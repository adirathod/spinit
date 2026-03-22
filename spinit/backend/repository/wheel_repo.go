package repository

import (
	"github.com/adirathod/spinit-backend/models"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type WheelRepository interface {
	Create(wheel *models.Wheel) error
	GetByCode(code string) (*models.Wheel, error)
	GetBySessionID(sessionID uuid.UUID) ([]models.Wheel, error)
	Delete(code string, sessionID uuid.UUID) error
	IncrementSpinCount(code string) error
	LogSpin(log *models.SpinLog) error
	CleanupExpired() (int64, error)
}

type wheelRepository struct {
	db *gorm.DB
}

func NewWheelRepository(db *gorm.DB) WheelRepository {
	return &wheelRepository{db}
}

func (r *wheelRepository) Create(wheel *models.Wheel) error {
	return r.db.Create(wheel).Error
}

func (r *wheelRepository) GetByCode(code string) (*models.Wheel, error) {
	var wheel models.Wheel
	err := r.db.Preload("Segments").Where("share_code = ? AND expires_at > NOW()", code).First(&wheel).Error
	if err != nil {
		return nil, err
	}
	return &wheel, nil
}

func (r *wheelRepository) GetBySessionID(sessionID uuid.UUID) ([]models.Wheel, error) {
	var wheels []models.Wheel
	err := r.db.Where("session_id = ?", sessionID).Order("created_at DESC").Find(&wheels).Error
	return wheels, err
}

func (r *wheelRepository) Delete(code string, sessionID uuid.UUID) error {
	return r.db.Where("share_code = ? AND session_id = ?", code, sessionID).Delete(&models.Wheel{}).Error
}

func (r *wheelRepository) IncrementSpinCount(code string) error {
	return r.db.Model(&models.Wheel{}).Where("share_code = ?", code).Update("spin_count", gorm.Expr("spin_count + 1")).Error
}

func (r *wheelRepository) LogSpin(log *models.SpinLog) error {
	return r.db.Create(log).Error
}

func (r *wheelRepository) CleanupExpired() (int64, error) {
	result := r.db.Where("expires_at < NOW()").Delete(&models.Wheel{})
	return result.RowsAffected, result.Error
}
