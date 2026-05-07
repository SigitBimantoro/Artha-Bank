package models

import "time"

type User struct {
	UserID     uint      `gorm:"primaryKey;autoIncrement;column:user_id" json:"user_id"`
	Nama       string    `gorm:"type:varchar(100);not null;column:nama" json:"nama"`
	Email      string    `gorm:"type:varchar(100);uniqueIndex:users_email_key;not null;column:email" json:"email"`
	Password   string    `gorm:"type:varchar(255);not null;column:password" json:"-"`
	PhoneNumber string	 `gorm:"type:varchar(255);uniqueIndex:user_phone_key;not null;column:phone_number" json:"phone_number"`
	IsVerified bool      `gorm:"default:false;column:is_verified" json:"is_verified"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt  time.Time `gorm:"column:updated_at" json:"updated_at"`
}