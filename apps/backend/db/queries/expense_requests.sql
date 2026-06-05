-- name: GetExpenseRequestByID :one
SELECT id, requester_id, department_id, status, title, description, total_amount, submitted_at, manager_approved_at, accounting_approved_at, created_at, updated_at
FROM expense_requests
WHERE id = $1;

-- name: ListExpenseRequestsByRequesterID :many
SELECT id, requester_id, department_id, status, title, description, total_amount, submitted_at, manager_approved_at, accounting_approved_at, created_at, updated_at
FROM expense_requests
WHERE requester_id = $1
ORDER BY created_at DESC, id DESC;
