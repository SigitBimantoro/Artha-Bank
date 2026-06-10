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
	Pembayaran        float64 `json:"pembayaran"`
	PembayaranPulsa   float64 `json:"pembayaran_pulsa"`
	PembayaranListrik float64 `json:"pembayaran_listrik"`
	TopUp             float64 `json:"top_up"`
	TransferMasuk     float64 `json:"transfer_masuk"`
	TransferKeluar    float64 `json:"transfer_keluar"`
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
		if trx.TransactionType == "TOPUP" || trx.TransactionType == "SAVING_OUT" {
			tipeMutasi = "MASUK"
		} else if trx.TransactionType == "PULSA" || trx.TransactionType == "PLN" || trx.TransactionType == "SAVING_IN" {
			tipeMutasi = "KELUAR"
		} else if trx.ReceiverID == userID {
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
	// PERBAIKAN 1: Gunakan waktu lokal agar sesuai dengan zona waktu database (WIB)
	now := time.Now()

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
		// PERBAIKAN 2: Paksa semua tipe transaksi jadi huruf besar agar aman dari typo di DB
		trxType := strings.ToUpper(trx.TransactionType)

		isPembayaran := trx.SenderID == userID && (trxType == "PULSA" || trxType == "PLN" || trxType == "PEMBAYARAN")
		isPulsa := trx.SenderID == userID && trxType == "PULSA"
		isListrik := trx.SenderID == userID && trxType == "PLN"
		// PERBAIKAN 3: Longgarkan syarat Top Up agar terbaca (entah user sebagai penerima/pengirim)
		isTopUp := trxType == "TOPUP"
		isTransferKeluar := trx.SenderID == userID && trxType == "TRANSFER"
		isTransferMasuk := trx.ReceiverID == userID && trxType == "TRANSFER"

		// Tambahkan ke Total jika ini adalah uang keluar (pengeluaran) atau topup
		if isPembayaran || isTopUp || isTransferKeluar {
			grandTotal += trx.Amount
		}

		if isPembayaran {
			pieChart.Pembayaran += trx.Amount
			if isPulsa {
				pieChart.PembayaranPulsa += trx.Amount
			} else if isListrik {
				pieChart.PembayaranListrik += trx.Amount
			}
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
				idx = 6 // Hari Minggu diletakkan di akhir (index 6)
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
			if isPulsa {
				barChart[idx].Nominal.PembayaranPulsa += trx.Amount
			} else if isListrik {
				barChart[idx].Nominal.PembayaranListrik += trx.Amount
			}
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
	pdf.SetMargins(14, 14, 14)
	pdf.AddPage()

	primaryR, primaryG, primaryB := 77, 85, 204
	darkR, darkG, darkB := 44, 38, 92
	softR, softG, softB := 238, 240, 255

	formatCurrency := func(value float64) string {
		return fmt.Sprintf("Rp %.2f", value)
	}

	periodLabel := map[string]string{
		"weekly":  "Mingguan",
		"monthly": "Bulanan",
		"yearly":  "Tahunan",
	}[period]
	if periodLabel == "" {
		periodLabel = strings.Title(period)
	}

	pdf.SetFillColor(primaryR, primaryG, primaryB)
	pdf.SetTextColor(255, 255, 255)
	pdf.SetFont("Arial", "B", 18)
	pdf.CellFormat(0, 14, "Ringkasan Keuangan Artha", "0", 1, "C", true, 0, "")
	pdf.Ln(8)

	pdf.SetTextColor(darkR, darkG, darkB)
	pdf.SetFont("Arial", "B", 13)
	pdf.CellFormat(90, 9, "Periode", "1", 0, "L", false, 0, "")
	pdf.CellFormat(90, 9, "Total Keseluruhan", "1", 1, "L", false, 0, "")
	pdf.SetFont("Arial", "", 12)
	pdf.SetFillColor(softR, softG, softB)
	pdf.CellFormat(90, 11, periodLabel, "1", 0, "L", true, 0, "")
	pdf.CellFormat(90, 11, formatCurrency(grandTotal), "1", 1, "L", true, 0, "")
	pdf.Ln(10)

	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Rincian Kategori", "", 1, "L", false, 0, "")
	pdf.Ln(2)
	pdf.SetFillColor(primaryR, primaryG, primaryB)
	pdf.SetTextColor(255, 255, 255)
	pdf.SetFont("Arial", "B", 11)
	pdf.CellFormat(90, 9, "Kategori", "1", 0, "C", true, 0, "")
	pdf.CellFormat(90, 9, "Nominal", "1", 1, "C", true, 0, "")

	pdf.SetTextColor(darkR, darkG, darkB)
	pdf.SetFont("Arial", "", 11)
	categoryRows := []struct {
		Label string
		Value float64
	}{
		{"Pulsa / Kuota", pieChart.PembayaranPulsa},
		{"Tagihan Listrik", pieChart.PembayaranListrik},
		{"Top Up", pieChart.TopUp},
		{"Transfer Masuk", pieChart.TransferMasuk},
		{"Transfer Keluar", pieChart.TransferKeluar},
	}
	for i, row := range categoryRows {
		pdf.SetFillColor(255, 255, 255)
		if i%2 == 1 {
			pdf.SetFillColor(softR, softG, softB)
		}
		pdf.CellFormat(90, 8, row.Label, "1", 0, "L", true, 0, "")
		pdf.CellFormat(90, 8, formatCurrency(row.Value), "1", 1, "R", true, 0, "")
	}
	pdf.Ln(10)

	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Ringkasan Periode", "", 1, "L", false, 0, "")
	pdf.Ln(2)

	pdf.SetFillColor(primaryR, primaryG, primaryB)
	pdf.SetTextColor(255, 255, 255)
	pdf.SetFont("Arial", "B", 9)
	pdf.CellFormat(18, 9, "Label", "1", 0, "C", true, 0, "")
	pdf.CellFormat(30, 9, "Pulsa / Kuota", "1", 0, "C", true, 0, "")
	pdf.CellFormat(30, 9, "Tagihan Listrik", "1", 0, "C", true, 0, "")
	pdf.CellFormat(28, 9, "Top Up", "1", 0, "C", true, 0, "")
	pdf.CellFormat(37, 9, "Transfer Masuk", "1", 0, "C", true, 0, "")
	pdf.CellFormat(37, 9, "Transfer Keluar", "1", 1, "C", true, 0, "")

	pdf.SetTextColor(darkR, darkG, darkB)
	pdf.SetFont("Arial", "", 8)
	for _, bar := range barChart {
		pdf.SetFillColor(255, 255, 255)
		pdf.CellFormat(18, 8, bar.Label, "1", 0, "C", true, 0, "")
		pdf.CellFormat(30, 8, formatCurrency(bar.Nominal.PembayaranPulsa), "1", 0, "R", true, 0, "")
		pdf.CellFormat(30, 8, formatCurrency(bar.Nominal.PembayaranListrik), "1", 0, "R", true, 0, "")
		pdf.CellFormat(28, 8, formatCurrency(bar.Nominal.TopUp), "1", 0, "R", true, 0, "")
		pdf.CellFormat(37, 8, formatCurrency(bar.Nominal.TransferMasuk), "1", 0, "R", true, 0, "")
		pdf.CellFormat(37, 8, formatCurrency(bar.Nominal.TransferKeluar), "1", 1, "R", true, 0, "")
	}
	pdf.Ln(8)

	summaryText := buildTrackingSummaryText(periodLabel, pieChart, grandTotal)
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 8, "Kesimpulan", "", 1, "L", false, 0, "")
	pdf.SetFont("Arial", "", 11)
	pdf.MultiCell(0, 7, summaryText, "1", "L", false)
	pdf.Ln(4)

	pdf.SetTextColor(90, 90, 90)
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

func buildTrackingSummaryText(periodLabel string, pieChart RincianKategori, grandTotal float64) string {
	formatCurrency := func(value float64) string {
		return fmt.Sprintf("Rp %.2f", value)
	}

	expenseRows := []struct {
		Label string
		Value float64
	}{
		{"Pulsa / Kuota", pieChart.PembayaranPulsa},
		{"Tagihan Listrik", pieChart.PembayaranListrik},
		{"Transfer Keluar", pieChart.TransferKeluar},
	}

	totalPengeluaran := pieChart.PembayaranPulsa + pieChart.PembayaranListrik + pieChart.TransferKeluar
	totalPemasukan := pieChart.TopUp + pieChart.TransferMasuk

	topExpenseLabel := "belum ada pengeluaran"
	topExpenseValue := 0.0
	for _, row := range expenseRows {
		if row.Value > topExpenseValue {
			topExpenseLabel = row.Label
			topExpenseValue = row.Value
		}
	}

	if totalPengeluaran <= 0 {
		return fmt.Sprintf(
			"Pada periode %s, belum ada pengeluaran yang tercatat. Total aktivitas keuangan yang terbaca adalah %s, dengan pemasukan sebesar %s.",
			periodLabel,
			formatCurrency(grandTotal),
			formatCurrency(totalPemasukan),
		)
	}

	balanceText := "lebih kecil dari"
	if totalPengeluaran > totalPemasukan {
		balanceText = "lebih besar dari"
	} else if totalPengeluaran == totalPemasukan {
		balanceText = "sama dengan"
	}

	return fmt.Sprintf(
		"Pada periode %s, total pengeluaran user adalah %s. Pengeluaran terbesar berasal dari %s sebesar %s. Total pemasukan tercatat %s, sehingga pengeluaran periode ini %s pemasukan.",
		periodLabel,
		formatCurrency(totalPengeluaran),
		topExpenseLabel,
		formatCurrency(topExpenseValue),
		formatCurrency(totalPemasukan),
		balanceText,
	)
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
