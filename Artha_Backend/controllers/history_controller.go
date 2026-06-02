// Isi file: controllers/history_controller.go
package controllers

import (
	"artha/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type RincianKategori struct {
	Pembayaran     float64 `json:"pembayaran"`
	TopUp          float64 `json:"top_up"`
	TransferMasuk  float64 `json:"transfer_masuk"`
	TransferKeluar float64 `json:"transfer_keluar"`
}

type GrafikBatang struct {
	Label   string          `json:"label"` // Misal: "Sen", "Sel", atau "Jan", "Feb"
	Nominal RincianKategori `json:"nominal"`
}

// Buat struct khusus untuk History
type HistoryController struct {
	DB *gorm.DB
}

// Ubah (tc *TransactionController) menjadi (hc *HistoryController)
func (hc *HistoryController) GetRiwayatTransaksi(c *gin.Context) {
	// 1. Ambil ID User yang sedang login dari Satpam JWT
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)
	
	limitStr := c.Query("limit") // Cek apakah ada '?limit=...' di URL
	limitPencarian, _ := strconv.Atoi(limitStr) // Ubah teks jadi angka. Kalau kosong, hasilnya otomatis 0

	// 2. Siapkan keranjang kosong untuk menampung banyak data transaksi
	var riwayat []models.Transaction
	
	query := hc.DB.Where("sender_id = ? OR receiver_id = ?", userID, userID).
		Order("created_at desc")

	// Jika teman Flutter mengirim angka limit (misal: lebih dari 0), pasang LIMIT ke database
	if limitPencarian > 0 {
		query = query.Limit(limitPencarian)
	}

	// 3. EKSEKUSI PENCARIAN
	if err := query.Find(&riwayat).Error; err != nil {
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
	// Jika data kosong, kita akali formatRiwayat agar menjadi array kosong [] bukan null
	if formatRiwayat == nil {
		formatRiwayat = []gin.H{}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil riwayat transaksi",
		"total":   len(riwayat),
		"data":    formatRiwayat,
	})
}

func (hc *HistoryController) GetTrackingKeuangan(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	period := c.DefaultQuery("period", "weekly")

	var startDate time.Time
	now := time.Now().UTC()

	// 2. Siapkan "Keranjang Kosong" untuk Grafik Batang (Bar Chart)
	var barChart []GrafikBatang

	switch period {
	case "weekly":
		startDate = now.AddDate(0, 0, -7)
		barChart = []GrafikBatang{
			{Label: "Sen"}, {Label: "Sel"}, {Label: "Rab"}, {Label: "Kam"}, 
			{Label: "Jum"}, {Label: "Sab"}, {Label: "Min"},
		}
	case "monthly":
		startDate = now.AddDate(0, -1, 0)
		barChart = []GrafikBatang{
			{Label: "M1"}, {Label: "M2"}, {Label: "M3"}, {Label: "M4"}, // Minggu 1, 2, 3, 4
		}
	case "yearly":
		startDate = now.AddDate(-1, 0, 0)
		barChart = []GrafikBatang{
			{Label: "Jan"}, {Label: "Feb"}, {Label: "Mar"}, {Label: "Apr"}, 
			{Label: "Mei"}, {Label: "Jun"}, {Label: "Jul"}, {Label: "Ags"}, 
			{Label: "Sep"}, {Label: "Okt"}, {Label: "Nov"}, {Label: "Des"},
		}
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": "Periode tidak valid"})
		return
	}

	// 3. Tarik SEMUA transaksi dalam rentang waktu tersebut (CUKUP 1 QUERY SAJA!)
	var riwayat []models.Transaction
	if err := hc.DB.Where("(sender_id = ? OR receiver_id = ?) AND created_at >= ?", userID, userID, startDate).
		Find(&riwayat).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data tracking"})
		return
	}

	// 4. Siapkan Keranjang untuk Pie Chart
	var pieChart RincianKategori
	var grandTotal float64

	// 5. PROSES PENGELOMPOKKAN (Murni di Memori Golang = Super Cepat)
	for _, trx := range riwayat {
		// A. Tentukan Kategori Transaksi
		isPembayaran := trx.SenderID == userID && (trx.TransactionType == "PULSA" || trx.TransactionType == "PLN")
		isTopUp := trx.ReceiverID == userID && trx.TransactionType == "TOPUP"
		isTransferKeluar := trx.SenderID == userID && trx.TransactionType == "TRANSFER"
		isTransferMasuk := trx.ReceiverID == userID && trx.TransactionType == "TRANSFER"

		// B. Tambahkan ke Grand Total & Pie Chart
		grandTotal += trx.Amount
		if isPembayaran {
			pieChart.Pembayaran += trx.Amount
		} else if isTopUp {
			pieChart.TopUp += trx.Amount
		} else if isTransferKeluar {
			pieChart.TransferKeluar += trx.Amount
		} else if isTransferMasuk {
			pieChart.TransferMasuk += trx.Amount
		}

		// C. Tentukan Masuk ke Keranjang Bar Chart yang Mana (Berdasarkan Waktu)
		idx := 0
		if period == "weekly" {
			// Golang: Minggu=0, Senin=1. Kita ubah agar Senin=0, Minggu=6
			wd := int(trx.CreatedAt.Weekday())
			idx = wd - 1
			if idx < 0 { idx = 6 }
		} else if period == "monthly" {
			// Bagi tanggal menjadi 4 minggu (Tgl 1-7 = M1, 8-14 = M2, dst)
			day := trx.CreatedAt.Day()
			idx = (day - 1) / 7
			if idx > 3 { idx = 3 } // Mentok di index 3 (M4)
		} else if period == "yearly" {
			// Bulan Jan=1, Feb=2. Kurangi 1 agar index array Jan=0, Feb=1
			idx = int(trx.CreatedAt.Month()) - 1
		}

		// D. Masukkan Nominal ke Bar Chart yang Sesuai
		if isPembayaran {
			barChart[idx].Nominal.Pembayaran += trx.Amount
		} else if isTopUp {
			barChart[idx].Nominal.TopUp += trx.Amount
		} else if isTransferKeluar {
			barChart[idx].Nominal.TransferKeluar += trx.Amount
		} else if isTransferMasuk {
			barChart[idx].Nominal.TransferMasuk += trx.Amount
		}
	}

	// 6. Kirim JSON Rapi ke Flutter
	c.JSON(http.StatusOK, gin.H{
		"message":           "Berhasil mengambil data tracking",
		"periode":           period,
		"total_keseluruhan": grandTotal,
		"pie_chart":         pieChart,
		"bar_chart":         barChart,
	})
}

