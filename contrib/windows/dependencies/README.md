# Dependencies Directory

This directory should contain third-party dependencies required for the Windows installer.

**Note:** These files are not included in the git repository due to their size. You must download and prepare them before building the installer.

## Required Directory Structure

```
dependencies/
├── postgresql/          # PostgreSQL 16 portable binaries
│   ├── bin/
│   ├── lib/
│   ├── share/
│   └── include/
├── python/             # Python 3.12 embeddable package
│   ├── python.exe
│   ├── python312.dll
│   ├── python312.zip
│   └── python312._pth
├── xerces-c/           # Xerces-C XML parser library
│   └── bin/
│       └── xerces-c_*.dll
├── libpq/              # PostgreSQL client library
│   └── bin/
│       ├── libpq.dll
│       └── *.dll (dependencies)
└── vcredist/           # Visual C++ Redistributable (optional)
    └── vc_redist.x64.exe
```

## Download Links

### PostgreSQL 16 Binaries
- Source: https://www.enterprisedb.com/download-postgresql-binaries
- Version: PostgreSQL 16.x Windows x64 binaries
- Extract the entire package to `postgresql/`

### Python 3.12 Embeddable
- Source: https://www.python.org/downloads/windows/
- File: Windows embeddable package (64-bit)
- Direct link: https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
- Extract to `python/`

### Xerces-C 3.2.3
- Source: https://xerces.apache.org/xerces-c/download.cgi
- Download Windows binaries or build from source
- Copy DLLs to `xerces-c/bin/`

### PostgreSQL Client Library (libpq)
- Included in PostgreSQL binaries
- Copy from `postgresql/bin/`:
  - libpq.dll
  - All dependent DLLs (crypto, ssl, intl, iconv, etc.)
- Place in `libpq/bin/`

### Visual C++ Redistributable (Optional)
- Source: https://aka.ms/vs/17/release/vc_redist.x64.exe
- Place in `vcredist/` if you want to bundle it

## Preparation Script

You can automate downloading and extracting with this PowerShell script:

```powershell
# Download-Dependencies.ps1
$depsDir = "dependencies"

# Create directories
New-Item -ItemType Directory -Force -Path "$depsDir/postgresql"
New-Item -ItemType Directory -Force -Path "$depsDir/python"
New-Item -ItemType Directory -Force -Path "$depsDir/xerces-c/bin"
New-Item -ItemType Directory -Force -Path "$depsDir/libpq/bin"

Write-Host "Please manually download and extract:"
Write-Host "1. PostgreSQL binaries to $depsDir/postgresql/"
Write-Host "2. Python embeddable to $depsDir/python/"
Write-Host "3. Xerces-C DLLs to $depsDir/xerces-c/bin/"
Write-Host "4. libpq DLLs to $depsDir/libpq/bin/"
```

## Verification

Before building the installer, verify all dependencies are in place:

```powershell
# Verify-Dependencies.ps1
$required = @(
    "dependencies/postgresql/bin/postgres.exe",
    "dependencies/postgresql/bin/psql.exe",
    "dependencies/postgresql/bin/pg_ctl.exe",
    "dependencies/postgresql/bin/initdb.exe",
    "dependencies/python/python.exe",
    "dependencies/python/python312.dll",
    "dependencies/xerces-c/bin/xerces-c_3_2.dll",
    "dependencies/libpq/bin/libpq.dll"
)

$missing = @()
foreach ($file in $required) {
    if (-not (Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing required files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" }
    exit 1
} else {
    Write-Host "All required dependencies are present!" -ForegroundColor Green
}
```

## Notes

- Keep these files up to date with latest stable versions
- Test the installer after updating any dependency
- Document version numbers in BUILD.md
- Consider using a separate repository or CDN for storing these binaries
