package config

import (
	"os"
	"strconv"

	"github.com/joho/godotenv"
	"github.com/rs/zerolog/log"
)

type Config struct {
	AppEnv         string
	AppPort        string
	AppVersion     string
	DBHost         string
	DBPort         string
	DBName         string
	DBUser         string
	DBPassword     string
	DBSSLMode      string
	JWTSecret      string
	JWTExpiryDays  int
	RateLimit      bool
	CleanupEnabled bool
}

func LoadConfig() *Config {
	err := godotenv.Load()
	if err != nil {
		log.Warn().Msg("No .env file found, using system environment variables")
	}

	jwtExpiry, _ := strconv.Atoi(getEnv("JWT_EXPIRY_DAYS", "365"))
	rateLimit, _ := strconv.ParseBool(getEnv("RATE_LIMIT_ENABLED", "true"))
	cleanup, _ := strconv.ParseBool(getEnv("CLEANUP_JOB_ENABLED", "true"))

	return &Config{
		AppEnv:         getEnv("APP_ENV", "development"),
		AppPort:        getEnv("APP_PORT", "8080"),
		AppVersion:     getEnv("APP_VERSION", "1.0.0"),
		DBHost:         getEnv("DB_HOST", "localhost"),
		DBPort:         getEnv("DB_PORT", "5432"),
		DBName:         getEnv("DB_NAME", "spinit"),
		DBUser:         getEnv("DB_USER", "spinit_user"),
		DBPassword:     getEnv("DB_PASSWORD", ""),
		DBSSLMode:      getEnv("DB_SSLMODE", "disable"),
		JWTSecret:      getEnv("JWT_SECRET", "super-secret-key-change-me"),
		JWTExpiryDays:  jwtExpiry,
		RateLimit:      rateLimit,
		CleanupEnabled: cleanup,
	}
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
