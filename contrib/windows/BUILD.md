# FrePPLe Windows Installer Build Instructions

This directory contains the Inno Setup script and supporting files to create a Windows installer for FrePPLe.

## Prerequisites

### Software Requirements
1. **Inno Setup 6.x** - Download from https://jrsoftware.org/isdl.php
2. **CMake 3.16+** - For building FrePPLe
3. **Visual Studio 2019/2022** - With C++ development tools
4. **Python 3.12** - For building and testing
5. **Git** - For version control

### Dependencies to Prepare

Before building the installer, you need to prepare the following dependencies:

#### 1. PostgreSQL Portable (Required)
Download PostgreSQL 16 binaries from EnterpriseDB:
```
https://www.enterprisedb.com/download-postgresql-binaries
```
Extract to: `contrib/windows/dependencies/postgresql/`

Required structure:
```
dependencies/postgresql/
├── bin/
│   ├── postgres.exe
│   ├── psql.exe
│   ├── pg_ctl.exe
│   ├── initdb.exe
│   └── *.dll
├── lib/
└── share/
```

#### 2. Python Embeddable Package (Required)
Download Python 3.12 embeddable package:
```
https://www.python.org/downloads/windows/
```
Look for "Windows embeddable package (64-bit)"
Extract to: `contrib/windows/dependencies/python/`

Then modify `python312._pth` to enable site-packages:
```
python312.zip
.
import site
```

#### 3. Xerces-C Library (Required)
Download xerces-c from: https://xerces.apache.org/xerces-c/
Or build from source.
Place DLLs in: `contrib/windows/dependencies/xerces-c/bin/`

#### 4. PostgreSQL Client Library (Required)
Extract libpq DLLs from PostgreSQL installation.
Place in: `contrib/windows/dependencies/libpq/bin/`
Required files:
- libpq.dll
- libcrypto-*.dll
- libssl-*.dll
- libiconv-*.dll
- libintl-*.dll

#### 5. NSSM (Optional but Recommended)
Download NSSM (Non-Sucking Service Manager):
```
https://nssm.cc/download
```
Place `nssm.exe` (64-bit) in: `contrib/windows/scripts/`

## Building FrePPLe

1. **Build the C++ components:**
```powershell
# Create build directory
mkdir build
cd build

# Configure with CMake
cmake .. -G "Visual Studio 17 2022" -A x64

# Build Release version
cmake --build . --config Release

# Binaries will be in: bin/frepple.exe and bin/frepple.dll
```

2. **Prepare Python environment:**
```powershell
# Create virtual environment for building
python -m venv venv
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Collect static files
$env:FREPPLE_STATIC=".\static"
python frepplectl.py collectstatic --noinput --clear
```

## Building the Installer

### Method 1: Using Inno Setup Compiler GUI

1. Open `contrib/windows/frepple-installer.iss` in Inno Setup Compiler
2. Click **Build > Compile**
3. Installer will be created in: `build/windows/frepple-9.13.0-win64-setup.exe`

### Method 2: Using Command Line

```powershell
# Compile the installer
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" contrib\windows\frepple-installer.iss
```

### Method 3: Using CMake (Recommended)

Add to root CMakeLists.txt:
```cmake
if(WIN32)
  find_program(INNO_SETUP NAMES ISCC.exe 
    PATHS "C:/Program Files (x86)/Inno Setup 6")
  
  if(INNO_SETUP)
    add_custom_target(windows_installer
      COMMAND ${INNO_SETUP} "${CMAKE_SOURCE_DIR}/contrib/windows/frepple-installer.iss"
      WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
      COMMENT "Building Windows installer..."
    )
  endif()
endif()
```

Then build with:
```powershell
cmake --build . --target windows_installer
```

## Directory Structure

```
contrib/windows/
├── frepple-installer.iss     # Main Inno Setup script
├── README.txt                 # User-facing readme for installer
├── BUILD.md                   # This file
├── scripts/                   # Installation scripts
│   ├── init-postgresql.bat
│   ├── setup-python-env.bat
│   ├── init-frepple-db.bat
│   ├── install-service.bat
│   ├── uninstall-service.bat
│   ├── start-frepple.bat
│   ├── stop-frepple.bat
│   ├── stop-postgresql.bat
│   └── install-vcredist.bat
└── dependencies/              # Third-party dependencies (not in git)
    ├── postgresql/
    ├── python/
    ├── xerces-c/
    └── libpq/
```

## Testing the Installer

1. **Test in a clean VM:**
   - Use Windows 10/11 VM without any development tools
   - Install and verify all features work

2. **Test scenarios:**
   - Fresh installation
   - Installation with existing PostgreSQL
   - Custom port configuration
   - Service startup and shutdown
   - Uninstallation (with and without data)

3. **Check installation:**
   - Services are created and start automatically
   - Web interface accessible at http://localhost:8000
   - Can log in with admin credentials
   - Database migrations completed successfully
   - Static files served correctly

## Common Issues

### Issue: PostgreSQL fails to initialize
**Solution:** Ensure PostgreSQL binaries are complete and the data directory has write permissions.

### Issue: Python packages fail to install
**Solution:** Check internet connection or pre-download wheels and modify setup script.

### Issue: Service won't start
**Solution:** Check logs in `[InstallDir]\logs\` for error messages.

### Issue: Port already in use
**Solution:** User can change port during installation or modify djangosettings.py after.

## Creating Portable Version

To create a portable (non-service) version:
1. Modify installer script to skip service installation
2. Create `start-frepple-portable.bat`:
```batch
@echo off
cd "%~dp0"
start pgsql\bin\pg_ctl.exe -D pgsql\data -l logs\postgresql.log start
timeout /t 5
call venv\Scripts\activate.bat
python bin\frepplectl.py runserver 0.0.0.0:8000
```

## Code Signing (Optional)

For distribution, sign the installer:
```powershell
signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com frepple-setup.exe
```

## Automating Builds

Create a GitHub Actions workflow or Jenkins job:
```yaml
- name: Build Windows Installer
  run: |
    cmake --build . --config Release
    cmake --build . --target windows_installer
```

## Distribution

Upload the installer to:
- GitHub Releases: https://github.com/frePPLe/frepple/releases
- Website: https://frepple.com/download
- Include SHA256 checksum for verification

## Support

For issues with the installer build process:
- GitHub Issues: https://github.com/frePPLe/frepple/issues
- Label: `installer` and `windows`
