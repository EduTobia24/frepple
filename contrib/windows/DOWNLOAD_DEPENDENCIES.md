# Missing Dependencies - Download Links

## Summary
To build the FrePPLe Windows installer, you need to download these dependencies (~250 MB total):

## 1. PostgreSQL 16 Portable Binaries (~200 MB)

**Download:**
- URL: https://www.enterprisedb.com/download-postgresql-binaries
- Version: PostgreSQL 16.x Windows x64 binaries (NOT the installer)
- File: `postgresql-16.x-windows-x64-binaries.zip`

**Extract to:** `contrib/windows/dependencies/postgresql/`

**Should contain:**
```
postgresql/
├── bin/
│   ├── postgres.exe
│   ├── psql.exe
│   ├── pg_ctl.exe
│   ├── initdb.exe
│   └── many DLLs
├── lib/
└── share/
```

## 2. Python 3.12 Embeddable Package (~30 MB)

**Download:**
- URL: https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip
- Direct link: https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip

**Extract to:** `contrib/windows/dependencies/python/`

**Should contain:**
```
python/
├── python.exe
├── python312.dll
├── python312.zip
└── python312._pth
```

**IMPORTANT:** Edit `python312._pth` and add this line at the end:
```
import site
```

## 3. Xerces-C 3.2.x DLLs (~5 MB)

**Option A - Pre-built binaries:**
- URL: https://xerces.apache.org/xerces-c/download.cgi
- Look for Windows binaries

**Option B - From vcpkg (easier):**
```powershell
vcpkg install xerces-c:x64-windows
# Copy from: vcpkg/installed/x64-windows/bin/
```

**Place DLLs in:** `contrib/windows/dependencies/xerces-c/bin/`

**Need:**
```
xerces-c/
└── bin/
    └── xerces-c_3_2.dll (or similar)
```

## 4. PostgreSQL Client Library (libpq) DLLs (~10 MB)

These come with PostgreSQL binaries, just copy them:

**From:** `postgresql/bin/`  
**Copy these DLLs to:** `contrib/windows/dependencies/libpq/bin/`

**Files needed:**
- libpq.dll
- libcrypto-3-x64.dll
- libssl-3-x64.dll
- libiconv-2.dll
- libintl-9.dll
- libwinpthread-1.dll

## 5. FrePPLe Binaries

These need to be compiled. Two options:

### Option A: Skip for now and test the installer structure
You can test the Inno Setup script without binaries - it will just fail at file copy.

### Option B: Get pre-built binaries
- Download from FrePPLe releases if available
- Or build in WSL/Linux and copy the Windows versions

---

## Quick Setup Script

Run this after downloading:

```powershell
# Create directory structure
New-Item -ItemType Directory -Path "contrib/windows/dependencies/postgresql" -Force
New-Item -ItemType Directory -Path "contrib/windows/dependencies/python" -Force
New-Item -ItemType Directory -Path "contrib/windows/dependencies/xerces-c/bin" -Force
New-Item -ItemType Directory -Path "contrib/windows/dependencies/libpq/bin" -Force

# Extract your downloaded files to these directories
# Then verify:
.\contrib\windows\Test-Installer.ps1
```

## Once You Have Everything

Build the installer:
```powershell
cd build
cmake --build . --config Release --target windows_installer
```

Output: `build/windows/frepple-9.13.0-win64-setup.exe`

---

## Estimated Time
- Downloading: 15-30 minutes (depending on connection)
- Extracting/organizing: 5 minutes
- Building installer: 2 minutes

**Total: ~20-40 minutes**
