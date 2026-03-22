package middleware

import (
	"strings"

	"github.com/adirathod/spinit-backend/repository"
	"github.com/adirathod/spinit-backend/utils"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

func AuthMiddleware(jwtSecret string, sessionRepo repository.SessionRepository) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Missing authorization header")
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Invalid authorization format")
		}

		tokenString := parts[1]
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(jwtSecret), nil
		})

		if err != nil || !token.Valid {
			log.Error().Err(err).Msg("JWT validation failed")
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Invalid or expired token")
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Invalid token claims")
		}

		sessionIDStr := claims["session_id"].(string)
		sessionID, err := uuid.Parse(sessionIDStr)
		if err != nil {
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Invalid session ID in token")
		}

		// Verify session exists in DB
		_, err = sessionRepo.GetByID(sessionID)
		if err != nil {
			log.Error().Err(err).Str("session_id", sessionIDStr).Msg("Session not found in DB")
			return utils.ErrorResponse(c, fiber.StatusUnauthorized, "Session expired or invalid")
		}

		c.Locals("session_id", sessionIDStr)

		return c.Next()
	}
}
