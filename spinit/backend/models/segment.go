package models

import (
	"github.com/google/uuid"
)

type Segment struct {
	ID       uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	WheelID  uuid.UUID `gorm:"type:uuid" json:"wheel_id"`
	Label    string    `gorm:"size:100" json:"label"`
	Color    string    `gorm:"size:7" json:"color"`
	Position int       `json:"position"`
}
