package repository

import (
	"github.com/adirathod/spinit-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SessionRepository interface {
	Create(session *models.UserSession) error
	GetByDeviceToken(token string) (*models.UserSession, error)
	GetByID(id uuid.UUID) (*models.UserSession, error)
	UpdateLastSeen(id uuid.UUID) error
}

type sessionRepository struct {
	db *gorm.DB
}

func NewSessionRepository(db *gorm.DB) SessionRepository {
	return &sessionRepository{db}
}

func (r *sessionRepository) Create(session *models.UserSession) error {
	return r.db.Create(session).Error
}

func (r *sessionRepository) GetByDeviceToken(token string) (*models.UserSession, error) {
	var session models.UserSession
	err := r.db.Where("device_token = ?", token).First(&session).Error
	if err != nil {
		return nil, err
	}
	return &session, nil
}

func (r *sessionRepository) GetByID(id uuid.UUID) (*models.UserSession, error) {
	var session models.UserSession
	err := r.db.First(&session, id).Error
	if err != nil {
		return nil, err
	}
	return &session, nil
}

func (r *sessionRepository) UpdateLastSeen(id uuid.UUID) error {
	return r.db.Model(&models.UserSession{}).Where("id = ?", id).Update("last_seen_at", gorm.Expr("NOW()")).Error
}
