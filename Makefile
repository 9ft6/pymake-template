# Makefile to manage a Python project
# Configuration variables:
# - PYTHON_VERSION: required Python version (default 3.13)
# - VENV_DIR: path to the virtual environment (default .venv)
# - ENTRYPOINT: command/script to run the application (default app.py)
# - ACTIVATE: venv activation command (used in commands)
# - UBUNTU_PACKAGES: system packages to install via apt-get/apt at the end of 'make install' (optional)

PYTHON_VERSION ?= 3.13
VENV_DIR       ?= .venv
ENTRYPOINT     ?= app.py
UBUNTU_PACKAGES?= 
ACTIVATE_SCRIPT:= $(VENV_DIR)/bin/activate
ACTIVATE       := . $(ACTIVATE_SCRIPT)

.DEFAULT_GOAL := help
.PHONY: help venv install run clean clean-venv

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z0-9_.-]+:.*?## / {printf "%-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

venv: ## Create a virtual environment with Python $(PYTHON_VERSION) in $(VENV_DIR)
	@set -eu; \
	if [ -d "$(VENV_DIR)" ]; then \
		echo "Venv already exists: $(VENV_DIR)"; \
		$(ACTIVATE); \
		exit 0; \
	fi; \
	if command -v python$(PYTHON_VERSION) >/dev/null 2>&1; then \
		PY="python$(PYTHON_VERSION)"; \
	elif command -v pyenv >/dev/null 2>&1 && pyenv which python$(PYTHON_VERSION) >/dev/null 2>&1; then \
		PY="$$ (pyenv which python$(PYTHON_VERSION))"; \
	elif command -v python3 >/dev/null 2>&1; then \
		PY="python3"; \
	else \
		echo "Python interpreter python$(PYTHON_VERSION) or python3 not found. Install the required version or configure pyenv."; \
		exit 1; \
	fi; \
	echo "Creating venv using: $$PY"; \
	"$$PY" -m venv "$(VENV_DIR)"; \
	$(ACTIVATE) && python -m pip install -U pip

install: ## Install dependencies (requirements.txt or pyproject.toml)
	@set -eu; \
	if [ ! -f "$(ACTIVATE_SCRIPT)" ]; then \
		$(MAKE) --no-print-directory venv; \
	fi; \
	$(ACTIVATE) && \
	if [ -f requirements.txt ]; then \
		python -m pip install -U pip && python -m pip install -r requirements.txt; \
	elif [ -f pyproject.toml ]; then \
		python -m pip install -U pip && python -m pip install -e .; \
	else \
		echo "requirements.txt or pyproject.toml not found"; \
	fi
	@set -eu; \
	if [ -n "$(strip $(UBUNTU_PACKAGES))" ]; then \
		echo "Installing Ubuntu packages: $(UBUNTU_PACKAGES)"; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo apt-get update && sudo apt-get install -y $(UBUNTU_PACKAGES); \
		elif command -v apt >/dev/null 2>&1; then \
			sudo apt update && sudo apt install -y $(UBUNTU_PACKAGES); \
		else \
			echo "apt/apt-get not found; skipping Ubuntu packages installation"; \
		fi; \
	fi

run: ## Run the application (ENTRYPOINT=$(ENTRYPOINT))
	@set -eu; \
	if [ ! -f "$(ACTIVATE_SCRIPT)" ]; then \
		$(MAKE) --no-print-directory venv; \
	fi; \
	$(ACTIVATE) && python $(ENTRYPOINT)

clean: ## Remove build artifacts
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} +; \
	rm -rf build dist .pytest_cache .mypy_cache *.egg-info

clean-venv: ## Remove virtual environment
	@rm -rf "$(VENV_DIR)"
