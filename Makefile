.PHONY: build
build:
	npx tsc

PHONY: install
install:
	npm install

PHONY: run-dev
run-dev:
	node dist/server.js

PHONY: secrets
secrets:
	@mkdir -p users
	@echo "${EXTRACT_SECRET_GPLAY}" > users/${EXTRACT_USER_GPLAY}
	@echo "${EXTRACT_SECRET_FREE}" > users/${EXTRACT_USER_FREE}

PHONY: run
run: secrets
	node dist/server.js
