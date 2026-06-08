package models

import "time"

type FavoriteAccount struct {
    ID              string    `gorm:"type:uuid;primaryKey;column:id" json:"id"`
    UserID          uint      `gorm:"not null;column:user_id" json:"user_id"`
    RecipientUserID uint      `gorm:"not null;column:recipient_user_id" json:"recipient_user_id"`
    RecipientPhone  string    `gorm:"type:varchar(50);not null;column:recipient_phone" json:"recipient_phone"`
    RecipientName   string    `gorm:"type:varchar(100);not null;column:recipient_name" json:"recipient_name"`
    Label           string    `gorm:"type:varchar(100);not null;column:label" json:"label"`
    BankName        string    `gorm:"type:varchar(100);column:bank_name" json:"bank_name"`
    AccountNumber   string    `gorm:"type:varchar(50);column:account_number" json:"account_number"`
    AccountName     string    `gorm:"type:varchar(100);column:account_name" json:"account_name"` // Tambahkan ini
    CreatedAt       time.Time `gorm:"autoCreateTime;column:created_at" json:"created_at"`
    UpdatedAt       time.Time `gorm:"autoUpdateTime;column:updated_at" json:"updated_at"`
}