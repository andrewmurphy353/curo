# ================================================
# Curo Dart – Development Makefile
# ================================================
# Common commands:
#   make test               # Run all tests
#   make coverage           # Generate coverage report
#   make format             # Format code
#   make analyze            # Static analysis
#   make dry-run            # Dry-run publish to pub.dev
#   make publish            # Publish to pub.dev (with confirmation)
#   make docs-serve         # Serve documentation locally
#   make docs-deploy        # Deploy docs to GitHub Pages
#   make clean              # Clean build artifacts and coverage
# ================================================

# Tools
DART := dart
UV := uv
PYTHON := python3
VENV_DIR := .venv

# Default target
.PHONY: all
all: format analyze test coverage

# ================================================
# Code Quality
# ================================================

.PHONY: format
format:
	$(DART) format .

.PHONY: analyze
analyze:
	$(DART) analyze --fatal-infos

.PHONY: fix
fix:
	$(DART) fix --apply

# ================================================
# Testing & Coverage
# ================================================

.PHONY: test
test:
	$(DART) test test/ site/test

.PHONY: coverage
coverage:
	rm -rf coverage  # Clean old data
	mkdir -p coverage

	# Run all tests with VM service enabled and isolates paused on exit
	# Use 'dart run' instead of 'dart test' for reliable VM flag passing
	$(DART) run --pause-isolates-on-exit \
	         --disable-service-auth-codes \
	         --enable-vm-service=8181 \
	         test test/ site/test &

	# Collect coverage data from the VM service (starts waiting immediately)
	$(DART) pub global run coverage:collect_coverage \
		--uri=http://127.0.0.1:8181 \
		--wait-paused \
		--resume-isolates \
		-o coverage/coverage.json

	# Format to LCOV, focusing only on your lib/ code
	$(DART) pub global run coverage:format_coverage \
		--lcov \
		--in=coverage/coverage.json \
		--out=coverage/lcov.info \
		--report-on=lib \
		--check-ignore \
		--packages=.dart_tool/package_config.json

	# Generate HTML report (requires lcov installed)
	mkdir -p coverage/html
	genhtml coverage/lcov.info -o coverage/html \
		--title="Dart Coverage Report" \
		--legend \
		--branch-coverage

	@echo "Coverage report generated at coverage/html/index.html"
	@echo "Open with: open coverage/html/index.html  (macOS)"
	@echo "          xdg-open coverage/html/index.html (Linux)"

# ================================================
# Publishing
# ================================================

.PHONY: dry-run
dry-run: build-setup format analyze test
	$(DART) pub publish --dry-run
	@echo "Dry-run complete. Ready to publish when version is updated."

.PHONY: publish
publish: build-setup format analyze test
	$(DART) pub publish
	@echo "Package published to pub.dev!"

# Safety prompt before any publish attempt
.PHONY: build-setup
build-setup:
	@echo "------------------------------------------------------------------"
	@echo "Has the version in pubspec.yaml been bumped for this release?"
	@echo "------------------------------------------------------------------"
	@echo "1 - Yes, let's go!"
	@echo "2 - No, abort"
	@read -p "Choice [1-2]: " response; \
	if [ "$$response" != "1" ]; then \
		echo "Publish aborted. Please update pubspec.yaml version first."; \
		exit 1; \
	fi

# ================================================
# Documentation (using mkdocs via uv)
# ================================================

.PHONY: docs-serve
docs-serve: docs-venv
	@echo "Serving documentation at http://127.0.0.1:8000"
	$(UV) run --with mkdocstrings mkdocs serve

.PHONY: docs-build
docs-build: docs-venv
	$(UV) run --with mkdocstrings mkdocs build

.PHONY: docs-deploy
docs-deploy: docs-venv
	$(UV) run --with mkdocstrings mkdocs gh-deploy --force

# Ensure docs environment is ready
.PHONY: docs-venv
docs-venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment for docs..."; \
		$(UV) venv $(VENV_DIR); \
		. $(VENV_DIR)/bin/activate && \
		$(UV) pip install mkdocs mkdocs-material mkdocstrings[python]; \
	fi

# Alt: Dart docs -> /doc/api/
.PHONY: docs-dart
docs-dart:
	$(DART) doc

# ================================================
# Cleaning
# ================================================

.PHONY: clean
clean: clean-build clean-coverage clean-venv
	@echo "Project cleaned."

.PHONY: clean-build
clean-build:
	rm -rf build/ dist/ .dart_tool/
	$(DART) pub get

.PHONY: clean-coverage
clean-coverage:
	rm -rf coverage/ lcov.info

.PHONY: clean-venv
clean-venv:
	rm -rf $(VENV_DIR)

.PHONY: rebuild-docs
rebuild-docs: clean-venv docs-venv
	@echo "Documentation environment rebuilt."

# ================================================
# Help
# ================================================

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make test           - Run tests"
	@echo "  make coverage       - Generate HTML coverage report"
	@echo "  make format         - Format code"
	@echo "  make analyze        - Run static analysis"
	@echo "  make dry-run        - Test publish to pub.dev"
	@echo "  make publish        - Publish package (with confirmation)"
	@echo "  make docs-serve     - Serve docs locally"
	@echo "  make docs-deploy    - Deploy docs to GitHub Pages"
	@echo "  make clean          - Remove build artifacts and venv"
