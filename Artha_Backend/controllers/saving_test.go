package controllers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"artha/models"

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

// ==========================================
// FUNGSI HELPER UNTUK SETUP TESTING SAVING
// ==========================================

func setupSavingTestDB() *gorm.DB {
	db, _ := gorm.Open(sqlite.Open(":memory:"), &gorm.Config{})
	// Migrasi tabel tambahan models.Saving
	db.AutoMigrate(&models.User{}, &models.Wallet{}, &models.Transaction{}, &models.Saving{})
	return db
}

func setupSavingRouter(db *gorm.DB, mockUserID uint) (*gin.Engine, *SavingController) {
	gin.SetMode(gin.TestMode)
	router := gin.Default()
	sc := &SavingController{DB: db}

	router.Use(func(c *gin.Context) {
		c.Set("userID", mockUserID)
		c.Next()
	})

	return router, sc
}

// ==========================================
// PENGUJIAN API CONTROLLERS - SAVING
// ==========================================

func TestGetSavings(t *testing.T) {
	db := setupSavingTestDB()
	// Buat 2 tabungan dummy untuk User 1
	db.Create(&models.Saving{UserID: 1, NamaTarget: "Beli Laptop", TargetNominal: 15000000})
	db.Create(&models.Saving{UserID: 1, NamaTarget: "Liburan", TargetNominal: 5000000})

	router, sc := setupSavingRouter(db, 1)
	router.GET("/savings", sc.GetSavings)

	req, _ := http.NewRequest("GET", "/savings", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestCreateSaving(t *testing.T) {
	db := setupSavingTestDB()
	router, sc := setupSavingRouter(db, 1)
	router.POST("/savings", sc.CreateSaving)

	reqBody := CreateSavingReq{
		NamaTarget:       "Dana Darurat",
		TargetNominal:    10000000,
		AutoDebitNominal: 50000,
		AutoDebitPeriode: "BULANAN",
	}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/savings", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d. Alasan: %s", w.Code, w.Body.String())
	}
}

func TestUpdateSaving(t *testing.T) {
	db := setupSavingTestDB()
	// Insert data awal dengan ID 1
	db.Create(&models.Saving{UserID: 1, NamaTarget: "Target Lama", TargetNominal: 5000000})

	router, sc := setupSavingRouter(db, 1)
	router.PUT("/savings/:id", sc.UpdateSaving)

	reqBody := UpdateSavingReq{NamaTarget: "Target Baru Diubah", TargetNominal: 8000000}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("PUT", "/savings/1", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestUpdateAutoDebit(t *testing.T) {
	db := setupSavingTestDB()
	db.Create(&models.Saving{UserID: 1, AutoDebitNominal: 0, AutoDebitPeriode: "NONE"})

	router, sc := setupSavingRouter(db, 1)
	router.PUT("/savings/:id/autodebit", sc.UpdateAutoDebit)

	reqBody := UpdateAutoDebitReq{AutoDebitNominal: 10000, AutoDebitPeriode: "MINGGUAN"}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("PUT", "/savings/1/autodebit", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestAddSaldo(t *testing.T) {
	db := setupSavingTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 100000}) // Dompet Utama
	db.Create(&models.Saving{UserID: 1, SaldoTerkumpul: 0}) // Tabungan awal

	router, sc := setupSavingRouter(db, 1)
	router.POST("/savings/:id/add", sc.AddSaldo)

	reqBody := TransaksiSavingReq{Amount: 50000}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/savings/1/add", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}
}

func TestTarikSaldo(t *testing.T) {
	db := setupSavingTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 50000}) // Dompet Utama
	db.Create(&models.Saving{UserID: 1, SaldoTerkumpul: 200000}) // Ada uang di tabungan

	router, sc := setupSavingRouter(db, 1)
	router.POST("/savings/:id/tarik", sc.TarikSaldo)

	// Tarik 100.000 ke dompet utama
	reqBody := TransaksiSavingReq{Amount: 100000}
	jsonValue, _ := json.Marshal(reqBody)

	req, _ := http.NewRequest("POST", "/savings/1/tarik", bytes.NewBuffer(jsonValue))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}

	// Verifikasi apakah saldo dompet benar-benar bertambah jadi 150.000
	var wallet models.Wallet
	db.First(&wallet, "user_id = ?", 1)
	if wallet.Saldo != 150000 {
		t.Errorf("Saldo dompet harusnya 150000, tapi %v", wallet.Saldo)
	}
}

func TestDeleteSaving(t *testing.T) {
	db := setupSavingTestDB()
	db.Create(&models.Wallet{UserID: 1, Saldo: 10000})
	db.Create(&models.Saving{UserID: 1, SaldoTerkumpul: 50000}) // Punya saldo 50rb

	router, sc := setupSavingRouter(db, 1)
	router.DELETE("/savings/:id", sc.DeleteSaving)

	req, _ := http.NewRequest("DELETE", "/savings/1", nil)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("GAGAL! Diharapkan 200 OK, tapi dapat %d", w.Code)
	}

	// Pastikan uang 50rb kembali ke Dompet sehingga Dompet jadi 60rb
	var wallet models.Wallet
	db.First(&wallet, "user_id = ?", 1)
	if wallet.Saldo != 60000 {
		t.Errorf("Uang tidak kembali penuh ke dompet, saldo aktual: %v", wallet.Saldo)
	}
}