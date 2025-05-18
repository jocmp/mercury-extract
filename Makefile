.PHONY: build
build:
	npx tsc

PHONY: install
install:
	npm install

PHONY: run
run:
	@mkdir -p users
	@echo "${EXTRACT_SECRET}" > users/${EXTRACT_USER}
	node dist/server.js
