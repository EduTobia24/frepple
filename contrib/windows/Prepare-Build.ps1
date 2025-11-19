# FrePPLe Windows Build Preparation Script
# This script helps prepare the build environment

Write-Host "=== FrePPLe Windows Build Preparation ===" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
$issues = @()
$warnings = @()

Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# 1. Check CMake
Write-Host "  [1/6] CMake... " -NoNewline
try {
    $cmakeVersion = cmake --version 2>$null | Select-String "cmake version" | Out-String
    Write-Host "OK ($($cmakeVersion.Trim()))" -ForegroundColor Green
} catch {
    Write-Host "NOT FOUND" -ForegroundColor Red
    $issues += "CMake is not installed or not in PATH"
}

# 2. Check Visual Studio
Write-Host "  [2/6] Visual Studio... " -NoNewline
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
if (Test-Path $vsPath) {
    Write-Host "OK (VS 2022 Community)" -ForegroundColor Green
} else {
    Write-Host "NOT FOUND" -ForegroundColor Red
    $issues += "Visual Studio 2022 is not installed"
}

# 3. Check Inno Setup
Write-Host "  [3/6] Inno Setup... " -NoNewline
$innoPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if (Test-Path $innoPath) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "NOT FOUND" -ForegroundColor Red
    $issues += "Inno Setup 6 is not installed. Download from: https://jrsoftware.org/isdl.php"
}

# 4. Check Python
Write-Host "  [4/6] Python... " -NoNewline
$pythonPaths = @(
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe"
)

$pythonFound = $false
foreach ($path in $pythonPaths) {
    if (Test-Path $path) {
        $pythonExe = $path
        $pythonVersion = & $pythonExe --version 2>&1
        Write-Host "OK ($pythonVersion at $path)" -ForegroundColor Green
        $pythonFound = $true
        break
    }
}

if (-not $pythonFound) {
    Write-Host "NOT FOUND" -ForegroundColor Red
    $issues += "Python 3.8+ is not installed. Download from: https://www.python.org/downloads/"
}

# 5. Check PostgreSQL dependencies
Write-Host "  [5/6] PostgreSQL dependencies... " -NoNewline
$pgPath = ".\contrib\windows\dependencies\postgresql\bin\postgres.exe"
if (Test-Path $pgPath) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "MISSING" -ForegroundColor Yellow
    $warnings += "PostgreSQL binaries not in dependencies folder"
}

# 6. Check Python embeddable package
Write-Host "  [6/6] Python embeddable package... " -NoNewline
$pyEmbedPath = ".\contrib\windows\dependencies\python\python.exe"
if (Test-Path $pyEmbedPath) {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "MISSING" -ForegroundColor Yellow
    $warnings += "Python embeddable package not in dependencies folder"
}

Write-Host ""

# Report issues
if ($issues.Count -gt 0) {
    Write-Host "CRITICAL ISSUES FOUND:" -ForegroundColor Red
    foreach ($issue in $issues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please install the missing prerequisites before continuing." -ForegroundColor Red
    exit 1
}

if ($warnings.Count -gt 0) {
    Write-Host "WARNINGS:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "You can build FrePPLe, but won't be able to create the full installer without dependencies." -ForegroundColor Yellow
    Write-Host "See contrib/windows/dependencies/README.md for instructions." -ForegroundColor Yellow
    Write-Host ""
}

# Offer to create build directory
Write-Host "=== Build Setup ===" -ForegroundColor Cyan
Write-Host ""

if (Test-Path ".\build") {
    Write-Host "Build directory already exists." -ForegroundColor Yellow
    $response = Read-Host "Do you want to clean it and start fresh? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host "Removing old build directory..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force ".\build"
    }
}

if (-not (Test-Path ".\build")) {
    Write-Host "Creating build directory..." -ForegroundColor Green
    New-Item -ItemType Directory -Path ".\build" | Out-Null
    
    Write-Host "Running CMake configuration..." -ForegroundColor Green
    Set-Location ".\build"
    
    # Try to find MSBuild
    $msbuild = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    
    if (Test-Path $msbuild) {
        cmake .. -G "Visual Studio 17 2022" -A x64
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "=== Configuration Complete ===" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Cyan
            Write-Host "1. Build FrePPLe:" -ForegroundColor White
            Write-Host "   cmake --build . --config Release" -ForegroundColor Gray
            Write-Host ""
            Write-Host "2. (Optional) Download dependencies for full installer:" -ForegroundColor White
            Write-Host "   See contrib\windows\dependencies\README.md" -ForegroundColor Gray
            Write-Host ""
            Write-Host "3. Build the installer:" -ForegroundColor White
            Write-Host "   cmake --build . --config Release --target windows_installer" -ForegroundColor Gray
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "CMake configuration failed. Check the error messages above." -ForegroundColor Red
            Set-Location ..
            exit 1
        }
    } else {
        Write-Host "Could not find MSBuild. Please run from a Visual Studio Developer Command Prompt." -ForegroundColor Red
        Set-Location ..
        exit 1
    }
    
    Set-Location ..
} else {
    Write-Host "Build directory exists. You can now build with:" -ForegroundColor Green
    Write-Host "  cd build" -ForegroundColor Gray
    Write-Host "  cmake --build . --config Release" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Ready! ===" -ForegroundColor Green
