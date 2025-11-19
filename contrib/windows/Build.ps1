# Quick Build Script for FrePPLe
# Uses MSYS64 Python since it's already installed

Write-Host "=== Building FrePPLe ===" -ForegroundColor Cyan
Write-Host ""

# Use MSYS64 Python
$pythonExe = "C:\msys64\ucrt64\bin\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Host "ERROR: Python not found at $pythonExe" -ForegroundColor Red
    exit 1
}

$pythonVersion = & $pythonExe --version
Write-Host "Using: $pythonVersion from MSYS64" -ForegroundColor Green
Write-Host ""

# Create build directory
if (-not (Test-Path ".\build")) {
    Write-Host "Creating build directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path ".\build" | Out-Null
}

Set-Location ".\build"

Write-Host "Running CMake configuration..." -ForegroundColor Yellow
Write-Host "(This may take a few minutes on first run)" -ForegroundColor Gray
Write-Host ""

# Configure with CMake
cmake .. -G "Visual Studio 17 2022" -A x64 `
    -DPython3_EXECUTABLE="$pythonExe"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "Configuration successful!" -ForegroundColor Green
Write-Host ""
Write-Host "Now building FrePPLe (Release configuration)..." -ForegroundColor Yellow
Write-Host "This will take several minutes..." -ForegroundColor Gray
Write-Host ""

# Build
cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host ""
Write-Host "=== Build Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Binaries are in: .\bin\" -ForegroundColor Cyan
Write-Host "  - frepple.exe" -ForegroundColor Gray
Write-Host "  - frepple.dll" -ForegroundColor Gray
Write-Host ""

# Check if dependencies are ready for installer
$hasDeps = (Test-Path "..\contrib\windows\dependencies\postgresql\bin\postgres.exe") -and `
           (Test-Path "..\contrib\windows\dependencies\python\python.exe")

if ($hasDeps) {
    Write-Host "Dependencies are ready! You can now build the installer:" -ForegroundColor Green
    Write-Host "  cmake --build . --config Release --target windows_installer" -ForegroundColor White
} else {
    Write-Host "To build the full installer, you need to prepare dependencies:" -ForegroundColor Yellow
    Write-Host "  1. Download PostgreSQL 16 portable binaries" -ForegroundColor Gray
    Write-Host "  2. Download Python 3.12 embeddable package" -ForegroundColor Gray
    Write-Host "  3. See: contrib\windows\dependencies\README.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "You can still test the installer script without full dependencies." -ForegroundColor Cyan
}

Set-Location ..
Write-Host ""
