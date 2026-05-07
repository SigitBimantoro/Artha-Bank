package models

import "time"
type Otp struct {
	OtpID     uint      `gorm:"primaryKey;column:otp_id" json:"otp_id"`
	UserID    uint      `gorm:"type:bigint;not null;column:user_id" json:"user_id"`
	Kode      string    `gorm:"type:varchar(10);not null;column:kode" json:"kode"`
	ExpiredAt time.Time `gorm:"not null;column:expired_at" json:"expired_at"`
	Status    string    `gorm:"type:varchar(20);default:'PENDING';column:status" json:"status"`
}