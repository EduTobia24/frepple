# FrePPLe Windows Build - Quick Start Guide

## Current Status

✅ Inno Setup 6 - Installed  
✅ Visual Studio 2022 - Installed  
✅ CMake 3.31 - Installed  
✅ Python 3.11 - Available (MSYS64)  
❌ Xerces-C library - **MISSING**  
❌ PostgreSQL dev libraries - **MISSING**  

## Problem

Building FrePPLe on Windows requires C++ dependencies that are complex to set up:
1. **Xerces-C** (XML parser library)
2. **PostgreSQL** client development libraries

## Solutions

### Option 1: Build in WSL/Linux (RECOMMENDED for Testing)

Since you have WSL, you can build there much more easily:

```bash
# In WSL
cd /mnt/c/Users/eduar/ProyectosPersonales/frepple

# Install dependencies
sudo apt update
sudo apt install -y cmake g++ python3-dev python3-pip \
    libxerces-c-dev libpq-dev postgresql-client

# Build
mkdir build
cd build
cmake ..
cmake --build . --config Release

# Build DEB package
cmake --build . --target package
```

### Option 2: Download Pre-built Binaries (EASIEST)

For the Windows installer, you can:

1. **Use the Ubuntu build** to get the binaries, then
2. **Cross-compile** or **download** Windows versions of dependencies

### Option 3: Complete Windows Native Build (COMPLEX)

You need to manually download and set up:

#### A. Download Xerces-C for Windows
1. Go to: https://xerces.apache.org/xerces-c/download.cgi
2. Download Windows binaries or source
3. Extract to: `C:\develop\xerces-c-3.2.3`
4. CMakeLists.txt expects it there (line 38)

#### B. Download PostgreSQL for Windows  
1. Go to: https://www.enterprisedb.com/download-postgresql-binaries
2. Download PostgreSQL 16 Windows binaries
3. Extract to: `C:\develop\pgsql`
4. CMakeLists.txt expects it there (line 54)

## Recommended Approach for You

Since building on Windows is complex, here's what I suggest:

### Step 1: Build the Core in WSL (5 minutes)
```bash
# This gives you the compiled binaries
wsl
cd /mnt/c/Users/eduar/ProyectosPersonales/frepple
sudo apt install -y cmake g++ python3-dev libxerces-c-dev libpq-dev postgresql-client
mkdir build && cd build
cmake .. && cmake --build . --config Release
```

### Step 2: Prepare Windows Dependencies (for installer)

Download these for the Windows installer:

1. **PostgreSQL 16 Portable** → `contrib/windows/dependencies/postgresql/`
   - https://www.enterprisedb.com/download-postgresql-binaries
   - Get Windows x64 binaries

2. **Python 3.12 Embeddable** → `contrib/windows/dependencies/python/`
   - https://www.python.org/ftp/python/3.12.7/python-3.12.7-embed-amd64.zip

3. **Xerces-C DLLs** → `contrib/windows/dependencies/xerces-c/bin/`
   - https://xerces.apache.org/xerces-c/

### Step 3: Build Installer (Once dependencies are ready)

```powershell
# Build the installer package
cd build
cmake --build . --config Release --target windows_installer
```

## What Do You Want to Do?

1. **Test the installer scripts** - We can do this now without building
2. **Build in WSL** - Quick, easy, gets you working binaries
3. **Set up full Windows build** - Takes time, download ~2GB of dependencies
4. **Just create the installer skeleton** - Test Inno Setup script only

Let me know which option you prefer!
