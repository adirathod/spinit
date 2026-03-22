package services

import (
	"time"

	"github.com/adirathod/spinit-backend/models"
	"github.com/adirathod/spinit-backend/repository"
	"github.com/adirathod/spinit-backend/utils"
	"github.com/google/uuid"
)

type WheelService struct {
	repo repository.WheelRepository
}

func NewWheelService(repo repository.WheelRepository) *WheelService {
	return &WheelService{repo}
}

func (s *WheelService) CreateWheel(name string, sessionID uuid.UUID, segments []models.Segment) (*models.Wheel, error) {
	shareCode := utils.GenerateShareCode()
	// Retry logic (simplified, in a real app we'd check if code exists)
	for i := 0; i < 5; i++ {
		_, err := s.repo.GetByCode(shareCode)
		if err != nil {
			// If error is not found, we're good
			break
		}
		shareCode = utils.GenerateShareCode()
	}

	wheel := &models.Wheel{
		ID:        uuid.New(),
		ShareCode: shareCode,
		Name:      name,
		SessionID: sessionID,
		CreatedAt: time.Now(),
		ExpiresAt: time.Now().Add(time.Hour * 24 * 30), // 30 days
	}

	for i := range segments {
		segments[i].ID = uuid.New()
		segments[i].WheelID = wheel.ID
	}
	wheel.Segments = segments

	if err := s.repo.Create(wheel); err != nil {
		return nil, err
	}

	return wheel, nil
}

func (s *WheelService) GetWheel(code string) (*models.Wheel, error) {
	return s.repo.GetByCode(code)
}

func (s *WheelService) GetMyWheels(sessionID uuid.UUID) ([]models.Wheel, error) {
	return s.repo.GetBySessionID(sessionID)
}

func (s *WheelService) DeleteWheel(code string, sessionID uuid.UUID) error {
	return s.repo.Delete(code, sessionID)
}

func (s *WheelService) LogSpin(code string, label, color string) error {
	wheel, err := s.repo.GetByCode(code)
	if err != nil {
		return err
	}

	_ = s.repo.IncrementSpinCount(code)

	log := &models.SpinLog{
		ID:          uuid.New(),
		WheelID:     wheel.ID,
		ResultLabel: label,
		ResultColor: color,
		SpunAt:      time.Now(),
	}
	return s.repo.LogSpin(log)
}
