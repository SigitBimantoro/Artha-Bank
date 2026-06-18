package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"artha/models" // Pastikan path ini sesuai dengan project Anda

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

// ==========================================
// 1. FUNGSI HELPER UNTUK SETUP TESTING
// ==========================================

// setupTestDB membuat database SQLite di RAM (sementara) agar DB asli aman
func setupTestDB() *gorm.DB {
	// Menghapus "?cache=shared" agar setiap fungsi test mendapat database yang benar-benar baru
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	db.AutoMigrate(&models.User{}, &models.Wallet{}, &models.Transaction{})
	return db
}

// setupRouter membuat simulasi server Gin dan menyuntikkan UserID (Mocking JWT Middleware)
func setupRouter(db *gorm.DB, mockUserID uint) (*gin.Engine, *TransactionController) {
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	tc := &TransactionController{DB: db}

	// Middleware buatan untuk memalsukan proses JWT (selalu set userID dari parameter)
	router.Use(func(c *gin.Context) {
		c.Set("userID", mockUserID)
		c.Next()
	})

	return router, tc
}

// ==========================================
// 2. PENGUJIAN FUNGSI UTILITIES (PURE FUNCTION)
// ==========================================

func TestGenerateTokenPLN(t *testing.T) {
	token := generateTokenPLN()
	if len(token) != 24 {
		t.Errorf("Panjang token salah, dapat: %d", len(token))
	}
	if len(strings.Split(token, " ")) != 5 {
		t.Errorf("Format spasi token salah")
	}
}

// ==========================================
// 3. PENGUJIAN API CONTROLLERS
// ==========================================

func TestTopUpInternal(t *testing.T) {
	db := setupTestDB()
	// Siapkan data awal: Dompet user 1 punya saldo 0
	db.Create(&models.Wallet{UserID: 1, Saldo: 0})

	router, tc := setupRouter(db, 1) // Login sebagai User 1
	router.POST("/topup", tc.TopUpInternal)

	// Buat Request Body
	reqBody := TopUpReq{Amount: 50000, Metode: "Indomaret"}
	jsonValue, _ := json.Marshal(reqBody)

	// Tembak API Mock
	req, _ := http.NewRequest("POST", "/topup", bytes.NewBuffer(jsonValue))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Validasi Hasil
	if w.Code != http.StatusOK {
		t.Errorf("Diharapkan status 200 OK, tapi dapat %d", w.Code)
	}

	// Cek apakah saldo benar-benar bertambah di DB sementara
	var wallet models.Wallet
	db.First(&wallet, "user_id = ?", 1)
	if wallet.Saldo != 50000 {
		t.Errorf("Diharapkan saldo 50000, tapi aktualnya %v", wallet.Saldo)
	}
}

func TestBeliPulsa(t *testing.T) {
	db := setupTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 50000}) // Saldo awal

	router, tc := setupRouter(db, 1)
	router.POST("/pulsa", tc.BeliPulsa)

	reqBody := PulsaReq{PhoneNumber: "081299998888", Amount: 20000}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/pulsa", bytes.NewBuffer(jsonValue))
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Diharapkan status 200 OK, dapat %d", w.Code)
	}
}

func TestTransferUang(t *testing.T) {
	db := setupTestDB()
	db.Create(&models.User{UserID: 2, PhoneNumber: "08123456789", Nama: "Penerima"})
	db.Create(&models.Wallet{UserID: 1, Saldo: 100000}) 
	db.Create(&models.Wallet{UserID: 2, Saldo: 0})      

	router, tc := setupRouter(db, 1) 
	router.POST("/transfer", tc.TransferUang)

	reqBody := TransferReq{ReceiverPhone: "08123456789", Amount: 30000, Notes: "Bayar utang"}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/transfer", bytes.NewBuffer(jsonValue))
	// WAJIB DITAMBAHKAN AGAR GIN MENGENALI JSON-NYA
	req.Header.Set("Content-Type", "application/json") 
    
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d. Alasan: %s", w.Code, w.Body.String())
	}
}


func TestBeliTokenListrik(t *testing.T) {
	db := setupTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 150000})

	router, tc := setupRouter(db, 1)
	router.POST("/pln", tc.BeliTokenListrik)

	reqBody := PLNReq{MeterNumber: "12345678901", Amount: 100000}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/pln", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json") // WAJIB DITAMBAHKAN

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d. Alasan: %s", w.Code, w.Body.String())
	}
}

func TestBayarQRIS(t *testing.T) {
	db := setupTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 100000})

	router, tc := setupRouter(db, 1)
	router.POST("/qris", tc.BayarQRIS)

	reqBody := QRISReq{MerchantName: "Kopi Kenangan", Amount: 25000, Payload: "QRIS_DATA"}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/qris", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json") // WAJIB DITAMBAHKAN

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d. Alasan: %s", w.Code, w.Body.String())
	}
}