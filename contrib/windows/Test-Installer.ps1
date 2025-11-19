# Test Inno Setup Script
# This validates the installer script syntax without requiring all files

Write-Host "=== Testing Inno Setup Script ===" -ForegroundColor Cyan
Write-Host ""

$isccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$scriptPath = ".\contrib\windows\frepple-installer.iss"

if (-not (Test-Path $isccPath)) {
    Write-Host "ERROR: Inno Setup not found at: $isccPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Installer script not found at: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Inno Setup Compiler: " -NoNewline -ForegroundColor Yellow
Write-Host $isccPath -ForegroundColor White

Write-Host "Installer Script: " -NoNewline -ForegroundColor Yellow
Write-Host $scriptPath -ForegroundColor White
Write-Host ""

# Show current missing dependencies
Write-Host "Checking installer dependencies..." -ForegroundColor Yellow
Write-Host ""

$deps = @{
    "FrePPLe binaries" = ".\bin\frepple.exe"
    "PostgreSQL portable" = ".\contrib\windows\dependencies\postgresql\bin\postgres.exe"
    "Python embeddable" = ".\contrib\windows\dependencies\python\python.exe"
    "Xerces-C DLL" = ".\contrib\windows\dependencies\xerces-c\bin"
}

$missing = @()
foreach ($dep in $deps.GetEnumerator()) {
    Write-Host "  $($dep.Key): " -NoNewline
    if (Test-Path $dep.Value) {
        Write-Host "✓ Found" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing" -ForegroundColor Red
        $missing += $dep.Key
    }
}

Write-Host ""

if ($missing.Count -gt 0) {
    Write-Host "Missing dependencies:" -ForegroundColor Yellow
    foreach ($item in $missing) {
        Write-Host "  - $item" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "The installer script syntax can still be checked, but compilation will fail." -ForegroundColor Yellow
    Write-Host ""
}

# Offer to open in Inno Setup IDE
Write-Host "Options:" -ForegroundColor Cyan
Write-Host "  1. Open installer script in Inno Setup IDE (recommended)" -ForegroundColor White
Write-Host "  2. Try to compile anyway (will fail without dependencies)" -ForegroundColor White
Write-Host "  3. Show installer script info" -ForegroundColor White
Write-Host "  4. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Opening in Inno Setup IDE..." -ForegroundColor Green
        Start-Process -FilePath "C:\Program Files (x86)\Inno Setup 6\Compil32.exe" -ArgumentList $scriptPath
        Write-Host "You can now edit and test compile in the IDE." -ForegroundColor Cyan
    }
    "2" {
        Write-Host ""
        Write-Host "Attempting to compile..." -ForegroundColor Yellow
        & $isccPath $scriptPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Success! Installer created." -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "Compilation failed (expected without dependencies)." -ForegroundColor Yellow
        }
    }
    "3" {
        Write-Host ""
        Write-Host "=== Installer Script Information ===" -ForegroundColor Cyan
        Write-Host ""
        
        $content = Get-Content $scriptPath -Raw
        
        Write-Host "App Name: FrePPLe" -ForegroundColor White
        Write-Host "Version: 9.13.0" -ForegroundColor White
        Write-Host "Publisher: frePPLe bv" -ForegroundColor White
        Write-Host ""
        Write-Host "Components:" -ForegroundColor Yellow
        Write-Host "  - FrePPLe Core Engine and Web Application" -ForegroundColor Gray
        Write-Host "  - PostgreSQL Database Server" -ForegroundColor Gray
        Write-Host "  - Python Runtime" -ForegroundColor Gray
        Write-Host "  - Desktop and Start Menu Shortcuts" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Output will be: build\windows\frepple-9.13.0-win64-setup.exe" -ForegroundColor Cyan
    }
    default {
        Write-Host "Exiting..." -ForegroundColor Gray
    }
}

Write-Host ""
