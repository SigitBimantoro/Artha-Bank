package controllers

import (
	"artha/models"
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type TransactionController struct {
	DB *gorm.DB
}
type TopUpReq struct {
	Amount float64 `json:"amount" binding:"required,gte=10000"`
}
type TransferReq struct {
	ReceiverPhone string  `json:"receiver_phone" binding:"required"`
	Amount        float64 `json:"amount" binding:"required,gt=0"`
	Notes         string  `json:"notes"`
}
type PulsaReq struct {
	PhoneNumber string  `json:"phone_number" binding:"required"`
	Amount      float64 `json:"amount" binding:"required,gt=0"`
}

type PLNReq struct {
	MeterNumber string  `json:"meter_number" binding:"required"`
	Amount      float64 `json:"amount" binding:"required,gt=0"`
}
// Fungsi Eksekusi Top Up
func (tc *TransactionController) TopUpInternal(c *gin.Context) {
	// 1. Ambil UserID dari Middleware JWT (Tidak bisa dipalsukan oleh Hacker)
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	// 2. Tangkap JSON Request (Jumlah Top Up)
	var req TopUpReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format jumlah saldo salah. Pastikan amount lebih dari 10000."})
		return
	}

	// 3. Mulai Transaksi Database (Mencegah data corrupt jika internet putus)
	tx := tc.DB.Begin()

	// 4. Cari Dompet User & Kunci Row-nya (Menghindari Double Top-Up bersamaan)
	var dompet models.Wallet
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", userID).First(&dompet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Data dompet tidak ditemukan"})
		return
	}

	// 5. Tambahkan Saldo
	dompet.Saldo += req.Amount
	if err := tx.Save(&dompet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan saldo baru"})
		return
	}

	// 6. Catat ke Buku Mutasi (Sender = 0, Receiver = UserID)
	newLog := models.Transaction{
		TransactionType: "TOPUP",
		SenderID:        0,       // 0 adalah identitas Sistem Artha / Bank
		ReceiverID:      userID,
		Amount:          req.Amount,
		Notes:           "Top Up Saldo Internal Artha",
	}
	
	if err := tx.Create(&newLog).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencatat riwayat mutasi"})
		return
	}

	// 7. Simpan Permanen (Commit)
	tx.Commit()

	// 8. Berikan Balasan ke Flutter
	c.JSON(http.StatusOK, gin.H{
		"message": "Top up berhasil diproses", 
		"saldo_sekarang": dompet.Saldo,
	})
}

func (tc *TransactionController) TransferUang(c *gin.Context) {
	// A. Ambil ID Pengirim dari Middleware JWT
	senderIDContext, _ := c.Get("userID")
	senderID := senderIDContext.(uint)

	// B. Tangkap Request
	var req TransferReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak valid. Pastikan nomor tujuan dan jumlah transfer diisi dengan benar."})
		return
	}

	// C. Cari ID Penerima berdasarkan Nomor HP
	var receiver models.User
	if err := tc.DB.Where("phone_number = ?", req.ReceiverPhone).First(&receiver).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Nomor tujuan tidak ditemukan di sistem Artha."})
		return
	}
	receiverID := receiver.UserID

	// D. Cegah Transfer ke Diri Sendiri
	if senderID == receiverID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Anda tidak bisa melakukan transfer ke nomor Anda sendiri."})
		return
	}

	// ==================================================
	// 🚀 MULAI TRANSAKSI DATABASE (ACID) & ROW LOCKING
	// ==================================================
	tx := tc.DB.Begin()

	// E. Kunci & Cek Dompet Pengirim
	var senderWallet models.Wallet
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", senderID).First(&senderWallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengakses dompet pengirim."})
		return
	}

	// F. Pastikan Saldo Cukup
	if senderWallet.Saldo < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maaf, saldo Anda tidak mencukupi."})
		return
	}

	// G. Kunci Dompet Penerima
	var receiverWallet models.Wallet
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", receiverID).First(&receiverWallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengakses dompet penerima."})
		return
	}

	// H. EKSEKUSI PEMINDAHAN UANG
	senderWallet.Saldo -= req.Amount   // Potong saldo pengirim
	receiverWallet.Saldo += req.Amount // Tambah saldo penerima

	if err := tx.Save(&senderWallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memotong saldo."})
		return
	}
	if err := tx.Save(&receiverWallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menambah saldo penerima."})
		return
	}

	// I. Catat Riwayat Mutasi ke Tabel Transactions
	newLog := models.Transaction{
		TransactionType: "TRANSFER",
		SenderID:        senderID,
		ReceiverID:      receiverID,
		Amount:          req.Amount,
		Notes:           req.Notes,
	}

	if err := tx.Create(&newLog).Error; err != nil {
		tx.Rollback() // Batalkan pemotongan uang jika gagal mencatat riwayat
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencatat riwayat mutasi."})
		return
	}

	// J. SIMPAN PERMANEN
	tx.Commit()

	// K. Beri Balasan Sukses
	c.JSON(http.StatusOK, gin.H{
		"message":     "Transfer berhasil diproses!",
		"sisa_saldo":  senderWallet.Saldo,
		"penerima":    receiver.Nama,
	})
}

