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