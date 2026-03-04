SHELL := /bin/bash
.PHONY: all ci-check bootstrap devshell


all: ci-check

ci-check:
	@echo "CI checks placeholder: nothing to lint yet"

bootstrap:
	./tools/bootstrap.sh

devshell:
	@echo "To build devshell: docker build -t ocd-devshell ./tools/devshell"

build-deb:
	@bash packages/deb/build_deb.sh

