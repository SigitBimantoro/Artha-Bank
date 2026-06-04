package config

import (
	"log"

	"artha/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB() {
	dsn := "postgresql://neondb_owner:npg_oJXRYfrb21wV@ep-plain-darkness-a1xxp6bi-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("failed to connect to the database: ", err)
	}

	err = DB.AutoMigrate(&models.User{}, &models.Otp{}, &models.AuthSession{}, &models.Wallet{}, &models.Transaction{}, &models.Saving{}, &models.FavoriteAccount{})
	if err != nil {
		log.Fatal("Error:", err)
	}
}
