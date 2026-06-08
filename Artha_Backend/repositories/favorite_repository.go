package repositories

import (
	"artha/models"

	"gorm.io/gorm"
)

type FavoriteRepository struct {
	db *gorm.DB
}

func NewFavoriteRepository(db *gorm.DB) *FavoriteRepository {
	return &FavoriteRepository{db: db}
}

func (r *FavoriteRepository) Create(favorite *models.FavoriteAccount) error {
	if favorite.BankName == "" {
		favorite.BankName = "Artha Bank"
	}
	if favorite.AccountNumber == "" {
		favorite.AccountNumber = favorite.RecipientPhone
	}
	if favorite.AccountName == "" {
		favorite.AccountName = favorite.RecipientName
	} // Tambahkan ini

	return r.db.Create(favorite).Error
}

func (r *FavoriteRepository) FindAllByUserID(userID uint) ([]models.FavoriteAccount, error) {
	var favorites []models.FavoriteAccount
	if err := r.db.Where("user_id = ?", userID).Order("created_at DESC").Find(&favorites).Error; err != nil {
		return nil, err
	}
	return favorites, nil
}

func (r *FavoriteRepository) FindUserByPhone(phone string) (*models.User, error) {
	var user models.User
	if err := r.db.Where("phone_number = ?", phone).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *FavoriteRepository) DeleteByIDAndUserID(id string, userID uint) error {
	result := r.db.Where("id = ? AND user_id = ?", id, userID).Delete(&models.FavoriteAccount{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}
	return nil
}
