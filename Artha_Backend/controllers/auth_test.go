package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"artha/models"

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// ==========================================
// FUNGSI HELPER UNTUK SETUP TESTING AUTH
// ==========================================

func setupAuthTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	db.AutoMigrate(&models.User{}, &models.Wallet{}, &models.Otp{}, &models.AuthSession{})
	return db
}

func setupAuthRouter(db *gorm.DB, mockUserID uint) (*gin.Engine, *AuthController) {
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	ac := &AuthController{DB: db}

	// Middleware Satpam JWT Palsu (Khusus rute yang butuh login)
	router.Use(func(c *gin.Context) {
		if mockUserID > 0 {
			c.Set("userID", mockUserID)
		}
		c.Next()
	})

	return router, ac
}

func hashPasswordTest(password string) string {
	hashed, _ := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(hashed)
}

// ==========================================
// PENGUJIAN API CONTROLLERS - AUTH
// ==========================================

func TestRegisterUser(t *testing.T) {
	db := setupAuthTestDB()
	router, ac := setupAuthRouter(db, 0) // Tidak butuh login
	router.POST("/register", ac.RegisterUser)

	reqBody := RegisterRequest{
		Nama:        "Pengguna Baru",
		Email:       "baru@artha.com",
		PhoneNumber: "081234567890",
		Password:    "rahasia123",
	}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/register", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusCreated {
		t.Errorf("GAGAL! Diharapkan 201 Created, tapi dapat %d", w.Code)
	}
}

func TestVerifyOTP(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{UserID: 1, Email: "test@artha.com", IsVerified: false})
	db.Create(&models.Otp{UserID: 1, Kode: "123456", Status: "PENDING", ExpiredAt: time.Now().Add(5 * time.Minute)})

	router, ac := setupAuthRouter(db, 0)
	router.POST("/verify-otp", ac.VerifyOTP)

	reqBody := VerifyOTPRequest{Email: "test@artha.com", Kode: "123456"}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/verify-otp", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestLoginUser(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{
		UserID:      1,
		PhoneNumber: "081234567890",
		Password:    hashPasswordTest("rahasia123"),
		IsVerified:  true,
	})

	router, ac := setupAuthRouter(db, 0)
	router.POST("/login", ac.LoginUser)

	reqBody := LoginRequest{PhoneNumber: "081234567890", Password: "rahasia123"}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/login", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestSetUserPin(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{UserID: 1, Pin: ""})

	router, ac := setupAuthRouter(db, 1) // Login sebagai User 1
	router.POST("/set-pin", ac.SetUserPin)

	reqBody := SetPinReq{Pin: "123456"}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/set-pin", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestGetProfile(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{UserID: 1, Nama: "Artha User", Email: "user@artha.com", PhoneNumber: "0811111111"})
	db.Create(&models.Wallet{UserID: 1, Saldo: 150000})

	router, ac := setupAuthRouter(db, 1)
	router.GET("/profile", ac.GetProfile)

	req, _ := http.NewRequest("GET", "/profile", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestResetPassword(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{UserID: 1, Email: "lupa@artha.com"})
	db.Create(&models.Otp{UserID: 1, Kode: "654321", Status: "PENDING", ExpiredAt: time.Now().Add(5 * time.Minute)})

	router, ac := setupAuthRouter(db, 0)
	router.POST("/reset-password", ac.ResetPassword)

	reqBody := ResetPasswordReq{Email: "lupa@artha.com", OTP: "654321", NewPassword: "passwordbaru"}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/reset-password", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestChangePassword(t *testing.T) {
	db := setupAuthTestDB()
	db.Create(&models.User{UserID: 1, Password: hashPasswordTest("sandilama")})

	router, ac := setupAuthRouter(db, 1)
	router.POST("/change-password", ac.ChangePassword)

	reqBody := ChangePasswordReq{CurrentPassword: "sandilama", NewPassword: "sandibaru123", ConfirmNewPassword: "sandibaru123"}
	jsonValue, _ := json.Marshal(reqBody)
	req, _ := http.NewRequest("POST", "/change-password", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}