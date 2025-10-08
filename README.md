# Python Makefile Template

This is minimal Makefile to manage Python projects. Built for personal use. No warranties or guarantees.

Features
- Create a virtual environment for a specific version (default 3.13).
- Install dependencies from requirements.txt or pyproject.toml.
- Run the application via ENTRYPOINT.
- Clean build artifacts.
- Optionally install Ubuntu system packages via UBUNTU_PACKAGES (apt/apt-get).

Settings:
- PYTHON_VERSION - Python version (default 3.13)
- VENV_DIR - path to the virtual environment (default venv)
- ENTRYPOINT - command/script to run (default app.py)
- UBUNTU_PACKAGES - list of Ubuntu system packages installed at the end of `make install`

Commands
- help - show available commands
- venv - create a virtual environment
- install - install dependencies (+ Ubuntu packages if provided)
- run - run the application
- clean - remove build artifacts
- clean-venv - remove virtual environment

