package middlewares

import (
	"artha/models"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var jwtKey = []byte("artha_secret_key_2026")

func CekTiketJWT(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Akses ditolak: Token tidak ditemukan"})
			c.Abort()
			return
		}

		tokenString := strings.Replace(authHeader, "Bearer ", "", 1)

		// Verifikasi JWT
		_, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("Metode enkripsi token tidak valid")
			}
			return jwtKey, nil
		})

		// JIKA ERROR KARENA KEDALUWARSA (EXPIRED)
		if err != nil {
			if errors.Is(err, jwt.ErrTokenExpired) {
				// 🟢 PERUBAHAN: Jangan dihapus! Ubah statusnya jadi EXPIRED
				db.Model(&models.AuthSession{}).Where("token = ?", tokenString).Update("status", "EXPIRED")
				
				c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi Anda telah berakhir, silakan login kembali"})
				c.Abort()
				return
			}

			c.JSON(http.StatusUnauthorized, gin.H{"error": "Token tidak valid atau telah dimodifikasi"})
			c.Abort()
			return
		}

		// 🟢 PERUBAHAN: Pastikan token ada di database DAN statusnya WAJIB "ACTIVE"
		var session models.AuthSession
		if err := db.Where("token = ? AND status = ?", tokenString, "ACTIVE").First(&session).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid atau Anda sudah logout"})
			c.Abort()
			return
		}

		// Cek kedaluwarsa manual (Berjaga-jaga jika JWT Parse lolos)
		if time.Now().UTC().After(session.ExpiredAt) {
			// 🟢 PERUBAHAN: Ubah status jadi EXPIRED
			db.Model(&session).Update("status", "EXPIRED")
			
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi Anda telah berakhir, silakan login kembali"})
			c.Abort()
			return
		}

		// SUKSES!
		c.Set("userID", session.UserID)
		c.Next()
	}
}

func CekPIN(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Ambil User ID dari Satpam Pertama (JWT)
		userIDContext, exists := c.Get("userID")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid"})
			c.Abort()
			return
		}
		userID := userIDContext.(uint)

		// 2. Ambil PIN dari Header (Teman Flutter-mu harus mengirim header "X-PIN")
		pinHeader := c.GetHeader("X-PIN")
		if pinHeader == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "PIN Keamanan (X-PIN) wajib disertakan untuk transaksi ini."})
			c.Abort()
			return
		}

		// 3. Cari User di Database untuk mengambil PIN yang di-hash
		var user models.User
		if err := db.Select("pin").Where("user_id = ?", userID).First(&user).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memverifikasi user"})
			c.Abort()
			return
		}

		// 4. Pastikan User sudah pernah membuat PIN
		if user.Pin == "" {
			c.JSON(http.StatusForbidden, gin.H{"error": "Anda belum mengatur PIN Keamanan. Silakan buat PIN terlebih dahulu."})
			c.Abort()
			return
		}

		// 5. Bandingkan PIN dari Header dengan PIN di Database (Pakai bcrypt)
		err := bcrypt.CompareHashAndPassword([]byte(user.Pin), []byte(pinHeader))
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "PIN yang Anda masukkan salah!"})
			c.Abort()
			return
		}

		// SUKSES! PIN Benar, silakan lanjut ke fitur Transfer/Pembayaran
		c.Next()
	}
}