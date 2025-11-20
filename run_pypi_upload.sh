#!/bin/bash

# PyPI Upload Script for robotframework-jsonlib
# Uploads the package to production PyPI
#
# Prerequisites:
#   1. Register an account at https://pypi.org/account/register/
#   2. Generate an API token at https://pypi.org/manage/account/token/
#   3. Configure ~/.pypirc with:
#      [pypi]
#      username = __token__
#      password = <your PyPI API Token>
#
# Usage:
#   ./run_pypi_upload.sh           # Build and upload to PyPI
#   ./run_pypi_upload.sh --no-build # Skip building (use existing dist/)

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

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Parse arguments
SKIP_BUILD=false

for arg in "$@"; do
    case $arg in
        --no-build)
            SKIP_BUILD=true
            shift
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--no-build]"
            exit 1
            ;;
    esac
done

# ================================
# Setup
# ================================
VENV_DIR=".venv"

if [ -d "$VENV_DIR" ]; then
    echo "Using existing virtual environment..."
else
    echo "Creating virtual environment..."
    python -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "Installing/upgrading build tools..."
python -m pip install --upgrade pip > /dev/null 2>&1
python -m pip install --upgrade build twine > /dev/null 2>&1
print_success "Build tools ready"
echo ""

# ================================
# Build Package (unless --no-build)
# ================================
if [ "$SKIP_BUILD" = false ]; then
    echo -e "${BLUE}Building Package...${NC}"
    echo ""
    
    print_info "Running build..."
    bash run_build_only.sh --no-setup
    echo ""
else
    print_info "Skipping build (using existing dist/)..."
    
    # Verify dist directory exists
    if [ ! -d "dist" ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
        print_error "No distribution files found in dist/"
        print_info "Run without --no-build flag to build the package first"
        exit 1
    fi
    print_success "Found existing distribution files"
    echo ""
fi

# ================================
# Final Checks Before Upload
# ================================
echo -e "${BLUE}Pre-Upload Checks...${NC}"
echo ""

# Extract version from dist filename (compatible with both GNU and BSD)
VERSION=$(ls dist/*.whl | head -1 | sed -E 's/.*-([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || echo "unknown")

print_info "Package version: $VERSION"

# Check if this version already exists on PyPI
echo ""
print_warning "IMPORTANT: This will upload to PRODUCTION PyPI!"
echo ""
echo -e "${YELLOW}Package: robotframework-jsonlib${NC}"
echo -e "${YELLOW}Version: $VERSION${NC}"
echo ""
echo -e "${RED}⚠️  WARNING: This action cannot be undone!${NC}"
echo -e "${RED}⚠️  Versions cannot be re-uploaded once published.${NC}"
echo ""
read -p "Are you sure you want to upload to production PyPI? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Upload cancelled."
    exit 0
fi

# ================================
# Check PyPI Configuration
# ================================
print_info "Checking .pypirc configuration..."
if [ ! -f ~/.pypirc ]; then
    print_warning "~/.pypirc not found"
    echo ""
    echo -e "${YELLOW}To avoid entering credentials each time, create ~/.pypirc with:${NC}"
    echo ""
    echo "[pypi]"
    echo "username = __token__"
    echo "password = <your PyPI API Token>"
    echo ""
    echo -e "${YELLOW}Get your token at: https://pypi.org/manage/account/token/${NC}"
    echo ""
elif ! grep -q "\[pypi\]" ~/.pypirc; then
    print_warning "PyPI not configured in ~/.pypirc"
    echo ""
    echo -e "${YELLOW}Add this section to ~/.pypirc:${NC}"
    echo ""
    echo "[pypi]"
    echo "username = __token__"
    echo "password = <your PyPI API Token>"
    echo ""
    echo -e "${YELLOW}Get your token at: https://pypi.org/manage/account/token/${NC}"
    echo ""
else
    print_success "Found PyPI configuration in ~/.pypirc"
fi

# ================================
# Upload to PyPI
# ================================
echo -e "${BLUE}Uploading to Production PyPI...${NC}"
echo ""

print_info "Uploading to PyPI..."
echo ""

# Upload with explicit error handling
if twine upload dist/*; then
    print_success "Upload successful!"
    echo ""
    
    echo -e "${GREEN}Package uploaded successfully to PyPI!${NC}"
    echo ""
    echo -e "${YELLOW}View your package at:${NC}"
    echo "  https://pypi.org/project/robotframework-jsonlib/"
    echo ""
    echo -e "${YELLOW}Your package will be available for installation in a few minutes:${NC}"
    echo "  pip install robotframework-jsonlib"
    echo ""
    echo -e "${YELLOW}To install this specific version:${NC}"
    echo "  pip install robotframework-jsonlib==$VERSION"
    echo ""
else
    print_error "Upload failed"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "  1. This version may already exist on PyPI (versions cannot be re-uploaded)"
    echo "  2. Check your credentials in ~/.pypirc"
    echo "  3. Ensure you have a PyPI account: https://pypi.org/account/register/"
    echo "  4. Verify your API token has upload permissions"
    echo ""
    echo -e "${YELLOW}For testing, use TestPyPI first:${NC}"
    echo "  ./run_testpypi_upload.sh"
    echo ""
    exit 1
fi

# ================================
# Post-Upload Instructions
# ================================
echo -e "${GREEN}PyPI Upload Complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Verify package: https://pypi.org/project/robotframework-jsonlib/$VERSION/"
echo "  2. Test installation: pip install robotframework-jsonlib==$VERSION"
echo ""
echo -e "${YELLOW}Note: Virtual environment is still active (.venv)${NC}"
echo -e "${YELLOW}To deactivate, run: deactivate${NC}"

