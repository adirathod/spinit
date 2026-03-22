package services

import (
	"time"

	"github.com/adirathod/spinit-backend/models"
	"github.com/adirathod/spinit-backend/repository"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type SessionService struct {
	repo      repository.SessionRepository
	jwtSecret string
	expiry    int
}

func NewSessionService(repo repository.SessionRepository, jwtSecret string, expiry int) *SessionService {
	return &SessionService{repo, jwtSecret, expiry}
}

func (s *SessionService) GetOrCreateSession(deviceToken string) (string, string, error) {
	session, err := s.repo.GetByDeviceToken(deviceToken)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			// Create new session
			session = &models.UserSession{
				ID:          uuid.New(),
				DeviceToken: deviceToken,
				CreatedAt:   time.Now(),
				LastSeenAt:  time.Now(),
			}
			if err := s.repo.Create(session); err != nil {
				return "", "", err
			}
		} else {
			return "", "", err
		}
	} else {
		// Update last seen
		_ = s.repo.UpdateLastSeen(session.ID)
	}

	// Generate JWT
	tokenString, err := s.generateJWT(session.ID)
	return session.ID.String(), tokenString, err
}

func (s *SessionService) generateJWT(sessionID uuid.UUID) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"session_id": sessionID.String(),
		"exp":        time.Now().Add(time.Hour * 24 * time.Duration(s.expiry)).Unix(),
	})

	return token.SignedString([]byte(s.jwtSecret))
}
