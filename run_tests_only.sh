#!/bin/bash

# Quick test script (skips linting and formatting checks)
# Useful for rapid development iteration
#
# Usage:
#   ./run_tests_only.sh           # Normal mode: sets up venv and runs tests
#   ./run_tests_only.sh --no-setup # Skip venv/dependency setup (used by run_ci_checks.sh)

set -eo pipefail

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if --no-setup flag is passed
SKIP_SETUP=false
if [ "$1" == "--no-setup" ]; then
    SKIP_SETUP=true
fi

# ================================
# Setup (unless --no-setup is passed)
# ================================
if [ "$SKIP_SETUP" = false ]; then
    VENV_DIR=".venv"
    
    if [ -d "$VENV_DIR" ]; then
        echo "Using existing virtual environment..."
    else
        echo "Creating virtual environment..."
        python -m venv "$VENV_DIR"
    fi
    
    echo "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"
    
    echo "Installing dependencies..."
    python -m pip install --upgrade pip > /dev/null 2>&1
    python -m pip install -e . > /dev/null 2>&1
    python -m pip install -r requirements-dev.txt > /dev/null 2>&1
    echo ""
fi

# ================================
# Run Tests
# ================================
echo "Running pytest..."
pytest --cov-config=tests/.coveragerc --cov --cov-report term tests/

echo "Generating coverage reports..."
coverage xml --rcfile tests/.coveragerc
coverage html --rcfile tests/.coveragerc

echo "Running Robot Framework tests..."
robot -d tests/__out__/robot acceptance/

echo -e "\n✓ All tests passed!"

if [ "$SKIP_SETUP" = false ]; then
    echo "Note: Virtual environment is still active (.venv)"
    echo "To deactivate, run: deactivate"
fi