// Fungsi Pencetak 20 Digit Token PLN
func generateTokenPLN() string {
	// Inisialisasi mesin random berdasarkan waktu saat ini agar angkanya selalu berbeda
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	var token string

	for i := 0; i < 20; i++ {
		// Tambahkan angka acak 0-9
		token += strconv.Itoa(r.Intn(10))
		
		// Jika sudah 4 angka dan bukan angka terakhir, tambahkan spasi
		if (i+1)%4 == 0 && i != 19 {
			token += " "
		}
	}
	return token
}
// ==========================================
// FITUR PEMBELIAN PULSA
// ==========================================
func (tc *TransactionController) BeliPulsa(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	var req PulsaReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nomor HP atau nominal pulsa tidak valid"})
		return
	}

	tx := tc.DB.Begin()

	// Kunci & Potong Saldo
	var wallet models.Wallet
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", userID).First(&wallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengakses dompet"})
		return
	}

	if wallet.Saldo < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maaf, saldo Anda tidak mencukupi"})
		return
	}

	wallet.Saldo -= req.Amount
	tx.Save(&wallet)

	// Catat Transaksi (Penerima = 0 / Sistem)
	newLog := models.Transaction{
		TransactionType: "PULSA",
		SenderID:        userID,
		ReceiverID:      0, 
		Amount:          req.Amount,
		Notes:           "Pembelian Pulsa untuk nomor " + req.PhoneNumber,
	}
	tx.Create(&newLog)
	tx.Commit()

	c.JSON(http.StatusOK, gin.H{
		"message":    "Pembelian pulsa berhasil!",
		"sisa_saldo": wallet.Saldo,
	})
}

