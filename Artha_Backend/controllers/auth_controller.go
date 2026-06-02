package controllers

import (
	"errors"
	"fmt"
	"math/rand"
	"net/http"
	"regexp"
	"strings"
	"time"

	"artha/models"
	"artha/services"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var jwtKey = []byte("artha_secret_key_2026")

type ForgotPasswordReq struct {
	Email string `json:"email" binding:"required,email"`
}
type ResetPasswordReq struct {
	Email       string `json:"email" binding:"required,email"`
	OTP         string `json:"otp" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}
type AuthController struct {
	DB *gorm.DB
}
type RegisterRequest struct {
	Nama     string `json:"nama" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	PhoneNumber string	`json:"phone_number" binding:"required,numeric,min=10,max=13"`
	Password string `json:"password" binding:"required,min=6"`
}
type LoginRequest struct {
	PhoneNumber string	`json:"phone_number" binding:"required,numeric,min=10,max=13"`
	Password string `json:"password" binding:"required,min=6"`
}
type VerifyOTPRequest struct {
	Email string `json:"email" binding:"required,email"`
	Kode  string `json:"kode" binding:"required,len=6"`
}
type VerifyPasswordReq struct {
	Password string `json:"password" binding:"required"`
}
type ResendOTPRequest struct {
	Email string `json:"email" binding:"required,email"`
}
type SetPinReq struct {
	Pin string `json:"pin" binding:"required,len=6,numeric"`
}
// Struct untuk Request Ganti PIN
type ChangePinReq struct {
	Password      string `json:"password" binding:"required"`
	NewPin        string `json:"new_pin" binding:"required,numeric,len=6"`
	ConfirmNewPin string `json:"confirm_new_pin" binding:"required,numeric,len=6"`
}
func (ac *AuthController)RegisterUser(c *gin.Context) {
	var req RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		
		// Cek apakah errornya berasal dari tag binding (required, min, dll)
		if validationErrors, ok := err.(validator.ValidationErrors); ok {
			// Kita ambil error yang PERTAMA kali ditemukan saja
			firstError := validationErrors[0]
			
			var pesanError string
			polaNama := regexp.MustCompile(`^[a-zA-Z\s]+$`)
			// Bedah berdasarkan nama kolom (Field) dan aturannya (Tag)
			switch firstError.Field() {
			case "Nama":
				if firstError.Tag() == "required" {
					pesanError = "Nama tidak boleh kosong."
				} else if !polaNama.MatchString(req.Nama){
					pesanError = "Nama tidak valid."
				}
			case "PhoneNumber":
				if firstError.Tag() == "required" {
					pesanError = "Nomor HP wajib diisi."
				} else if firstError.Tag() == "numeric" {
					pesanError = "Nomor HP tidak valid, hanya boleh berisi angka."
				} else if firstError.Tag() == "min" || firstError.Tag() == "max" {
					pesanError = "Nomor HP harus antara 10 hingga 13 angka."
				}
			case "Password":
				if firstError.Tag() == "required" {
					pesanError = "Password tidak boleh kosong."
				} else if firstError.Tag() == "min" {
					pesanError = "Password terlalu pendek, minimal 8 karakter."
				}
			case "Email":
				if firstError.Tag() == "required" {
					pesanError = "Email tidak boleh kosong."
				} else{
					pesanError = "Email Tidak Valid"
				}
			default:
				pesanError = "Data tidak valid pada kolom " + firstError.Field()
			}
			
			// Kirim 1 pesan spesifik ke Flutter
			c.JSON(http.StatusBadRequest, gin.H{"error": pesanError})
			return
		}

		// Jika errornya karena format JSON-nya berantakan / bukan dari validator
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak sesuai."})
		return
	}

	polaNama := regexp.MustCompile(`^[a-zA-Z\s]+$`)
	if !polaNama.MatchString(req.Nama) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nama tidak valid."})
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
		
		if validationErrors, ok := err.(validator.ValidationErrors); ok {
			firstError := validationErrors[0]
			var pesanError string
			
			switch firstError.Field() {
			case "PhoneNumber":
				if firstError.Tag() == "required" {
					pesanError = "Nomor HP tidak boleh kosong."
				} else if firstError.Tag() == "numeric" {
					pesanError = "Nomor HP tidak valid."
				} else if firstError.Tag() == "min" || firstError.Tag() == "max" {
					pesanError = "Nomor HP harus antara 10 hingga 13 angka."
				}
			case "Password":
				if firstError.Tag() == "required" {
					pesanError = "Password tidak boleh kosong."
				}
			default:
				pesanError = "Data tidak valid pada " + firstError.Field()
			}
			
			c.JSON(http.StatusBadRequest, gin.H{"error": pesanError})
			return
		}

		c.JSON(http.StatusBadRequest, gin.H{"error": "Format data tidak sesuai."})
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format email tidak valid atau kosong."})
		return
	}

	// Cek apakah nomor HP terdaftar
	var user models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		// Trik Keamanan: Tetap beri pesan sukses seolah-olah OTP dikirim
		c.JSON(http.StatusOK, gin.H{"message": "Jika email terdaftar, OTP instruksi reset password telah dikirim."})
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
		"message": "Jika email terdaftar, OTP instruksi reset password telah dikirim.",
	})
}

