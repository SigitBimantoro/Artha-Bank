package models

import "time"

type Transaction struct {
	TransactionID   uint      `gorm:"primaryKey;autoIncrement;column:transaction_id" json:"transaction_id"`
	TransactionType string    `gorm:"type:varchar(20);not null;column:transaction_type" json:"transaction_type"`
	
	SenderID        uint      `gorm:"type:bigint;not null;column:sender_id" json:"sender_id"` 
	ReceiverID      uint      `gorm:"type:bigint;not null;column:receiver_id" json:"receiver_id"` 
	
	Amount          float64   `gorm:"type:numeric(15,2);not null;column:amount" json:"amount"`
	Notes           string    `gorm:"type:text;column:notes" json:"notes"`
	CreatedAt       time.Time `gorm:"autoCreateTime;column:created_at" json:"created_at"`
	Sender          User      `gorm:"foreignKey:SenderID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"-"`
	Receiver        User      `gorm:"foreignKey:ReceiverID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;" json:"-"`
}