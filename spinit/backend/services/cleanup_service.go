package services

import (
	"time"

	"github.com/adirathod/spinit-backend/repository"
	"github.com/rs/zerolog/log"
)

func StartCleanupJob(repo repository.WheelRepository) {
	ticker := time.NewTicker(24 * time.Hour)
	go func() {
		log.Info().Msg("Background cleanup job started")
		for range ticker.C {
			count, err := repo.CleanupExpired()
			if err != nil {
				log.Error().Err(err).Msg("Failed to cleanup expired wheels")
			} else if count > 0 {
				log.Info().Int64("count", count).Msg("Cleaned up expired wheels")
			}
		}
	}()
}
