-- name: GetUserByID :one
SELECT id, department_id, manager_user_id, email, password_hash, full_name, is_active, created_at, updated_at
FROM users
WHERE id = $1;

-- name: GetUserByEmail :one
SELECT id, department_id, manager_user_id, email, password_hash, full_name, is_active, created_at, updated_at
FROM users
WHERE email = $1;
