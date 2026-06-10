package jobs

import (
	"artha/models"
	"fmt"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ProsesAutoDebit berjalan berdasarkan jadwal cron,
// bukan saat top up masuk.
func ProsesAutoDebit(db *gorm.DB) {
	fmt.Println("[ROBOT] Memulai pengecekan Auto-Debit Tabungan...")

	var savings []models.Saving
	if err := db.Where("auto_debit_periode != ? AND auto_debit_nominal > 0", "NONE").Find(&savings).Error; err != nil {
		fmt.Println("[ROBOT] Gagal mengambil data tabungan:", err)
		return
	}

	waktuSekarang := time.Now()

	for _, saving := range savings {
		if !shouldProcessAutoDebit(saving.AutoDebitPeriode, waktuSekarang) {
			continue
		}

		tx := db.Begin()

		var wallet models.Wallet
		if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
			Where("user_id = ?", saving.UserID).
			First(&wallet).Error; err != nil {
			tx.Rollback()
			continue
		}

		var lockedSaving models.Saving
		if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
			Where("saving_id = ?", saving.SavingID).
			First(&lockedSaving).Error; err != nil {
			tx.Rollback()
			continue
		}

		if wallet.Saldo < lockedSaving.AutoDebitNominal {
			fmt.Printf("[ROBOT] Saldo User ID %d tidak cukup untuk Auto-Debit '%s'\n", lockedSaving.UserID, lockedSaving.NamaTarget)
			tx.Rollback()
			continue
		}

		wallet.Saldo -= lockedSaving.AutoDebitNominal
		lockedSaving.SaldoTerkumpul += lockedSaving.AutoDebitNominal

		if err := tx.Save(&wallet).Error; err != nil {
			tx.Rollback()
			continue
		}
		if err := tx.Save(&lockedSaving).Error; err != nil {
			tx.Rollback()
			continue
		}

		catatan := "Auto-Debit Tabungan: " + lockedSaving.NamaTarget
		if err := tx.Create(&models.Transaction{
			TransactionType: "SAVING_IN",
			SenderID:        lockedSaving.UserID,
			ReceiverID:      lockedSaving.UserID,
			Amount:          lockedSaving.AutoDebitNominal,
			Notes:           catatan,
		}).Error; err != nil {
			tx.Rollback()
			continue
		}

		tx.Commit()
		fmt.Printf("[ROBOT] Berhasil memotong Rp %.0f untuk '%s' (User %d)\n", lockedSaving.AutoDebitNominal, lockedSaving.NamaTarget, lockedSaving.UserID)
	}

	fmt.Println("[ROBOT] Pengecekan Auto-Debit selesai.")
}

func shouldProcessAutoDebit(periode string, now time.Time) bool {
	switch periode {
	case "DAILY":
		return true
	case "WEEKLY":
		return now.Weekday() == time.Monday
	case "MONTHLY":
		return now.Day() == 1
	default:
		return false
	}
}
