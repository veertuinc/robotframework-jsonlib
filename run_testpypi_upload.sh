#!/bin/bash

# TestPyPI Upload Script for robotframework-jsonlib
# Tests the package upload process using TestPyPI
#
# Prerequisites:
#   1. Register an account at https://test.pypi.org/account/register/
#   2. Generate an API token at https://test.pypi.org/manage/account/token/
#   3. Configure ~/.pypirc with:
#      [testpypi]
#      username = __token__
#      password = <your TestPyPI API Token>
#
# Usage:
#   ./run_testpypi_upload.sh           # Build and upload to TestPyPI
#   ./run_testpypi_upload.sh --no-build # Skip building (use existing dist/)
#   ./run_testpypi_upload.sh --verify   # Also test installation from TestPyPI

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
VERIFY_INSTALL=true

for arg in "$@"; do
    case $arg in
        --no-build)
            SKIP_BUILD=true
            shift
            ;;
        --verify)
            VERIFY_INSTALL=true
            shift
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--no-build] [--verify]"
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
# Upload to TestPyPI
# ================================
echo -e "${BLUE}Uploading to TestPyPI...${NC}"
echo ""

print_info "Checking .pypirc configuration..."
if [ ! -f ~/.pypirc ]; then
    print_warning "~/.pypirc not found"
    echo ""
    echo -e "${YELLOW}To avoid entering credentials each time, create ~/.pypirc with:${NC}"
    echo ""
    echo "[testpypi]"
    echo "username = __token__"
    echo "password = <your TestPyPI API Token>"
    echo ""
    echo -e "${YELLOW}Get your token at: https://test.pypi.org/manage/account/token/${NC}"
    echo ""
elif ! grep -q "\[testpypi\]" ~/.pypirc; then
    print_warning "TestPyPI not configured in ~/.pypirc"
    echo ""
    echo -e "${YELLOW}Add this section to ~/.pypirc:${NC}"
    echo ""
    echo "[testpypi]"
    echo "username = __token__"
    echo "password = <your TestPyPI API Token>"
    echo ""
    echo -e "${YELLOW}Get your token at: https://test.pypi.org/manage/account/token/${NC}"
    echo ""
else
    print_success "Found TestPyPI configuration in ~/.pypirc"
fi

print_info "Uploading to TestPyPI..."
echo ""

