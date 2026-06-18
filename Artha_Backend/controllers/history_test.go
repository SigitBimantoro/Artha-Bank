package controllers

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"artha/models"

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

// ==========================================
// FUNGSI HELPER UNTUK SETUP TESTING HISTORY
// ==========================================

func setupHistoryTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	db.AutoMigrate(&models.User{}, &models.Transaction{})
	return db
}

func setupHistoryRouter(db *gorm.DB, mockUserID uint) (*gin.Engine, *HistoryController) {
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	hc := &HistoryController{DB: db}

	// Middleware Satpam JWT Palsu
	router.Use(func(c *gin.Context) {
		c.Set("userID", mockUserID)
		c.Next()
	})

	return router, hc
}

// ==========================================
// PENGUJIAN API CONTROLLERS - HISTORY
// ==========================================

func TestGetRiwayatTransaksi(t *testing.T) {
	db := setupHistoryTestDB()
	// Insert data transaksi dummy (Campuran Masuk & Keluar)
	db.Create(&models.Transaction{TransactionType: "TOPUP", SenderID: 1, ReceiverID: 1, Amount: 50000, CreatedAt: time.Now()})
	db.Create(&models.Transaction{TransactionType: "PULSA", SenderID: 1, ReceiverID: 1, Amount: 20000, CreatedAt: time.Now()})
	db.Create(&models.Transaction{TransactionType: "TRANSFER", SenderID: 1, ReceiverID: 2, Amount: 10000, CreatedAt: time.Now()})

	router, hc := setupHistoryRouter(db, 1) // Login sebagai User 1
	router.GET("/history", hc.GetRiwayatTransaksi)

	// Skenario 1: Ambil semua tanpa limit
	req, _ := http.NewRequest("GET", "/history", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}

	// Skenario 2: Ambil dengan limit 2
	reqLimit, _ := http.NewRequest("GET", "/history?limit=2", nil)
	wLimit := httptest.NewRecorder()
	router.ServeHTTP(wLimit, reqLimit)

	if wLimit.Code != http.StatusOK {
		t.Errorf("GAGAL limit! Diharapkan 200 OK, tapi dapat %d", wLimit.Code)
	}
}

func TestGetTrackingKeuangan(t *testing.T) {
	db := setupHistoryTestDB()
	// Data untuk test pie chart & bar chart (dibuat waktu 'Now' agar masuk filter chart)
	db.Create(&models.Transaction{TransactionType: "TOPUP", SenderID: 1, ReceiverID: 1, Amount: 100000, CreatedAt: time.Now()})
	db.Create(&models.Transaction{TransactionType: "PLN", SenderID: 1, ReceiverID: 1, Amount: 50000, CreatedAt: time.Now()})

	router, hc := setupHistoryRouter(db, 1)
	router.GET("/tracking", hc.GetTrackingKeuangan)

	// Test periode default (weekly)
	req, _ := http.NewRequest("GET", "/tracking", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestExportTrackingKeuanganPDF(t *testing.T) {
	db := setupHistoryTestDB()
	// Data minimum agar PDF tidak kosong
	db.Create(&models.Transaction{TransactionType: "TOPUP", SenderID: 1, ReceiverID: 1, Amount: 150000, CreatedAt: time.Now()})

	router, hc := setupHistoryRouter(db, 1)
	router.GET("/tracking/pdf", hc.ExportTrackingKeuanganPDF)

	req, _ := http.NewRequest("GET", "/tracking/pdf?period=monthly", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d. Response: %s", w.Code, w.Body.String())
	}

	// Validasi apakah file yang dikembalikan benar-benar berformat PDF
	contentType := w.Header().Get("Content-Type")
	if contentType != "application/pdf" {
		t.Errorf("Format salah! Diharapkan 'application/pdf', tapi dapat '%s'", contentType)
	}
}

func TestGetRiwayatTransferKeluar(t *testing.T) {
	db := setupHistoryTestDB()
	// Buat data User (Penerima)
	db.Create(&models.User{UserID: 2, Nama: "Budi", PhoneNumber: "08122222"})
	db.Create(&models.User{UserID: 3, Nama: "Andi", PhoneNumber: "08133333"})

	// Buat data Transaksi Transfer
	db.Create(&models.Transaction{TransactionType: "TRANSFER", SenderID: 1, ReceiverID: 2, Amount: 50000, CreatedAt: time.Now().Add(-2 * time.Hour)})
	db.Create(&models.Transaction{TransactionType: "TRANSFER", SenderID: 1, ReceiverID: 3, Amount: 20000, CreatedAt: time.Now().Add(-1 * time.Hour)})

	router, hc := setupHistoryRouter(db, 1)
	router.GET("/transfer-history", hc.GetRiwayatTransferKeluar)

	req, _ := http.NewRequest("GET", "/transfer-history", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}