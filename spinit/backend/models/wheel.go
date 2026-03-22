package models

import (
	"time"

	"github.com/google/uuid"
)

type Wheel struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	ShareCode  string    `gorm:"uniqueIndex;size:6" json:"share_code"`
	Name       string    `gorm:"size:100" json:"name"`
	SessionID  uuid.UUID `gorm:"type:uuid" json:"session_id"`
	SpinCount  int       `gorm:"default:0" json:"spin_count"`
	Segments   []Segment `gorm:"foreignKey:WheelID" json:"segments"`
	CreatedAt  time.Time `json:"created_at"`
	ExpiresAt  time.Time `json:"expires_at"`
}
