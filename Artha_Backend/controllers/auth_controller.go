package controllers

import (
	"errors"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"artha/models"
	"artha/services"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var jwtKey = []byte("artha_secret_key_2026")

type ForgotPasswordReq struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
}

type ResetPasswordReq struct {
	PhoneNumber string `json:"phone_number" binding:"required"`
	OTP         string `json:"otp" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type AuthController struct {
	DB *gorm.DB
}
type RegisterRequest struct {
	Nama     string `json:"nama" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	PhoneNumber string	`json:"phone_number" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
}

type LoginRequest struct {
	PhoneNumber    string `json:"phone_number" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type VerifyOTPRequest struct {
	Email string `json:"email" binding:"required,email"`
	Kode  string `json:"kode" binding:"required,len=6"`
}

type ResendOTPRequest struct {
	Email string `json:"email" binding:"required,email"`
}
type SetPinReq struct {
	Pin string `json:"pin" binding:"required,len=6,numeric"`
}
func (ac *AuthController)RegisterUser(c *gin.Context) {
	var req RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		fmt.Println("1", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err})
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)

	newUser := models.User{
		Nama:     req.Nama,
		Email:    req.Email,
		PhoneNumber: req.PhoneNumber,
		Password: string(hashedPassword),
	}
	if result := ac.DB.Create(&newUser); result.Error != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email or phone number is already registered."})
		return
	}
	newDompet := models.Wallet{
		UserID: newUser.UserID,
		Saldo:  0,
	}
	ac.DB.Create(&newDompet)
	kodeOTP := fmt.Sprintf("%06d", rand.Intn(1000000))
	waktuExpired := time.Now().UTC().Add(3 * time.Minute)

	newOtp := models.Otp{
		UserID:    newUser.UserID,
		Kode:      kodeOTP,
		ExpiredAt: waktuExpired,
	}
	ac.DB.Create(&newOtp)

	go func() {
		err := services.KirimEmailOTP(req.Email, kodeOTP)
		if err != nil {
			fmt.Println("GAGAL mengirim email ke:", req.Email, "Error:", err)
		} else {
			fmt.Println("SUKSES mengirim email OTP ke:", req.Email)
		}
	}()

	c.JSON(http.StatusCreated, gin.H{
		"message": "Registration successful. Please check your email for the OTP.",
		"user_id": newUser.UserID,
	})
}

func (ac *AuthController)VerifyOTP(c *gin.Context) {
	var req VerifyOTPRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email or OTP code is incorrect."})
		return
	}
	var user models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Email or OTP code is incorrect."})
		return
	}

	var otp models.Otp
	result := ac.DB.Where("user_id = ? AND kode = ? AND status = 'PENDING'", user.UserID, req.Kode).First(&otp)
	
	if result.Error != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email or OTP code is incorrect."})
		return
	}

	if time.Now().UTC().After(otp.ExpiredAt) {
		otp.Status = "EXPIRED"
		ac.DB.Save(&otp)
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP code has expired, please request a new one!"})
		return
	}

	otp.Status = "VERIFIED"
	ac.DB.Save(&otp)
	ac.DB.Model(&user).Update("is_verified", true)
	c.JSON(http.StatusOK, gin.H{"message": "Verification successful! Your account is now active."})
}

func (ac *AuthController)LoginUser(c *gin.Context) {
	var req LoginRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "incomplete data"})
		return
	}

	var user models.User
	result := ac.DB.Where("phone_number = ?", req.PhoneNumber).First(&user)
	
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "PhoneNumber or Password is incorrect."})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}
	
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "PhoneNumber or Password is incorrect."})
		return
	}
	if !user.IsVerified {
        c.JSON(http.StatusForbidden, gin.H{
            "error": "The account is not active. Please verify the OTP first.",
        })
        return
    }
	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &jwt.RegisteredClaims{
		Subject:   user.PhoneNumber,
		ExpiresAt: jwt.NewNumericDate(expirationTime),
	}
	token, _ := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(jwtKey)

	newSession := models.AuthSession{
		UserID:    user.UserID,
		Token:     token,
		ExpiredAt: expirationTime,
	}
	ac.DB.Create(&newSession)

	hasPin := false
	if user.Pin != "" {
		hasPin = true
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Login successful!",
		"token":   token,
		"has_pin": hasPin, // 👈 INDIKATOR UNTUK FLUTTER
		"user": gin.H{
			"user_id":      user.UserID,
			"nama":         user.Nama,
			"phone_number": user.PhoneNumber,
		},
	})
}

