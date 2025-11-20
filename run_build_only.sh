#!/bin/bash

# Package building script for robotframework-jsonlib
# Builds the package and verifies it's ready for PyPI
#
# Usage:
#   ./run_build_only.sh           # Normal mode: sets up venv and builds
#   ./run_build_only.sh --no-setup # Skip venv/dependency setup (used by run_ci_checks.sh)

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    
    echo "Installing build dependencies..."
    python -m pip install --upgrade pip > /dev/null 2>&1
    python -m pip install build twine > /dev/null 2>&1
    print_success "Build dependencies installed"
    echo ""
fi

# ================================
# Package Building
# ================================
echo -e "${BLUE}Building Package...${NC}"
echo ""

print_info "Cleaning previous builds..."
rm -rf dist/ build/ robotframework_jsonlib.egg-info/
print_success "Build directories cleaned"

print_info "Building package..."
# Note: Setuptools may show deprecation warnings about license format.
# We use the table format for compatibility with Python 3.6-3.8.
# These warnings are safe to ignore until 2026-Feb-18.
python -m build > /dev/null 2>&1
print_success "Package built successfully"

print_info "Verifying package with twine..."
twine check dist/*
print_success "Package verification passed"

print_info "Testing package installation..."
pip install dist/*.whl --force-reinstall > /dev/null 2>&1
python -c "from JSONLib import JSONLib; print('✓ Package imports correctly')"
python -c "from JSONLib.__version__ import __version__; print(f'✓ Version: {__version__}')"
print_success "Package installation test passed"

echo ""
echo -e "${GREEN}Package build completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Distribution files are available in:${NC}"
echo -e "  - dist/"
ls -lh dist/
echo ""

if [ "$SKIP_SETUP" = false ]; then
    echo -e "${YELLOW}Note: Virtual environment is still active (.venv)${NC}"
    echo -e "${YELLOW}To deactivate, run: deactivate${NC}"
fi

