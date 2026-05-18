# -----------------------------------------------------------------------------------------------------------
# Common Makefile — Rosé Pine Glow
# -----------------------------------------------------------------------------------------------------------
# Glamour JSON styles for Charm Glow. Targets use scripts/log.bash for output.
#
#   make help        — list targets
#   make check       — verify jq, python3, go (glow optional)
#   make build       — regenerate styles/*.json
#   make test        — validate JSON + Glamour render
#   make screenshots — regenerate gallery PNGs
#   make preview     — render examples/sample.md with glow
#   make clean       — remove Python caches
# -----------------------------------------------------------------------------------------------------------

.DEFAULT_GOAL := help

PROJECT_NAME := Rosé Pine Glow
SHELL := /bin/bash

COMMON_MAKEFILE_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
LOGGER := source $(COMMON_MAKEFILE_DIR)scripts/log.bash &&
STYLES_DIR := $(COMMON_MAKEFILE_DIR)styles
SCRIPTS_DIR := $(COMMON_MAKEFILE_DIR)scripts
VERIFY_DIR := $(SCRIPTS_DIR)/verify
SAMPLE_MD := $(COMMON_MAKEFILE_DIR)examples/sample.md

# Default style for make preview (override: make preview STYLE=rose-pine-dawn)
STYLE ?= rose-pine-moon-dark
STYLE_FILE := $(STYLES_DIR)/$(STYLE).json

# -----------------------------------------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------------------------------------

.PHONY: help build check clean test screenshots preview install

.PHONY: help ## Show this help message
help:
	@$(LOGGER) log_banner
	@$(LOGGER) log_info "Available make targets ($(PROJECT_NAME)):"
	@echo ""
	@grep -E \
		'^.PHONY: .*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ".PHONY: |## "}; {printf " %-22s - %s\n", $$2, $$3}'
	@echo ""
	@$(LOGGER) log_info "Quick start"
	@echo "  make check && make build && make test && make install"

# -----------------------------------------------------------------------------------------------------------
# Tool checks
# -----------------------------------------------------------------------------------------------------------

check_jq:
	@if ! command -v jq >/dev/null 2>&1; then \
		$(LOGGER) log_error "jq is not installed (brew install jq)"; \
		exit 1; \
	else \
		$(LOGGER) log_info_dim "$$(jq --version) is installed."; \
	fi

check_python:
	@if ! command -v python3 >/dev/null 2>&1; then \
		$(LOGGER) log_error "python3 is not installed (brew install python)"; \
		exit 1; \
	else \
		$(LOGGER) log_info_dim "python3 $$(python3 --version 2>&1 | cut -d' ' -f2) is installed."; \
	fi

check_go:
	@if ! command -v go >/dev/null 2>&1; then \
		$(LOGGER) log_error "go is not installed (brew install go)"; \
		exit 1; \
	else \
		$(LOGGER) log_info_dim "go $$(go version | awk '{print $$3}') is installed."; \
	fi

check_glow:
	@if ! command -v glow >/dev/null 2>&1; then \
		$(LOGGER) log_warning "glow is not installed — optional for make preview (brew install glow)"; \
	else \
		$(LOGGER) log_info_dim "glow $$(glow --version 2>&1 | head -1) is installed."; \
	fi

check_pillow:
	@python3 -c "import PIL" 2>/dev/null || { \
		$(LOGGER) log_warning "Pillow not installed — required for make screenshots (pip install pillow)"; \
	}

.PHONY: check ## Verify required tools (jq, python3, go)
check:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Checking dependencies"
	@$(MAKE) check_jq
	@$(MAKE) check_python
	@$(MAKE) check_go
	@$(MAKE) check_glow
	@$(MAKE) check_pillow
	@if [ ! -f "$(STYLE_FILE)" ]; then \
		$(LOGGER) log_warning "Default style not found: $(STYLE_FILE) (run make build)"; \
	fi
	@$(LOGGER) log_success "Check complete"

# -----------------------------------------------------------------------------------------------------------
# Build & validate
# -----------------------------------------------------------------------------------------------------------

.PHONY: build ## Regenerate styles/*.json from scripts/build-styles.py
build: check_python
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Building Glamour style JSON"
	@python3 $(SCRIPTS_DIR)/build-styles.py
	@$(LOGGER) log_success "Styles written to styles/"

validate_json: check_jq
	@$(LOGGER) log_info_dim "Validating JSON syntax..."
	@jq empty $(STYLES_DIR)/*.json
	@$(LOGGER) log_info_dim "All style JSON files are valid."

.PHONY: test ## Validate JSON and verify Glamour can render each style
test: check_jq check_go validate_json
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Verifying Glamour rendering"
	@cd $(VERIFY_DIR) && go run .
	@$(LOGGER) log_success "All styles render successfully"

# -----------------------------------------------------------------------------------------------------------
# Gallery & preview
# -----------------------------------------------------------------------------------------------------------

.PHONY: screenshots ## Regenerate screenshots/*.png (requires Pillow)
screenshots: check_python
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Generating screenshot PNGs"
	@python3 -c "import PIL" 2>/dev/null || { \
		$(LOGGER) log_error "Pillow required: pip install pillow"; \
		exit 1; \
	}
	@python3 $(SCRIPTS_DIR)/generate-screenshots.py
	@$(LOGGER) log_success "Screenshots written to screenshots/"

.PHONY: install ## Install styles to ~/.config/glow and configure glow.yml (interactive)
install: check_glow
	@if [ ! -f "$(STYLES_DIR)/rose-pine.json" ]; then \
		$(LOGGER) log_warning "Styles missing — running make build"; \
		$(MAKE) build; \
	fi
	@INSTALL_STYLE="$(INSTALL_STYLE)" GLOW_STYLES_DIR="$(GLOW_STYLES_DIR)" \
		GLOW_CONFIG_FILE="$(GLOW_CONFIG_FILE)" \
		bash $(SCRIPTS_DIR)/install.bash $(INSTALL_FLAGS)

.PHONY: preview ## Preview sample markdown with glow (STYLE=rose-pine-moon-dark)
preview: check_glow
	@if [ ! -f "$(STYLE_FILE)" ]; then \
		$(LOGGER) log_error "Style not found: $(STYLE_FILE)"; \
		exit 1; \
	fi
	@if ! command -v glow >/dev/null 2>&1; then \
		$(LOGGER) log_error "glow is required for preview"; \
		exit 1; \
	fi
	@$(LOGGER) log_info "Previewing $(SAMPLE_MD) with $(STYLE).json"
	@glow -s "$(STYLE_FILE)" "$(SAMPLE_MD)" --pager=false

# -----------------------------------------------------------------------------------------------------------
# Clean
# -----------------------------------------------------------------------------------------------------------

.PHONY: clean ## Remove Python caches and Go test cache
clean:
	@$(LOGGER) log_separator
	@$(LOGGER) log_info "Cleaning artifacts"
	@find $(COMMON_MAKEFILE_DIR) -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@rm -rf $(VERIFY_DIR)/go.sum.bak 2>/dev/null || true
	@go clean -cache -testcache 2>/dev/null || true
	@$(LOGGER) log_success "Clean complete"
