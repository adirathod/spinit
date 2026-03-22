package config

import (
	"fmt"

	"github.com/adirathod/spinit-backend/models"
	"github.com/rs/zerolog/log"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase(cfg *Config) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=%s",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort, cfg.DBSSLMode)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to connect to database")
	}

	log.Info().Msg("Connected to PostgreSQL database")

	// Auto-migrate models
	err = db.AutoMigrate(&models.UserSession{}, &models.Wheel{}, &models.Segment{}, &models.SpinLog{})
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to run database migrations")
	}

	DB = db
}
