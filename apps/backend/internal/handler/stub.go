package handler

import (
	"net/http"

	"github.com/isksss/ExpenseClaim/apps/backend/internal/generated/openapi"
	"github.com/labstack/echo/v4"
)

type Stub struct{}

func NewStub() *Stub {
	return &Stub{}
}

func notImplemented(c echo.Context) error {
	return c.JSON(http.StatusNotImplemented, map[string]string{
		"message": "not implemented",
	})
}

func (s *Stub) ListAuditLogs(ctx echo.Context, params openapi.ListAuditLogsParams) error {
	return notImplemented(ctx)
}

func (s *Stub) Login(ctx echo.Context) error {
	return notImplemented(ctx)
}

func (s *Stub) Logout(ctx echo.Context) error {
	return notImplemented(ctx)
}

func (s *Stub) GetCurrentUser(ctx echo.Context) error {
	return notImplemented(ctx)
}

func (s *Stub) RefreshToken(ctx echo.Context) error {
	return notImplemented(ctx)
}

func (s *Stub) ListDepartments(ctx echo.Context, params openapi.ListDepartmentsParams) error {
	return notImplemented(ctx)
}

func (s *Stub) GetDepartment(ctx echo.Context, departmentId openapi.DepartmentId) error {
	return notImplemented(ctx)
}

func (s *Stub) ListExpenseClaims(ctx echo.Context, params openapi.ListExpenseClaimsParams) error {
	return notImplemented(ctx)
}

func (s *Stub) CreateExpenseClaim(ctx echo.Context) error {
	return notImplemented(ctx)
}

func (s *Stub) DeleteExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) GetExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) UpdateExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) AccountingApproveExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) UploadAttachment(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) DeleteAttachment(ctx echo.Context, claimId openapi.ClaimId, attachmentId openapi.AttachmentId) error {
	return notImplemented(ctx)
}

func (s *Stub) DownloadAttachment(ctx echo.Context, claimId openapi.ClaimId, attachmentId openapi.AttachmentId) error {
	return notImplemented(ctx)
}

func (s *Stub) CancelExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) ManagerApproveExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) RejectExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) SendBackExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) SubmitExpenseClaim(ctx echo.Context, claimId openapi.ClaimId) error {
	return notImplemented(ctx)
}

func (s *Stub) ListUsers(ctx echo.Context, params openapi.ListUsersParams) error {
	return notImplemented(ctx)
}

func (s *Stub) GetUser(ctx echo.Context, userId openapi.UserId) error {
	return notImplemented(ctx)
}
