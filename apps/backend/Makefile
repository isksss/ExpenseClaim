OPENAPI_SPEC := ../../packages/openapi/openapi.yaml
OAPI_CONFIG := oapi-codegen.yaml
DB_MIGRATIONS_DIR := db/migrations
DB_DRIVER := postgres

.PHONY: generate
generate:
	tmp_spec=$$(mktemp); \
	trap 'rm -f "$$tmp_spec"' EXIT; \
	perl -0pe 's/openapi: 3\.1\.0/openapi: 3.0.3/; s/(\n\s*)type:\n(\s*)- (string|object)\n\2- "null"/$$1type: $$3$$1nullable: true/g' $(OPENAPI_SPEC) > "$$tmp_spec"; \
	oapi-codegen --config $(OAPI_CONFIG) "$$tmp_spec"

.PHONY: build
build:
	go build -o ./bin/server ./cmd/server

.PHONY: clean
clean:
	rm -rf ./bin

.PHONY: generate-db
generate-db:
	sqlc generate

.PHONY: require-database-url
require-database-url:
	@[ -n "$${DATABASE_URL:-}" ] || { echo "DATABASE_URL is required. Set DATABASE_URL before running migration targets." >&2; exit 1; }

.PHONY: migrate-up
migrate-up: require-database-url
	@goose -dir $(DB_MIGRATIONS_DIR) $(DB_DRIVER) "$${DATABASE_URL}" up

.PHONY: migrate-down
migrate-down: require-database-url
	@goose -dir $(DB_MIGRATIONS_DIR) $(DB_DRIVER) "$${DATABASE_URL}" down

.PHONY: migrate-status
migrate-status: require-database-url
	@goose -dir $(DB_MIGRATIONS_DIR) $(DB_DRIVER) "$${DATABASE_URL}" status