# Upload with explicit error handling
if twine upload --verbose --repository testpypi dist/*; then
    print_success "Upload successful!"
    echo ""
    
    # Extract version from dist filename (compatible with both GNU and BSD)
    VERSION=$(ls dist/*.whl | head -1 | sed -E 's/.*-([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || echo "unknown")
    
    echo -e "${GREEN}Package uploaded successfully!${NC}"
    echo ""
    echo -e "${YELLOW}View your package at:${NC}"
    echo "  https://test.pypi.org/project/robotframework-jsonlib/"
    echo ""
else
    print_error "Upload failed"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "  1. This version may already exist on TestPyPI"
    echo "  2. Check your credentials in ~/.pypirc"
    echo ""
    exit 1
fi

# ================================
# Verify Installation (if --verify flag)
# ================================
if [ "$VERIFY_INSTALL" = true ]; then
    echo -e "${BLUE}Verifying Installation from TestPyPI...${NC}"
    echo ""
    
    print_info "Creating temporary test environment..."
    TEST_VENV=".venv_testpypi_verify"
    rm -rf "$TEST_VENV"
    python -m venv "$TEST_VENV"
    source "$TEST_VENV/bin/activate"
    
    print_info "Installing from TestPyPI..."
    echo ""
    
    # Install from TestPyPI with PyPI as fallback for dependencies
    if pip install --index-url https://test.pypi.org/simple/ \
                   --extra-index-url https://pypi.org/simple/ \
                   robotframework-jsonlib; then
        echo ""
        print_success "Installation successful"
        
    print_info "Testing Python import..."
    python -c "from JSONLib import JSONLib; print('✓ Package imports correctly')"
    python -c "from JSONLib.__version__ import __version__; print(f'✓ Version: {__version__}')"
    print_success "Python import test passed"
    
    echo ""
    print_info "Creating Robot Framework test in /tmp..."
    
    # Create test directory
    TEST_DIR="/tmp/robotframework_jsonlib_testpypi_verify_$$"
    mkdir -p "$TEST_DIR"
    
    # Create test JSON file
    cat > "$TEST_DIR/test.json" << 'EOF'
{
    "name": "TestPyPI Verification",
    "version": "1.0.0",
    "features": ["json", "jsonpath", "jsonschema"],
    "metadata": {
        "author": "Test User",
        "verified": false
    }
}
EOF
    
    # Create JSON schema file
    cat > "$TEST_DIR/test_schema.json" << 'EOF'
{
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "version": {"type": "string"},
        "features": {"type": "array"},
        "metadata": {"type": "object"}
    },
    "required": ["name", "version"]
}
EOF
    
    # Create Robot Framework test
    cat > "$TEST_DIR/verify_jsonlib.robot" << 'EOF'
*** Settings ***
Library    JSONLib

*** Test Cases ***
Verify JSON Loading
    [Documentation]    Test loading JSON from file
    ${json}=    Load Json From File    ${CURDIR}/test.json
    Should Not Be Equal    ${json}    ${None}
    Log    ✓ JSON loaded successfully

Verify Get Value From JSON
    [Documentation]    Test getting values using JSONPath
    ${json}=    Load Json From File    ${CURDIR}/test.json
    ${name}=    Get Value From Json    ${json}    $.name
    Should Be Equal As Strings    ${name[0]}    TestPyPI Verification
    ${features}=    Get Value From Json    ${json}    $.features
    Length Should Be    ${features[0]}    3
    Log    ✓ Get value works correctly

Verify Update Value
    [Documentation]    Test updating JSON values
    ${json}=    Load Json From File    ${CURDIR}/test.json
    ${json}=    Update Value To Json    ${json}    $.metadata.verified    ${True}
    ${verified}=    Get Value From Json    ${json}    $.metadata.verified
    Should Be True    ${verified[0]}
    Log    ✓ Update value works correctly

Verify Add Object
    [Documentation]    Test adding objects to JSON
    ${json}=    Load Json From File    ${CURDIR}/test.json
    ${new_data}=    Create Dictionary    test=success    timestamp=2024-01-01
    ${json}=    Add Object To Json    ${json}    $.metadata    ${new_data}
    ${test_value}=    Get Value From Json    ${json}    $.metadata.test
    Should Be Equal As Strings    ${test_value[0]}    success
    Log    ✓ Add object works correctly

Verify JSON Schema Validation
    [Documentation]    Test JSON schema validation
    ${json}=    Load Json From File    ${CURDIR}/test.json
    Validate Json By Schema File    ${json}    ${CURDIR}/test_schema.json
    Log    ✓ Schema validation works correctly

Verify Convert JSON To String
    [Documentation]    Test converting JSON to string
    ${json}=    Load Json From File    ${CURDIR}/test.json
    ${json_string}=    Convert Json To String    ${json}
    Should Contain    ${json_string}    TestPyPI Verification
    Log    ✓ JSON to string conversion works correctly
EOF
    
    print_success "Test files created in $TEST_DIR"
    
    echo ""
    print_info "Running Robot Framework test..."
    echo ""
    
    # Run Robot Framework test
    if robot -d "$TEST_DIR/results" "$TEST_DIR/verify_jsonlib.robot"; then
        echo ""
        print_success "Robot Framework test passed!"
        
        echo ""
        echo -e "${GREEN}Test Results:${NC}"
        robot --version
        echo ""
        echo -e "${YELLOW}Test output available at:${NC}"
        echo "  Report: $TEST_DIR/results/report.html"
        echo "  Log:    $TEST_DIR/results/log.html"
        echo ""
        
        # Show test summary
        if [ -f "$TEST_DIR/results/output.xml" ]; then
            echo -e "${GREEN}All Robot Framework tests passed successfully!${NC}"
        fi
    else
        print_error "Robot Framework test failed!"
        echo ""
        echo -e "${YELLOW}Test output available at:${NC}"
        echo "  Report: $TEST_DIR/results/report.html"
        echo "  Log:    $TEST_DIR/results/log.html"
        echo ""
        echo -e "${YELLOW}Test directory preserved for inspection: $TEST_DIR${NC}"
        
        # Don't cleanup on failure
        deactivate
        source "$VENV_DIR/bin/activate"
        echo ""
        echo -e "${RED}TestPyPI package verification failed!${NC}"
        exit 1
    fi
    
    # Cleanup test directory on success
    print_info "Cleaning up test directory..."
    rm -rf "$TEST_DIR"
    
    echo ""
    echo -e "${GREEN}TestPyPI package verified successfully!${NC}"
    else
        print_error "Installation from TestPyPI failed"
        echo ""
        echo -e "${YELLOW}Note: It may take a few minutes for the package to become available${NC}"
        echo "      after uploading. Try again in a moment."
    fi
    
    # Cleanup
    deactivate
    rm -rf "$TEST_VENV"
    source "$VENV_DIR/bin/activate"
    echo ""
fi

# ================================
# Summary
# ================================
echo -e "${GREEN}TestPyPI Upload Complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. View your package: https://test.pypi.org/project/robotframework-jsonlib/"
echo ""
echo -e "${YELLOW}When ready for production PyPI:${NC}"
echo "  twine upload dist/*"
echo ""
echo -e "${YELLOW}Note: Virtual environment is still active (.venv)${NC}"
echo -e "${YELLOW}To deactivate, run: deactivate${NC}"

