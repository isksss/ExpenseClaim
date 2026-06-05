package server

import (
	"github.com/isksss/ExpenseClaim/apps/backend/internal/generated/openapi"
	"github.com/isksss/ExpenseClaim/apps/backend/internal/handler"
	"github.com/labstack/echo/v4"
)

func New() *echo.Echo {
	e := echo.New()
	openapi.RegisterHandlers(e, handler.NewStub())
	return e
}
