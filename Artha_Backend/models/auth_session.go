package models

import "time"

type AuthSession struct {
	SessionID uint      `gorm:"primaryKey;autoIncrement;column:session_id" json:"session_id"`
	UserID    uint      `gorm:"type:bigint;not null;column:user_id" json:"user_id"`
	Token     string    `gorm:"type:text;not null;column:token" json:"token"`
	ExpiredAt time.Time `gorm:"not null;column:expired_at" json:"expired_at"`
	Status    string    `gorm:"type:varchar(20);default:'ACTIVE'" json:"status"`
}