func (hc *HistoryController) GetRiwayatTransferKeluar(c *gin.Context) {
	// 1. Ambil ID User dari Satpam JWT
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	// Tangkap parameter limit (opsional)
	limitStr := c.Query("limit")
	limitPencarian, _ := strconv.Atoi(limitStr)

	// ==============================================================
	// BAGIAN A: MENCARI 3 KONTAK TERAKHIR (Unik, tidak boleh ganda)
	// ==============================================================
	type RecentReceiver struct {
		ReceiverID uint
	}
	var recentIDs []RecentReceiver

	// Query Sakti: Kelompokkan berdasarkan penerima, ambil yang paling baru, batasi 3.
	hc.DB.Model(&models.Transaction{}).
		Select("receiver_id").
		Where("sender_id = ? AND transaction_type = ?", userID, "TRANSFER").
		Group("receiver_id").
		Order("MAX(created_at) DESC").
		Limit(3).
		Scan(&recentIDs)

	// Tarik nama dan nomor HP untuk 3 orang tersebut
	var recentContacts []gin.H
	for _, rec := range recentIDs {
		var u models.User
		// Cukup select nama dan nomor hp agar ringan
		hc.DB.Select("nama, phone_number").Where("user_id = ?", rec.ReceiverID).First(&u)
		recentContacts = append(recentContacts, gin.H{
			"nama":         u.Nama,
			"phone_number": u.PhoneNumber,
		})
	}

	// Jika kosong, pastikan mengirim array kosong [] bukan null
	if recentContacts == nil {
		recentContacts = []gin.H{}
	}

	// ==============================================================
	// BAGIAN B: MENCARI FULL RIWAYAT TRANSFER KELUAR
	// ==============================================================
	var riwayat []models.Transaction
	query := hc.DB.Where("sender_id = ? AND transaction_type = ?", userID, "TRANSFER").
		Order("created_at desc")

	// Pasang limit jika ada
	if limitPencarian > 0 {
		query = query.Limit(limitPencarian)
	}
	query.Find(&riwayat)

	// Trik Backend Pro: Hindari mengambil data user satu per satu di dalam loop (N+1 Problem).
	// Kita kumpulkan dulu semua ID penerimanya:
	var receiverIDs []uint
	for _, trx := range riwayat {
		receiverIDs = append(receiverIDs, trx.ReceiverID)
	}

	// Tarik SEMUA data penerima dalam 1x pencarian database
	var receivers []models.User
	if len(receiverIDs) > 0 {
		hc.DB.Select("user_id, nama, phone_number").Where("user_id IN ?", receiverIDs).Find(&receivers)
	}

	// Buat Kamus/Map agar cepat dicari
	mapReceiver := make(map[uint]models.User)
	for _, r := range receivers {
		mapReceiver[r.UserID] = r
	}

	// Rangkai data JSON untuk Flutter
	var formatRiwayat []gin.H
	for _, trx := range riwayat {
		penerima := mapReceiver[trx.ReceiverID] // Ambil dari kamus

		formatRiwayat = append(formatRiwayat, gin.H{
			"transaction_id": trx.TransactionID,
			"nama_penerima":  penerima.Nama,
			"nomor_penerima": penerima.PhoneNumber,
			"amount":         trx.Amount,
			"notes":          trx.Notes,
			"tanggal":        trx.CreatedAt.Format("02 Jan 2006, 15:04 WIB"),
		})
	}

	if formatRiwayat == nil {
		formatRiwayat = []gin.H{}
	}

	// ==============================================================
	// KIRIM BALASAN KE FLUTTER
	// ==============================================================
	c.JSON(http.StatusOK, gin.H{
		"message":         "Berhasil mengambil data riwayat transfer",
		"recent_contacts": recentContacts,
		"total_riwayat":   len(formatRiwayat),
		"riwayat":         formatRiwayat,
	})
}