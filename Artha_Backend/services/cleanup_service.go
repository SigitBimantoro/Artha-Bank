package services

import (
	"fmt"
	"time"

	"artha/models" // Sesuaikan dengan nama module-mu

	"gorm.io/gorm"
)

// Fungsi ini akan berjalan terus-menerus di latar belakang
func MulaiRobotPenyapu(db *gorm.DB) {
	// Robot ini akan bangun dan bekerja setiap 1 Menit
	

	// Goroutine (Proses latar belakang khas Golang)
	go func() {
		ticker := time.NewTicker(1 * time.Minute)
		for {
			// Tunggu sampai 1 menit berlalu
			<-ticker.C 
			
			waktuSekarang := time.Now().UTC()

			// 1. SAPU BERSIH AUTH SESSIONS
			// "Hei Database, cari semua sesi yang masih ACTIVE tapi waktunya sudah lewat, lalu ubah jadi EXPIRED!"

			// 2. SAPU BERSIH OTP (Asumsi kamu punya tabel/model OTP dengan struktur serupa)
			hasilOTP := db.Table("otps"). // Sesuaikan nama tabel OTP-mu
			Where("status = ? AND expired_at < ?", "PENDING", waktuSekarang).
			Update("status", "EXPIRED")

			
			if hasilOTP.RowsAffected > 0 {
    fmt.Printf("[ROBOT] Berhasil mengubah %d OTP menjadi EXPIRED\n", hasilOTP.RowsAffected)
			}
		}
	}()
	go func() {
		tickerSesi := time.NewTicker(15 * time.Minute)
		for {
			<-tickerSesi.C
			waktuSekarang := time.Now().UTC()

			hasilSession := db.Model(&models.AuthSession{}).
				Where("status = ? AND expired_at < ?", "ACTIVE", waktuSekarang).
				Update("status", "EXPIRED")

			if hasilSession.RowsAffected > 0 {
				fmt.Printf("[ROBOT SESI] Berhasil menyapu %d sesi menjadi EXPIRED\n", hasilSession.RowsAffected)
			}
		}
	}()
}