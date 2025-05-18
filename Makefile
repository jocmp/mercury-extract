.PHONY: build
build:
	npx tsc

PHONY: install
install:
	npm install

PHONY: run
run:
	node dist/server.js
