package main

import (
	"os"
	"time"

	"github.com/adirathod/spinit-backend/config"
	"github.com/adirathod/spinit-backend/handlers"
	"github.com/adirathod/spinit-backend/middleware"
	"github.com/adirathod/spinit-backend/repository"
	"github.com/adirathod/spinit-backend/services"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func main() {
	// Setup structured logging
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	cfg := config.LoadConfig()
	config.ConnectDatabase(cfg)

	// Repositories
	sessionRepo := repository.NewSessionRepository(config.DB)
	wheelRepo := repository.NewWheelRepository(config.DB)

	// Services
	sessionService := services.NewSessionService(sessionRepo, cfg.JWTSecret, cfg.JWTExpiryDays)
	wheelService := services.NewWheelService(wheelRepo)

	// Background Cleanup Job
	if cfg.CleanupEnabled {
		services.StartCleanupJob(wheelRepo)
	}

	// Handlers
	sessionHandler := handlers.NewSessionHandler(sessionService)
	wheelHandler := handlers.NewWheelHandler(wheelService)

	app := fiber.New(fiber.Config{
		AppName: "SpinIt API " + cfg.AppVersion,
	})

	// Global Middleware
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowMethods: "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
	}))
	app.Use(middleware.Logger())

	v1 := app.Group("/v1")

	// Public Routes
	v1.Get("/health", handlers.HealthCheck)
	
	// Session Routes
	sessionGroup := v1.Group("/session")
	if cfg.RateLimit {
		sessionGroup.Use(middleware.RateLimit(5, time.Minute))
	}
	sessionGroup.Post("/", sessionHandler.CreateSession)

	// Wheel Routes
	wheelsGroup := v1.Group("/wheels")
	
	// Public Wheel Access
	wheelsGroup.Get("/:code", wheelHandler.GetWheel)
	wheelsGroup.Post("/:code/spin", wheelHandler.LogSpin)

	// Authenticated Wheel Routes
	auth := middleware.AuthMiddleware(cfg.JWTSecret, sessionRepo)
	
	authenticatedWheels := wheelsGroup.Group("/")
	authenticatedWheels.Use(auth)
	
	if cfg.RateLimit {
		authenticatedWheels.Post("/", middleware.RateLimit(10, time.Minute), wheelHandler.CreateWheel)
	} else {
		authenticatedWheels.Post("/", wheelHandler.CreateWheel)
	}
	
	authenticatedWheels.Get("/my", wheelHandler.GetMyWheels)
	authenticatedWheels.Delete("/:code", wheelHandler.DeleteWheel)

	log.Info().Msgf("Starting server on port %s", cfg.AppPort)
	if err := app.Listen(":" + cfg.AppPort); err != nil {
		log.Fatal().Err(err).Msg("Server failed to start")
	}
}
