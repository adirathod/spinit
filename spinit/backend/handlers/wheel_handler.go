package handlers

import (
	"github.com/adirathod/spinit-backend/models"
	"github.com/adirathod/spinit-backend/services"
	"github.com/adirathod/spinit-backend/utils"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
	"gorm.io/gorm"
)

type WheelHandler struct {
	service *services.WheelService
}

func NewWheelHandler(service *services.WheelService) *WheelHandler {
	return &WheelHandler{service}
}

func (h *WheelHandler) CreateWheel(c *fiber.Ctx) error {
	sessionIDStr := c.Locals("session_id").(string)
	sessionID, _ := uuid.Parse(sessionIDStr)

	var body struct {
		Name     string           `json:"name"`
		Segments []models.Segment `json:"segments"`
	}

	if err := c.BodyParser(&body); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	if len(body.Segments) < 2 || len(body.Segments) > 20 {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Segments must be between 2 and 20")
	}

	wheel, err := h.service.CreateWheel(body.Name, sessionID, body.Segments)
	if err != nil {
		log.Error().Err(err).Str("session_id", sessionIDStr).Msg("Failed to create wheel")
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to create wheel")
	}

	return utils.SuccessResponse(c, fiber.Map{
		"wheel": wheel,
	})
}

func (h *WheelHandler) GetWheel(c *fiber.Ctx) error {
	code := c.Params("code")
	wheel, err := h.service.GetWheel(code)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return utils.ErrorResponse(c, fiber.StatusNotFound, "Wheel not found or expired")
		}
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to fetch wheel")
	}

	return utils.SuccessResponse(c, wheel)
}

func (h *WheelHandler) GetMyWheels(c *fiber.Ctx) error {
	sessionIDStr := c.Locals("session_id").(string)
	sessionID, _ := uuid.Parse(sessionIDStr)

	wheels, err := h.service.GetMyWheels(sessionID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to fetch wheels")
	}

	return utils.SuccessResponse(c, wheels)
}

func (h *WheelHandler) DeleteWheel(c *fiber.Ctx) error {
	sessionIDStr := c.Locals("session_id").(string)
	sessionID, _ := uuid.Parse(sessionIDStr)
	code := c.Params("code")

	err := h.service.DeleteWheel(code, sessionID)
	if err != nil {
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to delete wheel")
	}

	return utils.SuccessResponse(c, "Wheel deleted successfully")
}

func (h *WheelHandler) LogSpin(c *fiber.Ctx) error {
	code := c.Params("code")
	var body struct {
		ResultLabel string `json:"result_label"`
		ResultColor string `json:"result_color"`
	}

	if err := c.BodyParser(&body); err != nil {
		return utils.ErrorResponse(c, fiber.StatusBadRequest, "Invalid request body")
	}

	err := h.service.LogSpin(code, body.ResultLabel, body.ResultColor)
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return utils.ErrorResponse(c, fiber.StatusNotFound, "Wheel not found or expired")
		}
		return utils.ErrorResponse(c, fiber.StatusInternalServerError, "Failed to log spin")
	}

	return utils.SuccessResponse(c, "Spin logged successfully")
}