// ==========================================
// FITUR PEMBELIAN TOKEN LISTRIK (PLN)
// ==========================================
func (tc *TransactionController) BeliTokenListrik(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	var req PLNReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nomor meteran atau nominal tidak valid"})
		return
	}

	tx := tc.DB.Begin()

	// Kunci & Potong Saldo
	var wallet models.Wallet
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).Where("user_id = ?", userID).First(&wallet).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengakses dompet"})
		return
	}

	if wallet.Saldo < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Maaf, saldo Anda tidak mencukupi"})
		return
	}

	wallet.Saldo -= req.Amount
	tx.Save(&wallet)

	// Generate 20 Digit Token PLN
	tokenPLN := generateTokenPLN()

	// Catat Transaksi dan simpan token di Notes
	newLog := models.Transaction{
		TransactionType: "PLN",
		SenderID:        userID,
		ReceiverID:      0,
		Amount:          req.Amount,
		Notes:           "Token Listrik: " + tokenPLN,
	}
	tx.Create(&newLog)
	tx.Commit()

	// Balasan ke Flutter (Mengirimkan token agar bisa ditampilkan di layar besar-besar)
	c.JSON(http.StatusOK, gin.H{
		"message":      "Pembelian Token Listrik berhasil!",
		"token_listrik": tokenPLN,
		"sisa_saldo":   wallet.Saldo,
	})
}
// ==========================================
// FITUR RIWAYAT TRANSAKSI (MUTASI)
// ==========================================
func (tc *TransactionController) GetRiwayatTransaksi(c *gin.Context) {
	// 1. Ambil ID User yang sedang login dari Satpam JWT
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	// 2. Siapkan keranjang kosong untuk menampung banyak data transaksi
	var riwayat []models.Transaction

	// 3. Query ke Database: Cari saat dia jadi Pengirim ATAU Penerima
	// Order("created_at desc") memastikan data terbaru ada di paling atas
	if err := tc.DB.Where("sender_id = ? OR receiver_id = ?", userID, userID).
		Order("created_at desc").
		Find(&riwayat).Error; err != nil {
		
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data riwayat transaksi"})
		return
	}

	// 4. (Opsional tapi keren) Mempercantik balasan untuk Flutter
	// Kita bantu Flutter menentukan apakah ini uang masuk atau keluar
	var formatRiwayat []gin.H
	for _, trx := range riwayat {
		tipeMutasi := "KELUAR"
		if trx.ReceiverID == userID {
			tipeMutasi = "MASUK" // Jika dia penerimanya, berarti uang masuk
		}

		formatRiwayat = append(formatRiwayat, gin.H{
			"transaction_id":   trx.TransactionID,
			"transaction_type": trx.TransactionType,
			"mutasi":           tipeMutasi, // "MASUK" atau "KELUAR"
			"amount":           trx.Amount,
			"notes":            trx.Notes,
			"tanggal":          trx.CreatedAt.Format("02 Jan 2006, 15:04 WIB"), // Format rapi
		})
	}

	// 5. Kirim datanya ke Flutter/Postman
	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil riwayat transaksi",
		"total":   len(riwayat),
		"data":    formatRiwayat,
	})
}

// ==========================================
// FITUR RINGKASAN KEUANGAN (DASHBOARD)
// ==========================================
func (tc *TransactionController) GetRingkasanTransaksi(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	// 1. Tangkap parameter dari URL (contoh: ?period=weekly). Default-nya "monthly"
	period := c.DefaultQuery("period", "monthly")

	var startDate time.Time
	now := time.Now().UTC()

	// 2. Tentukan batas waktu mundur berdasarkan pilihan
	switch period {
	case "weekly":
		startDate = now.AddDate(0, 0, -7) // Mundur 7 hari
	case "monthly":
		startDate = now.AddDate(0, -1, 0) // Mundur 1 bulan
	case "yearly":
		startDate = now.AddDate(-1, 0, 0) // Mundur 1 tahun
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Periode tidak valid. Gunakan: weekly, monthly, atau yearly"})
		return
	}

	// 3. Minta Database menghitung Total Pemasukan (Saat user jadi Receiver)
	// COALESCE digunakan agar jika belum ada transaksi, hasilnya 0 (bukan error NULL)
	var totalPemasukan float64
	tc.DB.Model(&models.Transaction{}).
		Where("receiver_id = ? AND created_at >= ?", userID, startDate).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalPemasukan)

	// 4. Minta Database menghitung Total Pengeluaran (Saat user jadi Sender)
	var totalPengeluaran float64
	tc.DB.Model(&models.Transaction{}).
		Where("sender_id = ? AND created_at >= ?", userID, startDate).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalPengeluaran)

	// 5. Kirim balasan ke Flutter
	c.JSON(http.StatusOK, gin.H{
		"message":      "Berhasil mengambil ringkasan keuangan",
		"periode_pilih": period,
		"dari_tanggal":  startDate.Format("02 Jan 2006"),
		"sampai_tanggal": now.Format("02 Jan 2006"),
		"pemasukan":    totalPemasukan,
		"pengeluaran":  totalPengeluaran,
		"selisih":      totalPemasukan - totalPengeluaran, // Tambahan ekstra agar teman Flutter-mu makin senang!
	})
}