package models

import (
	"time"

	"github.com/google/uuid"
)

type SpinLog struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey" json:"id"`
	WheelID     uuid.UUID `gorm:"type:uuid" json:"wheel_id"`
	ResultLabel string    `gorm:"size:100" json:"result_label"`
	ResultColor string    `gorm:"size:7" json:"result_color"`
	SpunAt      time.Time `json:"spun_at"`
}
