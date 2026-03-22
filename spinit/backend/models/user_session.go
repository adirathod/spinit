package models

import (
	"time"

	"github.com/google/uuid"
)

type UserSession struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	DeviceToken string    `gorm:"uniqueIndex;size:255" json:"device_token"`
	CreatedAt   time.Time `json:"created_at"`
	LastSeenAt  time.Time `json:"last_seen_at"`
}