func (ac *AuthController) ResetPassword(c *gin.Context) {
	var req ResetPasswordReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data tidak lengkap. Pastikan Email, OTP, dan Password Baru diisi dengan benar."})
		return
	}

	// Cari User
	var user models.User
	if err := ac.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
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


// ==========================================
// FITUR CEK PASSWORD (UNTUK PAGE 1 GANTI PIN)
// ==========================================
func (ac *AuthController) VerifyPassword(c *gin.Context) {
	// 1. Ambil ID User dari Satpam JWT
	userIDContext, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid."})
		return
	}
	userID := userIDContext.(uint)

	// 2. Tangkap password dari Flutter
	var req VerifyPasswordReq
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Password wajib diisi."})
		return
	}

	// 3. Cari user di database
	var user models.User
	if err := ac.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "User tidak ditemukan."})
		return
	}

	// 4. Bandingkan passwordnya
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password yang Anda masukkan salah!"})
		return
	}

	// 5. Jika benar, beri lampu hijau ke Flutter untuk pindah halaman!
	c.JSON(http.StatusOK, gin.H{
		"message": "Password benar, silakan lanjut masukkan PIN.",
	})
}
// ==========================================
// FITUR GANTI PIN KEAMANAN
// ==========================================
func (ac *AuthController) ChangePin(c *gin.Context) {
	// 1. Ambil ID User dari Satpam JWT
	userIDContext, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid, silakan login kembali."})
		return
	}
	userID := userIDContext.(uint)

	var req ChangePinReq

	// 2. Tangkap JSON dan berikan pesan error spesifik jika format salah
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pastikan semua kolom terisi dan PIN berupa 6 digit angka."})
		return
	}

	// 3. Pastikan New Pin dan Confirm New Pin SAMA PERSIS
	if req.NewPin != req.ConfirmNewPin {
		c.JSON(http.StatusBadRequest, gin.H{"error": "PIN baru dan Konfirmasi PIN tidak cocok!"})
		return
	}

	// 4. Cari data user di database berdasarkan ID dari JWT
	var user models.User
	if err := ac.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menemukan data user."})
		return
	}

	// 5. VERIFIKASI PASSWORD (Cek apakah yang pegang HP ini benar-benar pemilik asli)
	err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))
	if err != nil {
		// Jika password salah, tolak prosesnya!
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Password yang Anda masukkan salah!"})
		return
	}

	// 6. Jika Password benar, Enkripsi (Hash) PIN yang baru
	hashedNewPin, err := bcrypt.GenerateFromPassword([]byte(req.NewPin), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengamankan PIN baru."})
		return
	}

	// 7. Simpan PIN baru ke Database
	if err := ac.DB.Model(&user).Update("pin", string(hashedNewPin)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan PIN baru ke database."})
		return
	}

	// 8. Beri balasan sukses!
	c.JSON(http.StatusOK, gin.H{
		"message": "PIN Keamanan berhasil diubah!",
	})
}