-- +goose Up
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE expense_request_status AS ENUM (
  'draft',
  'submitted',
  'manager_approved',
  'accounting_approved',
  'sent_back',
  'rejected',
  'canceled'
);

CREATE TYPE approval_action AS ENUM (
  'submit',
  'approve',
  'return',
  'reject',
  'cancel'
);

CREATE TABLE departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  identifier text NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT departments_identifier_not_blank CHECK (btrim(identifier) <> ''),
  CONSTRAINT departments_name_not_blank CHECK (btrim(name) <> ''),
  CONSTRAINT departments_identifier_unique UNIQUE (identifier)
);

COMMENT ON COLUMN departments.identifier IS 'Stable unique identifier used to identify departments, including accounting department checks.';

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  manager_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  email text NOT NULL,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT users_email_not_blank CHECK (btrim(email) <> ''),
  CONSTRAINT users_password_hash_not_blank CHECK (btrim(password_hash) <> ''),
  CONSTRAINT users_full_name_not_blank CHECK (btrim(full_name) <> ''),
  CONSTRAINT users_email_unique UNIQUE (email)
);

CREATE TABLE expense_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  department_id uuid REFERENCES departments(id) ON DELETE SET NULL,
  status expense_request_status NOT NULL DEFAULT 'draft',
  title text NOT NULL,
  description text,
  total_amount bigint NOT NULL,
  submitted_at timestamptz,
  manager_approved_at timestamptz,
  accounting_approved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT expense_requests_title_not_blank CHECK (btrim(title) <> ''),
  CONSTRAINT expense_requests_description_max_length CHECK (
    description IS NULL OR char_length(description) <= 1000
  ),
  CONSTRAINT expense_requests_total_amount_positive CHECK (total_amount > 0)
);

CREATE TABLE expense_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_request_id uuid NOT NULL REFERENCES expense_requests(id) ON DELETE CASCADE,
  spent_on date NOT NULL,
  category text NOT NULL,
  description text NOT NULL,
  amount bigint NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT expense_items_category_not_blank CHECK (btrim(category) <> ''),
  CONSTRAINT expense_items_description_not_blank CHECK (btrim(description) <> ''),
  CONSTRAINT expense_items_amount_positive CHECK (amount > 0)
);

CREATE TABLE attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_request_id uuid NOT NULL REFERENCES expense_requests(id) ON DELETE CASCADE,
  uploaded_by uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  storage_key text NOT NULL,
  file_name text NOT NULL,
  content_type text NOT NULL,
  size_bytes bigint NOT NULL,
  uploaded_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT attachments_storage_key_not_blank CHECK (btrim(storage_key) <> ''),
  CONSTRAINT attachments_file_name_not_blank CHECK (btrim(file_name) <> ''),
  CONSTRAINT attachments_content_type_not_blank CHECK (btrim(content_type) <> ''),
  CONSTRAINT attachments_size_bytes_positive CHECK (size_bytes > 0)
);

CREATE TABLE approvals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_request_id uuid NOT NULL REFERENCES expense_requests(id) ON DELETE CASCADE,
  actor_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  action approval_action NOT NULL,
  comment text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id uuid REFERENCES users(id) ON DELETE SET NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  action text NOT NULL,
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT audit_logs_entity_type_not_blank CHECK (btrim(entity_type) <> ''),
  CONSTRAINT audit_logs_action_not_blank CHECK (btrim(action) <> '')
);

CREATE TABLE refresh_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash text NOT NULL,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT refresh_tokens_token_hash_not_blank CHECK (btrim(token_hash) <> ''),
  CONSTRAINT refresh_tokens_token_hash_unique UNIQUE (token_hash),
  CONSTRAINT refresh_tokens_expires_after_created CHECK (expires_at > created_at),
  CONSTRAINT refresh_tokens_revoked_not_before_created CHECK (
    revoked_at IS NULL OR revoked_at >= created_at
  )
);

CREATE INDEX users_department_id_idx ON users(department_id);
CREATE INDEX users_manager_user_id_idx ON users(manager_user_id);
CREATE INDEX expense_requests_requester_id_idx ON expense_requests(requester_id);
CREATE INDEX expense_requests_department_id_idx ON expense_requests(department_id);
CREATE INDEX expense_requests_status_idx ON expense_requests(status);
CREATE INDEX expense_items_expense_request_id_idx ON expense_items(expense_request_id);
CREATE INDEX attachments_expense_request_id_idx ON attachments(expense_request_id);
CREATE INDEX attachments_uploaded_by_idx ON attachments(uploaded_by);
CREATE INDEX approvals_expense_request_id_idx ON approvals(expense_request_id);
CREATE INDEX approvals_actor_id_idx ON approvals(actor_id);
CREATE INDEX audit_logs_entity_idx ON audit_logs(entity_type, entity_id);
CREATE INDEX audit_logs_actor_id_idx ON audit_logs(actor_id);
CREATE INDEX refresh_tokens_user_id_idx ON refresh_tokens(user_id);

-- +goose Down
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS approvals;
DROP TABLE IF EXISTS attachments;
DROP TABLE IF EXISTS expense_items;
DROP TABLE IF EXISTS expense_requests;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS departments;
DROP TYPE IF EXISTS approval_action;
DROP TYPE IF EXISTS expense_request_status;
