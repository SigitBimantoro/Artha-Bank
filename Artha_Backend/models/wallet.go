package models

import "time"

type Wallet struct {
	WalletID  uint      `gorm:"primaryKey;autoIncrement;column:wallet_id" json:"wallet_id"`
	UserID    uint      `gorm:"type:bigint;uniqueIndex;not null;column:user_id" json:"user_id"`
	Saldo     float64   `gorm:"type:numeric(15,2);default:0;column:saldo" json:"saldo"`
	UpdatedAt time.Time `gorm:"column:updated_at" json:"updated_at"`
}