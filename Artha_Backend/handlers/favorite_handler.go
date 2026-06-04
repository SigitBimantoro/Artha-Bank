package handlers

import (
	"errors"
	"net/http"

	"artha/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type FavoriteHandler struct {
	service *services.FavoriteService
}

func NewFavoriteHandler(service *services.FavoriteService) *FavoriteHandler {
	return &FavoriteHandler{service: service}
}

func (h *FavoriteHandler) CreateFavorite(c *gin.Context) {
	userIDContext, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid."})
		return
	}
	userID := userIDContext.(uint)

	var req services.CreateFavoriteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Semua field favorit harus diisi dengan benar."})
		return
	}

	result, err := h.service.AddFavorite(userID, req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan rekening favorit."})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": result})
}

func (h *FavoriteHandler) ListFavorites(c *gin.Context) {
	userIDContext, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid."})
		return
	}
	userID := userIDContext.(uint)

	favorites, err := h.service.ListFavorites(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil daftar favorit."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": favorites})
}

func (h *FavoriteHandler) DeleteFavorite(c *gin.Context) {
	userIDContext, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Sesi tidak valid."})
		return
	}
	userID := userIDContext.(uint)

	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID favorit tidak boleh kosong."})
		return
	}

	if err := h.service.DeleteFavorite(userID, id); err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Rekening favorit tidak ditemukan."})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus rekening favorit."})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Rekening favorit berhasil dihapus."})
}
