package controllers

import (
	"artha/models"
	"net/http"

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