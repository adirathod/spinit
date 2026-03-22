package handlers

import (
	"github.com/adirathod/spinit-backend/services"
	"github.com/adirathod/spinit-backend/utils"
	"github.com/gofiber/fiber/v2"
)

type SessionHandler struct {
	service *services.SessionService
}

func NewSessionHandler(service *services.SessionService) *SessionHandler {
	return &SessionHandler{service}
}

func (h *SessionHandler) CreateSession(c *fiber.Ctx) error {
	var body struct {
		DeviceToken string `json:"device_token"`
	}

	if err := c.BodyParser(&body); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	if body.DeviceToken == "" {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Device token is required")
	}

	sessionID, token, err := h.service.GetOrCreateSession(body.DeviceToken)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to create session")
	}

	return utils.SuccessResponse(c, fiber.Map{
		"session_id": sessionID,
		"jwt_token":  token,
	})
}
