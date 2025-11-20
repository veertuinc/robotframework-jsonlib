# Development Guide

This guide is for contributors and maintainers of `robotframework-jsonlib`.

## Quick Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `run_ci_checks.sh` | Full CI validation (linting, tests, build) | `./run_ci_checks.sh` |
| `run_tests_only.sh` | Fast test iteration | `./run_tests_only.sh` |
| `run_build_only.sh` | Build and verify package | `./run_build_only.sh` |
| `run_testpypi_upload.sh` | Upload to TestPyPI for testing | `./run_testpypi_upload.sh` |
| `run_pypi_upload.sh` | Upload to production PyPI | `./run_pypi_upload.sh` |

All development scripts automatically create and use a Python virtual environment (`.venv`) to isolate dependencies.

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/veertuinc/robotframework-jsonlib.git
   cd robotframework-jsonlib
   ```

2. The scripts will automatically create a virtual environment on first run.

## Running CI Checks Locally

### Full CI Validation

To run all the CI validation checks locally (same as what runs in GitHub Actions):

```bash
./run_ci_checks.sh
```

This script will:
1. Create/activate a virtual environment
2. Install dependencies
3. Run pylint
4. Generate documentation
5. Check code formatting with black
6. Run flake8 linting
7. Run pytest with coverage
8. Run Robot Framework acceptance tests
9. Build and verify the package for PyPI

### Running Tests Only

For faster iteration during development, you can run just the tests:

```bash
./run_tests_only.sh
```

This will:
- Run pytest with coverage
- Generate coverage reports (HTML and XML)
- Run Robot Framework acceptance tests

### Building the Package

To build and verify the package for PyPI distribution:

```bash
./run_build_only.sh
```

This will:
- Clean previous builds
- Build source distribution and wheel
- Verify package with twine
- Test package installation

## Publishing

### Testing with TestPyPI

Before publishing to the production PyPI, it's recommended to test with TestPyPI:

```bash
./run_testpypi_upload.sh
```

This script will:
- Build the package (if needed)
- Upload to TestPyPI
- Provide instructions for testing installation
- Optionally verify the installation with Robot Framework tests

**Prerequisites:**
1. Register at [https://test.pypi.org/account/register/](https://test.pypi.org/account/register/)
2. Generate an API token at [https://test.pypi.org/manage/account/token/](https://test.pypi.org/manage/account/token/)
3. Configure `~/.pypirc`:
   ```ini
   [testpypi]
   username = __token__
   password = <your TestPyPI API Token>
   ```

**Options:**
- `--no-build` - Skip building, use existing dist/ files
- `--verify` - Test installation from TestPyPI and run Robot Framework verification tests

### Publishing to Production PyPI

After testing with TestPyPI, publish to production PyPI using the upload script:

```bash
./run_pypi_upload.sh
```

This script will:
- Build the package (if needed)
- Prompt for confirmation before uploading
- Upload to production PyPI
- Provide next steps and installation instructions

**Prerequisites:**
1. Register at [https://pypi.org/account/register/](https://pypi.org/account/register/)
2. Generate an API token at [https://pypi.org/manage/account/token/](https://pypi.org/manage/account/token/)
3. Configure `~/.pypirc`:
   ```ini
   [pypi]
   username = __token__
   password = <your PyPI API Token>
   ```

**Options:**
- `--no-build` - Skip building, use existing dist/ files

**Alternative:** You can also use twine directly:
```bash
twine upload dist/*
```

## Virtual Environment

The virtual environment will remain active after the scripts complete. To deactivate it:

```bash
deactivate
```

## Project Structure

```
robotframework-jsonlib/
├── JSONLib/              # Main library package
│   ├── __init__.py
│   ├── __version__.py
│   └── jsonlib.py       # Core library implementation
├── tests/               # Unit tests
│   ├── json/           # Test JSON files
│   └── test_JSONLib.py
├── acceptance/          # Acceptance tests
│   └── JSONLib.robot
├── docs/               # Generated documentation
├── run_*.sh            # Development scripts
├── pyproject.toml      # Project configuration
├── setup.py           # Build configuration
└── README.md          # User documentation
```

## Code Quality

The CI checks enforce:
- **pylint**: Static code analysis (errors only, R/C disabled)
- **black**: Code formatting
- **flake8**: Style guide enforcement
- **pytest**: Unit test coverage (target: 97%+)
- **Robot Framework**: Acceptance tests

## Making Changes

1. Create a new branch for your changes
2. Make your modifications
3. Run `./run_ci_checks.sh` to verify all checks pass
4. Update version in `JSONLib/__version__.py` if needed
5. Update documentation if adding new keywords
6. Submit a pull request

## Generating Documentation

Documentation is automatically generated from docstrings:

```bash
python -m robot.libdoc JSONLib docs/index.html
```

This is included in `./run_ci_checks.sh`.

## Testing Tips

- Use `./run_tests_only.sh` for fast iteration during development
- Coverage reports are in `tests/__out__/coverage/html/index.html`
- Robot Framework logs are in `tests/__out__/robot/`
- The test suite uses JSON files in `tests/json/` directory

## Release Process

1. Update version in `JSONLib/__version__.py`
2. Run full CI checks: `./run_ci_checks.sh`
3. Test on TestPyPI: `./run_testpypi_upload.sh --verify`
4. Publish to PyPI: `twine upload dist/*`
5. Create GitHub release with tag

## Help & Support

- **Issues**: [GitHub Issues](https://github.com/veertuinc/robotframework-jsonlib/issues)
- **Discussions**: [GitHub Discussions](https://github.com/veertuinc/robotframework-jsonlib/discussions)
- **CI Status**: Check GitHub Actions for build status

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Ensure all CI checks pass
5. Submit a pull request

For major changes, please open an issue first to discuss what you would like to change.

