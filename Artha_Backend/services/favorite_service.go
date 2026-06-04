package services

import (
	"artha/models"
	"artha/repositories"

	"github.com/google/uuid"
)

type CreateFavoriteRequest struct {
	RecipientPhone string `json:"recipient_phone" binding:"required,numeric,min=10,max=13"`
	Label          string `json:"label" binding:"required"`
}

type FavoriteResponse struct {
	ID              string `json:"id"`
	RecipientUserID uint   `json:"recipient_user_id"`
	RecipientPhone  string `json:"recipient_phone"`
	RecipientName   string `json:"recipient_name"`
	Label           string `json:"label"`
	CreatedAt       string `json:"created_at"`
	UpdatedAt       string `json:"updated_at"`
}

type FavoriteService struct {
	repo *repositories.FavoriteRepository
}

func NewFavoriteService(repo *repositories.FavoriteRepository) *FavoriteService {
	return &FavoriteService{repo: repo}
}

func (s *FavoriteService) AddFavorite(userID uint, req CreateFavoriteRequest) (FavoriteResponse, error) {
	recipient, err := s.repo.FindUserByPhone(req.RecipientPhone)
	if err != nil {
		return FavoriteResponse{}, err
	}

	favorite := models.FavoriteAccount{
		ID:              uuid.NewString(),
		UserID:          userID,
		RecipientUserID: recipient.UserID,
		RecipientPhone:  req.RecipientPhone,
		RecipientName:   recipient.Nama,
		Label:           req.Label,
	}

	if err := s.repo.Create(&favorite); err != nil {
		return FavoriteResponse{}, err
	}

	return FavoriteResponse{
		ID:              favorite.ID,
		RecipientUserID: favorite.RecipientUserID,
		RecipientPhone:  favorite.RecipientPhone,
		RecipientName:   favorite.RecipientName,
		Label:           favorite.Label,
		CreatedAt:       favorite.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		UpdatedAt:       favorite.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	}, nil
}

func (s *FavoriteService) ListFavorites(userID uint) ([]FavoriteResponse, error) {
	favorites, err := s.repo.FindAllByUserID(userID)
	if err != nil {
		return nil, err
	}

	var response []FavoriteResponse
	for _, favorite := range favorites {
		response = append(response, FavoriteResponse{
			ID:              favorite.ID,
			RecipientUserID: favorite.RecipientUserID,
			RecipientPhone:  favorite.RecipientPhone,
			RecipientName:   favorite.RecipientName,
			Label:           favorite.Label,
			CreatedAt:       favorite.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
			UpdatedAt:       favorite.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
		})
	}
	return response, nil
}

func (s *FavoriteService) DeleteFavorite(userID uint, favoriteID string) error {
	return s.repo.DeleteByIDAndUserID(favoriteID, userID)
}
