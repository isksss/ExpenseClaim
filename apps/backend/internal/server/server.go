package server

import (
	"net/http"
	"os"
	"strings"

	"github.com/isksss/ExpenseClaim/apps/backend/internal/generated/openapi"
	"github.com/isksss/ExpenseClaim/apps/backend/internal/handler"
	"github.com/labstack/echo/v4"
)

func New() *echo.Echo {
	e := echo.New()
	e.Use(corsMiddleware(allowedOrigins()))
	healthHandler := func(c echo.Context) error {
		return c.NoContent(http.StatusOK)
	}
	e.GET("/healthz", healthHandler)
	e.HEAD("/healthz", healthHandler)
	openapi.RegisterHandlers(e, handler.NewStub())
	return e
}

func corsMiddleware(allowedOrigins []string) echo.MiddlewareFunc {
	allowed := make(map[string]struct{}, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		allowed[origin] = struct{}{}
	}

	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			origin := c.Request().Header.Get(echo.HeaderOrigin)
			if _, ok := allowed[origin]; ok {
				c.Response().Header().Set(echo.HeaderAccessControlAllowOrigin, origin)
				c.Response().Header().Set(echo.HeaderAccessControlAllowMethods, "GET,POST,PUT,PATCH,DELETE,OPTIONS")
				c.Response().Header().Set(echo.HeaderAccessControlAllowHeaders, "Authorization,Content-Type")
			}
			if c.Request().Method == http.MethodOptions {
				return c.NoContent(http.StatusNoContent)
			}
			return next(c)
		}
	}
}

func allowedOrigins() []string {
	defaultOrigins := []string{"http://localhost:3000", "https://claim.isksss.dev"}
	value := os.Getenv("CORS_ALLOWED_ORIGINS")
	if value == "" {
		return defaultOrigins
	}

	origins := strings.Split(value, ",")
	allowed := make([]string, 0, len(origins))
	for _, origin := range origins {
		trimmed := strings.TrimSpace(origin)
		if trimmed != "" {
			allowed = append(allowed, trimmed)
		}
	}
	if len(allowed) == 0 {
		return defaultOrigins
	}
	return allowed
}
