package jobs

import (
	"artha/models"
	"fmt"
	"time"

	"gorm.io/gorm"
)

// Fungsi ini akan dieksekusi oleh Robot Cron
func ProsesAutoDebit(db *gorm.DB) {
	fmt.Println("[ROBOT] 🤖 Memulai pengecekan Auto-Debit Tabungan...")

	// 1. Cari semua tabungan yang fitur Auto-Debitnya menyala
	var savings []models.Saving
	if err := db.Where("auto_debit_periode != ?", "NONE").Find(&savings).Error; err != nil {
		fmt.Println("[ROBOT] ❌ Gagal mengambil data tabungan:", err)
		return
	}

	waktuSekarang := time.Now().UTC()

	// 2. Cek satu per satu tabungan tersebut
	for _, saving := range savings {
		harusDipotong := false

		// 3. Tentukan apakah hari ini adalah jadwal potong saldonya
		if saving.AutoDebitPeriode == "DAILY" {
			harusDipotong = true // Tiap hari dipotong
		} else if saving.AutoDebitPeriode == "WEEKLY" && waktuSekarang.Weekday() == time.Monday {
			harusDipotong = true // Hanya dipotong setiap hari Senin
		} else if saving.AutoDebitPeriode == "MONTHLY" && waktuSekarang.Day() == 1 {
			harusDipotong = true // Hanya dipotong setiap tanggal 1
		}

		if !harusDipotong {
			continue // Lewati jika bukan jadwalnya
		}

		// ==========================================
		// 4. EKSEKUSI PEMOTONGAN SALDO (TRANSAKSI AMAN)
		// ==========================================
		tx := db.Begin()

		// Cari dompet utamanya
		var wallet models.Wallet
		if err := tx.Where("user_id = ?", saving.UserID).First(&wallet).Error; err != nil {
			tx.Rollback()
			continue
		}

		// Cek apakah saldo dompet cukup untuk dipotong
		if wallet.Saldo < saving.AutoDebitNominal {
			fmt.Printf("[ROBOT] ⚠️ Saldo User ID %d tidak cukup untuk Auto-Debit '%s'\n", saving.UserID, saving.NamaTarget)
			tx.Rollback()
			continue
		}

		// Pindahkan Uang
		wallet.Saldo -= saving.AutoDebitNominal
		saving.SaldoTerkumpul += saving.AutoDebitNominal

		tx.Save(&wallet)
		tx.Save(&saving)

		// Catat ke History Transaksi
		catatan := "Auto-Debit Tabungan: " + saving.NamaTarget
		tx.Create(&models.Transaction{
			TransactionType: "SAVING_IN",
			SenderID:        saving.UserID,
			ReceiverID:      saving.UserID,
			Amount:          saving.AutoDebitNominal,
			Notes:           catatan,
		})

		tx.Commit()
		fmt.Printf("[ROBOT] ✅ Berhasil memotong Rp %.0f untuk '%s' (User %d)\n", saving.AutoDebitNominal, saving.NamaTarget, saving.UserID)
	}
	
	fmt.Println("[ROBOT] 🏁 Pengecekan Auto-Debit selesai.")
}