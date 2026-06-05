OPENAPI_SPEC := ../../packages/openapi/openapi.yaml
OAPI_CONFIG := oapi-codegen.yaml

.PHONY: generate
generate:
	tmp_spec=$$(mktemp); \
	trap 'rm -f "$$tmp_spec"' EXIT; \
	perl -0pe 's/openapi: 3\.1\.0/openapi: 3.0.3/; s/(\n\s*)type:\n(\s*)- (string|object)\n\2- "null"/$$1type: $$3$$1nullable: true/g' $(OPENAPI_SPEC) > "$$tmp_spec"; \
	oapi-codegen --config $(OAPI_CONFIG) "$$tmp_spec"

.PHONY: build
build:
	go build -o ./bin/server ./cmd/server
