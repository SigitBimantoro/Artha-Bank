package models

import "time"

type Saving struct {
	SavingID         uint      `gorm:"primaryKey;autoIncrement" json:"saving_id"`
	UserID           uint      `gorm:"not null" json:"user_id"`
	NamaTarget       string    `gorm:"type:varchar(100);not null" json:"nama_target"`
	TargetNominal    float64   `gorm:"not null" json:"target_nominal"`
	SaldoTerkumpul   float64   `gorm:"default:0" json:"saldo_terkumpul"`
	
	// Konfigurasi Auto-Debit (Bisa 0 jika user tidak mau auto-debit)
	AutoDebitNominal float64   `gorm:"default:0" json:"auto_debit_nominal"`
	AutoDebitPeriode string    `gorm:"type:varchar(20)" json:"auto_debit_periode"` // Contoh: "DAILY", "WEEKLY", "MONTHLY", atau "NONE"
	
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}