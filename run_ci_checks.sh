#!/bin/bash

# CI Validation Script for robotframework-jsonlib
# This script runs all the checks that are executed in the GitHub Actions workflow

set -eo pipefail  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}\n"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# ================================
# SECTION 0: Virtual Environment Setup
# ================================
print_section "SECTION 0: Virtual Environment Setup"

VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
    print_info "Virtual environment already exists, using existing venv..."
else
    print_info "Creating virtual environment..."
    python -m venv "$VENV_DIR"
    print_success "Virtual environment created"
fi

print_info "Activating virtual environment..."
source "$VENV_DIR/bin/activate"
print_success "Virtual environment activated"

# ================================
# SECTION 1: Environment Setup
# ================================
print_section "SECTION 1: Environment Setup"

print_info "Upgrading pip..."
python -m pip install --upgrade pip
print_success "pip upgraded"

print_info "Installing package in editable mode..."
python -m pip install -e .
print_success "Package installed"

print_info "Installing dev dependencies..."
python -m pip install -r requirements-dev.txt
print_success "Dev dependencies installed"

# ================================
# SECTION 2: Code Quality Checks
# ================================
print_section "SECTION 2: Code Quality Checks"

print_info "Running pylint..."
pylint JSONLib --disable=R,C,W0703,W0212,W1203
print_success "pylint passed"

print_info "Checking documentation generation..."
python -m robot.libdoc JSONLib docs/index.html
print_success "Documentation generated successfully"

print_info "Checking code formatting with black..."
black . --check --diff
print_success "black formatting check passed"

# ================================
# SECTION 3: Linting with flake8
# ================================
print_section "SECTION 3: Linting with flake8"

print_info "Running flake8 (critical errors)..."
# Stop the build if there are Python syntax errors or undefined names
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics --exclude=.venv*,build,dist
print_success "flake8 critical checks passed"

print_info "Running flake8 (warnings)..."
# Exit-zero treats all errors as warnings
flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics --exclude=.venv*,build,dist
print_success "flake8 warnings check completed"

# ================================
# SECTION 4: Testing
# ================================
print_section "SECTION 4: Testing"

print_info "Running test suite (via run_tests_only.sh)..."
bash run_tests_only.sh --no-setup
print_success "All tests passed"

# ================================
# SECTION 5: Package Building
# ================================
print_section "SECTION 5: Package Building"

print_info "Running package build (via run_build_only.sh)..."
bash run_build_only.sh --no-setup
print_success "Package build completed"

# ================================
# ALL DONE!
# ================================
print_section "ALL CHECKS PASSED! ✓"

echo -e "${GREEN}All CI validation checks completed successfully!${NC}"
echo -e "${YELLOW}Coverage reports are available in:${NC}"
echo -e "  - HTML: htmlcov/index.html"
echo -e "  - XML: coverage.xml"
echo -e "  - Robot: tests/__out__/robot/"
echo -e "\n${YELLOW}Note: Virtual environment is still active (.venv)${NC}"
echo -e "${YELLOW}To deactivate, run: deactivate${NC}"