func (ac *AuthController)ResendOTP(c *gin.Context) {
	var req ResendOTPRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Wrong email format."})
		return
	}

	var user models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Email not registered"})
		return
	}

	if user.IsVerified {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Your account is already active."})
		return
	}

	ac.DB.Model(&models.Otp{}).
		Where("user_id = ? AND status = ?", user.UserID, "PENDING").
		Update("status", "EXPIRED")

	kodeOTP := fmt.Sprintf("%06d", rand.Intn(1000000))
	waktuExpired := time.Now().UTC().Add(3 * time.Minute)

	newOtp := models.Otp{
		UserID:    user.UserID,
		Kode:      kodeOTP,
		ExpiredAt: waktuExpired,
	}
	ac.DB.Create(&newOtp)

	go func() {
		err := services.KirimEmailOTP(req.Email, kodeOTP)
		if err != nil {
			fmt.Println("GAGAL resend email ke:", req.Email, "Error:", err)
		} else {
			fmt.Println("SUKSES resend email OTP ke:", req.Email)
		}
	}()

	c.JSON(http.StatusOK, gin.H{
		"message": "A new OTP has been successfully sent. Please check your email.",
	})
}
// FITUR LOGOUT
func (ac *AuthController) LogoutUser(c *gin.Context) {
	// Ambil token dari Header (Sama seperti cara middleware)
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Token tidak ditemukan"})
		return
	}

	tokenString := strings.Replace(authHeader, "Bearer ", "", 1)

	// UBAH STATUS TOKEN MENJADI "REVOKED" (Dicabut secara paksa oleh user)
	result := ac.DB.Model(&models.AuthSession{}).
		Where("token = ?", tokenString).
		Update("status", "REVOKED")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal melakukan logout"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Berhasil logout. Sesi Anda telah diakhiri.",
	})
}
func (ac *AuthController) SetUserPin(c *gin.Context) {
	// 1. Ambil ID User dari Satpam JWT
	userIDContext, _ := c.Get("userID")
	userID := userIDContext.(uint)

	// 2. Tangkap PIN dari Flutter
	var req SetPinReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "PIN harus terdiri dari 6 digit angka."})
		return
	}

	// 3. Enkripsi (Hash) PIN menggunakan bcrypt agar aman
	hashedPin, err := bcrypt.GenerateFromPassword([]byte(req.Pin), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengamankan PIN"})
		return
	}

	// 4. Simpan ke Database
	if err := ac.DB.Model(&models.User{}).Where("user_id = ?", userID).Update("pin", string(hashedPin)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan PIN ke database"})
		return
	}

	// 5. Beri balasan sukses
	c.JSON(http.StatusOK, gin.H{
		"message": "PIN keamanan berhasil dibuat! Anda sekarang bisa melakukan transaksi.",
	})
}

func (ac *AuthController) RequestForgotPassword(c *gin.Context) {
	var req ForgotPasswordReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nomor HP wajib diisi."})
		return
	}

	// Cek apakah nomor HP terdaftar
	var user models.User
	if err := ac.DB.Where("phone_number = ?", req.PhoneNumber).First(&user).Error; err != nil {
		// Trik Keamanan: Jangan beritahu hacker apakah nomor ini terdaftar atau tidak.
		// Tetap beri pesan sukses seolah-olah OTP dikirim.
		c.JSON(http.StatusOK, gin.H{"message": "Jika nomor terdaftar, OTP instruksi reset password telah dikirim."})
		return
	}

	// Generate OTP (Contoh statis "1234" untuk testing, di dunia nyata gunakan math/rand)
	kodeOTP := fmt.Sprintf("%06d", rand.Intn(1000000))
	waktuExpired := time.Now().UTC().Add(3 * time.Minute)

	newOtp := models.Otp{
		UserID:    user.UserID,
		Kode:      kodeOTP,
		ExpiredAt: waktuExpired,
	}
	ac.DB.Create(&newOtp)

	err := services.KirimEmailOTP(user.Email, kodeOTP)
	if err != nil {
		fmt.Println("[ERROR] Gagal mengirim email:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengirim OTP ke email Anda."})
		return
	}

	fmt.Printf("[SYSTEM] Sukses mengirim OTP Lupa Password %s ke email %s\n", kodeOTP, user.Email)

	c.JSON(http.StatusOK, gin.H{
		"message": "Jika nomor terdaftar, OTP instruksi reset password telah dikirim.",
	})
}

func (ac *AuthController) ResetPassword(c *gin.Context) {
	var req ResetPasswordReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak lengkap. Pastikan Nomor HP, OTP, dan Password Baru diisi."})
		return
	}

	// Cari User
	var user models.User
	if err := ac.DB.Where("phone_number = ?", req.PhoneNumber).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak valid."})
		return
	}

	// Cek OTP apakah valid dan masih ACTIVE
	var otpData models.Otp
	if err := ac.DB.Where("user_id = ? AND kode = ? AND status = ?", user.UserID, req.OTP, "PENDING").First(&otpData).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "OTP salah atau sudah kedaluwarsa."})
		return
	}

	// Hash Password Baru
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengamankan password baru."})
		return
	}

	// Update Password User & Matikan OTP (Ubah jadi EXPIRED/USED)
	tx := ac.DB.Begin()
	
	if err := tx.Model(&user).Update("password", string(hashedPassword)).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengubah password."})
		return
	}

	if err := tx.Model(&otpData).Update("status", "USED").Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses OTP."})
		return
	}

	tx.Commit()

	c.JSON(http.StatusOK, gin.H{
		"message": "Password berhasil diubah! Silakan login dengan password baru Anda.",
	})
}