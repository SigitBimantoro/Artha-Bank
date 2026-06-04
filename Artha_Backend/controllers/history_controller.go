// Isi file: controllers/history_controller.go
package controllers

import (
	"artha/models"
	"bytes"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jung-kurt/gofpdf"
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

	limitStr := c.Query("limit")                // Cek apakah ada '?limit=...' di URL
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

func (hc *HistoryController) buildTrackingKeuangan(userID uint, period string) (RincianKategori, []GrafikBatang, float64, error) {
	var startDate time.Time
	now := time.Now().UTC()

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
			{Label: "M1"}, {Label: "M2"}, {Label: "M3"}, {Label: "M4"},
		}
	case "yearly":
		startDate = now.AddDate(-1, 0, 0)
		barChart = []GrafikBatang{
			{Label: "Jan"}, {Label: "Feb"}, {Label: "Mar"}, {Label: "Apr"},
			{Label: "Mei"}, {Label: "Jun"}, {Label: "Jul"}, {Label: "Ags"},
			{Label: "Sep"}, {Label: "Okt"}, {Label: "Nov"}, {Label: "Des"},
		}
	default:
		return RincianKategori{}, nil, 0, fmt.Errorf("Periode tidak valid")
	}

	var riwayat []models.Transaction
	if err := hc.DB.Where("(sender_id = ? OR receiver_id = ?) AND created_at >= ?", userID, userID, startDate).
		Find(&riwayat).Error; err != nil {
		return RincianKategori{}, nil, 0, err
	}

	var pieChart RincianKategori
	var grandTotal float64

	for _, trx := range riwayat {
		isPembayaran := trx.SenderID == userID && (trx.TransactionType == "PULSA" || trx.TransactionType == "PLN")
		isTopUp := trx.ReceiverID == userID && trx.TransactionType == "TOPUP"
		isTransferKeluar := trx.SenderID == userID && trx.TransactionType == "TRANSFER"
		isTransferMasuk := trx.ReceiverID == userID && trx.TransactionType == "TRANSFER"

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

		idx := 0
		if period == "weekly" {
			wd := int(trx.CreatedAt.Weekday())
			idx = wd - 1
			if idx < 0 {
				idx = 6
			}
		} else if period == "monthly" {
			day := trx.CreatedAt.Day()
			idx = (day - 1) / 7
			if idx > 3 {
				idx = 3
			}
		} else if period == "yearly" {
			idx = int(trx.CreatedAt.Month()) - 1
		}

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

	return pieChart, barChart, grandTotal, nil
}

func (hc *HistoryController) GetTrackingKeuangan(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	period := c.DefaultQuery("period", "weekly")

	pieChart, barChart, grandTotal, err := hc.buildTrackingKeuangan(userID, period)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":           "Berhasil mengambil data tracking",
		"periode":           period,
		"total_keseluruhan": grandTotal,
		"pie_chart":         pieChart,
		"bar_chart":         barChart,
	})
}

func (hc *HistoryController) ExportTrackingKeuanganPDF(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	period := c.DefaultQuery("period", "weekly")

	pieChart, barChart, grandTotal, err := hc.buildTrackingKeuangan(userID, period)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.SetTitle("Ringkasan Keuangan Artha", false)
	pdf.AddPage()
	pdf.SetFont("Arial", "B", 16)
	pdf.Cell(0, 10, "Ringkasan Keuangan Artha")
	pdf.Ln(12)

	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 7, fmt.Sprintf("Periode: %s", strings.Title(period)), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 7, fmt.Sprintf("Total Keseluruhan: Rp %.2f", grandTotal), "", 1, "", false, 0, "")
	pdf.Ln(5)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(0, 7, "Rincian Kategori:")
	pdf.Ln(8)
	pdf.SetFont("Arial", "", 11)
	pdf.CellFormat(0, 6, fmt.Sprintf("- Pembayaran: Rp %.2f", pieChart.Pembayaran), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 6, fmt.Sprintf("- Top Up: Rp %.2f", pieChart.TopUp), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 6, fmt.Sprintf("- Transfer Masuk: Rp %.2f", pieChart.TransferMasuk), "", 1, "", false, 0, "")
	pdf.CellFormat(0, 6, fmt.Sprintf("- Transfer Keluar: Rp %.2f", pieChart.TransferKeluar), "", 1, "", false, 0, "")
	pdf.Ln(8)

	pdf.SetFont("Arial", "B", 12)
	pdf.Cell(0, 7, "Bar Chart (Ringkasan):")
	pdf.Ln(8)
	pdf.SetFont("Arial", "", 11)
	for _, bar := range barChart {
		pdf.MultiCell(0, 6, fmt.Sprintf("%s: Pembayaran Rp %.2f, Top Up Rp %.2f, Transfer Masuk Rp %.2f, Transfer Keluar Rp %.2f", bar.Label, bar.Nominal.Pembayaran, bar.Nominal.TopUp, bar.Nominal.TransferMasuk, bar.Nominal.TransferKeluar), "", "L", false)
	}
	pdf.Ln(8)

	pdf.SetFont("Arial", "I", 10)
	pdf.CellFormat(0, 6, fmt.Sprintf("Dihasilkan pada: %s", time.Now().Format("02 Jan 2006 15:04")), "", 1, "", false, 0, "")

	var buf bytes.Buffer
	if err := pdf.Output(&buf); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat file PDF"})
		return
	}

	fileName := fmt.Sprintf("summary_%s.pdf", period)
	c.Header("Content-Type", "application/pdf")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", fileName))
	c.Data(http.StatusOK, "application/pdf", buf.Bytes())
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
