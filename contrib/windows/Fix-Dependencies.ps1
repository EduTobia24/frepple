# Fix Dependencies Structure
# This script helps reorganize the downloaded dependencies

$ErrorActionPreference = "Stop"
$depPath = ".\contrib\windows\dependencies"

Write-Host "`n=== Dependency Structure Fix ===" -ForegroundColor Cyan
Write-Host ""

# 1. Fix Python
Write-Host "1. Fixing Python..." -ForegroundColor Yellow
if (Test-Path "$depPath\postgresql\python\python.exe") {
    Write-Host "   Found Python in wrong location (postgresql\python), moving..."
    if (-not (Test-Path "$depPath\python")) {
        New-Item -ItemType Directory "$depPath\python" -Force | Out-Null
    }
    Move-Item "$depPath\postgresql\python\*" "$depPath\python\" -Force
    Remove-Item "$depPath\postgresql\python" -Recurse -Force
    Write-Host "   ✓ Python moved to correct location" -ForegroundColor Green
} elseif (Test-Path "$depPath\python\python.exe") {
    Write-Host "   ✓ Python already in correct location" -ForegroundColor Green
} else {
    Write-Host "   ✗ Python not found! Please extract python-3.12.7-embed-amd64.zip to dependencies\python\" -ForegroundColor Red
}

# 2. Fix PostgreSQL
Write-Host "`n2. Checking PostgreSQL..." -ForegroundColor Yellow
if (Test-Path "$depPath\postgresql\bin\postgres.exe") {
    Write-Host "   ✓ PostgreSQL already in correct location" -ForegroundColor Green
} else {
    Write-Host "   ✗ PostgreSQL binaries not found!" -ForegroundColor Red
    Write-Host "   Expected: $depPath\postgresql\bin\postgres.exe" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   The PostgreSQL download should have a 'pgsql' folder with bin, lib, share, include" -ForegroundColor Yellow
    Write-Host "   Please extract postgresql-18.1-1-windows-x64-binaries.zip" -ForegroundColor Yellow
    Write-Host "   Then move everything from the 'pgsql' folder to: $depPath\postgresql\" -ForegroundColor Yellow
}

# 3. Fix Xerces-C
Write-Host "`n3. Checking Xerces-C..." -ForegroundColor Yellow
if (Test-Path "$depPath\xerces-c\bin\*.dll") {
    Write-Host "   ✓ Xerces-C already in correct location" -ForegroundColor Green
} elseif (Test-Path "$depPath\xerces-c\xerces-c-3.3.0") {
    Write-Host "   Found Xerces-C in nested folder, moving..."
    Get-ChildItem "$depPath\xerces-c\xerces-c-3.3.0" | Move-Item -Destination "$depPath\xerces-c\" -Force
    Remove-Item "$depPath\xerces-c\xerces-c-3.3.0" -Recurse -Force
    Write-Host "   ✓ Xerces-C moved to correct location" -ForegroundColor Green
} else {
    Write-Host "   ✗ Xerces-C not found! Please extract xerces-c-3.3.0.zip to dependencies\xerces-c\" -ForegroundColor Red
}

# 4. Copy libpq DLLs
Write-Host "`n4. Creating libpq folder..." -ForegroundColor Yellow
if (Test-Path "$depPath\postgresql\bin\libpq.dll") {
    New-Item -ItemType Directory "$depPath\libpq\bin" -Force | Out-Null
    Copy-Item "$depPath\postgresql\bin\*.dll" "$depPath\libpq\bin\" -Force
    Write-Host "   ✓ Copied libpq DLLs" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Skipped (PostgreSQL not ready)" -ForegroundColor Yellow
}

# Final verification
Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Cyan
Write-Host ""

$checks = @{
    "PostgreSQL" = "$depPath\postgresql\bin\postgres.exe"
    "Python" = "$depPath\python\python.exe"
    "Xerces-C" = "$depPath\xerces-c\bin\*.dll"
    "libpq" = "$depPath\libpq\bin\libpq.dll"
}

$allGood = $true
foreach ($item in $checks.GetEnumerator()) {
    Write-Host "$($item.Key): " -NoNewline
    if (Test-Path $item.Value) {
        Write-Host "✓ READY" -ForegroundColor Green
    } else {
        Write-Host "✗ MISSING" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""
if ($allGood) {
    Write-Host "✓ All dependencies ready! You can now build the installer." -ForegroundColor Green
} else {
    Write-Host "⚠ Some dependencies are missing. Please extract the files as shown above." -ForegroundColor Yellow
}
