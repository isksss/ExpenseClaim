-- name: GetDepartmentByID :one
SELECT id, identifier, name, created_at, updated_at
FROM departments
WHERE id = $1;

-- name: GetDepartmentByIdentifier :one
SELECT id, identifier, name, created_at, updated_at
FROM departments
WHERE identifier = $1;

-- name: ListDepartments :many
SELECT id, identifier, name, created_at, updated_at
FROM departments
ORDER BY identifier;
