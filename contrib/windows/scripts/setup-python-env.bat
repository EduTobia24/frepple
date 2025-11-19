@echo off
REM Setup Python virtual environment and install dependencies

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1
set PYTHON_DIR=%INSTALL_DIR%\python
set VENV_DIR=%INSTALL_DIR%\venv
set REQUIREMENTS=%INSTALL_DIR%\share\frepple\requirements.txt

echo Setting up Python environment...
echo Install directory: %INSTALL_DIR%
echo Python directory: %PYTHON_DIR%
echo Virtual environment: %VENV_DIR%

REM Check if Python exists
if not exist "%PYTHON_DIR%\python.exe" (
    echo ERROR: Python not found at %PYTHON_DIR%
    exit /b 1
)

REM Create virtual environment
if not exist "%VENV_DIR%" (
    echo Creating virtual environment...
    "%PYTHON_DIR%\python.exe" -m venv "%VENV_DIR%"
    if %errorlevel% neq 0 (
        echo Failed to create virtual environment.
        exit /b 1
    )
)

REM Activate virtual environment and upgrade pip
echo Upgrading pip...
call "%VENV_DIR%\Scripts\activate.bat"
python -m pip install --upgrade pip setuptools wheel
if %errorlevel% neq 0 (
    echo Failed to upgrade pip.
    exit /b 1
)

REM Install requirements
if exist "%REQUIREMENTS%" (
    echo Installing Python packages from requirements.txt...
    echo This may take several minutes...
    pip install -r "%REQUIREMENTS%" --no-warn-script-location
    if %errorlevel% neq 0 (
        echo Failed to install Python packages.
        exit /b 1
    )
) else (
    echo WARNING: requirements.txt not found at %REQUIREMENTS%
)

REM Install freppledb package
echo Installing FrePPLe Python package...
cd "%INSTALL_DIR%\share\frepple"
pip install -e . --no-warn-script-location
if %errorlevel% neq 0 (
    echo Failed to install FrePPLe package.
    exit /b 1
)

REM Add Python and Scripts to PATH (already in registry, but set for current session)
set PATH=%VENV_DIR%\Scripts;%PYTHON_DIR%;%PATH%

echo Python environment setup complete.
exit /b 0
