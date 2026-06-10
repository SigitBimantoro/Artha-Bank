package controllers

import (
	"artha/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SavingController struct {
	DB *gorm.DB
}

// Struct Requests
type CreateSavingReq struct {
	NamaTarget       string  `json:"nama_target" binding:"required"`
	TargetNominal    float64 `json:"target_nominal" binding:"required,min=10000"`
	AutoDebitNominal float64 `json:"auto_debit_nominal"`
	AutoDebitPeriode string  `json:"auto_debit_periode"`
}

type UpdateSavingReq struct {
	NamaTarget    string  `json:"nama_target" binding:"required"`
	TargetNominal float64 `json:"target_nominal" binding:"required,min=10000"`
}

type UpdateAutoDebitReq struct {
	AutoDebitNominal float64 `json:"auto_debit_nominal"`
	AutoDebitPeriode string  `json:"auto_debit_periode"`
}

// 1. LIHAT DAFTAR TABUNGAN
func (sc *SavingController) GetSavings(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	var savings []models.Saving
	sc.DB.Where("user_id = ?", userID).Find(&savings)

	if savings == nil {
		savings = []models.Saving{} // Hindari return null
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil mengambil data tabungan",
		"total":   len(savings),
		"data":    savings,
	})
}

// 2. BUAT TABUNGAN BARU (MAKSIMAL 3)
func (sc *SavingController) CreateSaving(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	var req CreateSavingReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format salah. Pastikan nama terisi dan target minimal Rp 10.000"})
		return
	}
	if req.AutoDebitPeriode == "" || req.AutoDebitNominal <= 0 {
		req.AutoDebitPeriode = "NONE"
		req.AutoDebitNominal = 0
	}

	// Cek apakah user sudah punya 3 tabungan
	var count int64
	sc.DB.Model(&models.Saving{}).Where("user_id = ?", userID).Count(&count)
	if count >= 3 {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda sudah mencapai batas maksimal 3 tabungan aktif."})
		return
	}

	newSaving := models.Saving{
		UserID:           userID,
		NamaTarget:       req.NamaTarget,
		TargetNominal:    req.TargetNominal,
		AutoDebitNominal: req.AutoDebitNominal,
		AutoDebitPeriode: req.AutoDebitPeriode,
	}

	if err := sc.DB.Create(&newSaving).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat tabungan baru"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Tabungan impian berhasil dibuat!", "data": newSaving})
}

// 3. EDIT NAMA DAN TARGET NOMINAL
func (sc *SavingController) UpdateSaving(c *gin.Context) {
	savingID := c.Param("id") // Tangkap ID tabungan dari URL

	var req UpdateSavingReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak valid"})
		return
	}

	var saving models.Saving
	if err := sc.DB.First(&saving, savingID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tabungan tidak ditemukan"})
		return
	}

	saving.NamaTarget = req.NamaTarget
	saving.TargetNominal = req.TargetNominal

	sc.DB.Save(&saving)

	c.JSON(http.StatusOK, gin.H{"message": "Tabungan berhasil diperbarui!", "data": saving})
}

// 4. UPDATE PENGATURAN AUTO-DEBIT
func (sc *SavingController) UpdateAutoDebit(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)
	savingID := c.Param("id")

	var req UpdateAutoDebitReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data auto-debit tidak valid"})
		return
	}

	if req.AutoDebitPeriode == "" {
		req.AutoDebitPeriode = "NONE"
	}
	if req.AutoDebitPeriode == "NONE" {
		req.AutoDebitNominal = 0
	} else if req.AutoDebitNominal < 1000 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimal nominal auto-debit adalah Rp 1.000"})
		return
	}

	var saving models.Saving
	if err := sc.DB.Where("saving_id = ? AND user_id = ?", savingID, userID).First(&saving).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tabungan tidak ditemukan"})
		return
	}

	saving.AutoDebitNominal = req.AutoDebitNominal
	saving.AutoDebitPeriode = req.AutoDebitPeriode

	if err := sc.DB.Save(&saving).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pengaturan auto-debit"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pengaturan auto-debit berhasil diperbarui", "data": saving})
}

type TransaksiSavingReq struct {
	Amount float64 `json:"amount" binding:"required,min=1000"`
}

