package handlers

import (
	"time"

	"github.com/adirathod/spinit-backend/utils"
	"github.com/gofiber/fiber/v2"
)

var startTime = time.Now()

func HealthCheck(c *fiber.Ctx) error {
	return utils.SuccessResponse(c, fiber.Map{
		"status":  "ok",
		"db":      "connected",
		"version": "1.0.0",
		"uptime":  time.Since(startTime).String(),
	})
}