// 5. NABUNG (Pindah Uang: Dompet -> Tabungan)
func (sc *SavingController) AddSaldo(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)
	savingID := c.Param("id")

	var req TransaksiSavingReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimal menabung adalah Rp 1.000"})
		return
	}

	tx := sc.DB.Begin()

	// Kunci dan cek saldo Dompet Utama
	var wallet models.Wallet
	tx.Where("user_id = ?", userID).First(&wallet)
	if wallet.Saldo < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Saldo dompet utama tidak cukup untuk menabung."})
		return
	}

	// Kunci dan cari Tabungan
	var saving models.Saving
	if err := tx.Where("saving_id = ? AND user_id = ?", savingID, userID).First(&saving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Tabungan tidak valid"})
		return
	}

	// Lakukan Perpindahan Uang
	wallet.Saldo -= req.Amount
	saving.SaldoTerkumpul += req.Amount

	tx.Save(&wallet)
	tx.Save(&saving)

	// Catat ke Mutasi History agar terbaca di Grafik Tracking
	catatan := "Nabung untuk target: " + saving.NamaTarget
	tx.Create(&models.Transaction{
		TransactionType: "SAVING_IN",
		SenderID:        userID,
		ReceiverID:      userID, // Kirim ke diri sendiri
		Amount:          req.Amount,
		Notes:           catatan,
	})

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "Berhasil menabung!", "saldo_tabungan": saving.SaldoTerkumpul})
}

// 6. CAIRKAN FLEKSIBEL (Pindah Uang: Tabungan -> Dompet)
func (sc *SavingController) TarikSaldo(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)
	savingID := c.Param("id")

	var req TransaksiSavingReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Minimal penarikan adalah Rp 1.000"})
		return
	}

	tx := sc.DB.Begin()

	var saving models.Saving
	if err := tx.Where("saving_id = ? AND user_id = ?", savingID, userID).First(&saving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Tabungan tidak ditemukan"})
		return
	}

	// Cek apakah saldo tabungan cukup ditarik
	if saving.SaldoTerkumpul < req.Amount {
		tx.Rollback()
		c.JSON(http.StatusBadRequest, gin.H{"error": "Saldo tabungan tidak cukup untuk ditarik."})
		return
	}

	var wallet models.Wallet
	tx.Where("user_id = ?", userID).First(&wallet)

	// Kembalikan Uang ke Dompet Utama
	saving.SaldoTerkumpul -= req.Amount
	wallet.Saldo += req.Amount

	tx.Save(&saving)
	tx.Save(&wallet)

	// Catat ke Mutasi History
	catatan := "Pencairan dari tabungan: " + saving.NamaTarget
	tx.Create(&models.Transaction{
		TransactionType: "SAVING_OUT",
		SenderID:        userID,
		ReceiverID:      userID,
		Amount:          req.Amount,
		Notes:           catatan,
	})

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "Saldo tabungan berhasil dicairkan ke dompet utama!", "saldo_dompet": wallet.Saldo})
}

// 7. HAPUS TABUNGAN
func (sc *SavingController) DeleteSaving(c *gin.Context) {
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)
	savingID := c.Param("id")

	tx := sc.DB.Begin()

	var saving models.Saving
	if err := tx.Where("saving_id = ? AND user_id = ?", savingID, userID).First(&saving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusNotFound, gin.H{"error": "Tabungan tidak ditemukan"})
		return
	}

	if saving.SaldoTerkumpul > 0 {
		var wallet models.Wallet
		if err := tx.Where("user_id = ?", userID).First(&wallet).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengakses dompet utama"})
			return
		}

		wallet.Saldo += saving.SaldoTerkumpul
		if err := tx.Save(&wallet).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengembalikan saldo tabungan"})
			return
		}

		catatan := "Pengembalian saldo dari wishlist yang dihapus: " + saving.NamaTarget
		if err := tx.Create(&models.Transaction{
			TransactionType: "SAVING_OUT",
			SenderID:        userID,
			ReceiverID:      userID,
			Amount:          saving.SaldoTerkumpul,
			Notes:           catatan,
		}).Error; err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mencatat pengembalian saldo"})
			return
		}
	}

	if err := tx.Delete(&saving).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus wishlist"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "Wishlist berhasil dihapus"})
}
