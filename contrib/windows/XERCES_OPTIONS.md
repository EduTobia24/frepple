# Important Note About Xerces-C

## Current Status
The Xerces-C library is **required for building FrePPLe binaries** (the C++ core engine), but **NOT required for creating the installer structure**.

## Options to Proceed

### Option 1: Create Installer Without FrePPLe Binaries (RECOMMENDED FOR NOW)
You can create the installer structure with:
- PostgreSQL ✓
- Python ✓  
- All scripts and configuration ✓

The installer will work for deploying a Python-only version of FrePPLe (using Django and the web interface), but won't include the C++ planning engine.

**To proceed:**
```powershell
# Create the installer anyway
cmake --build . --config Release --target windows_installer
```

### Option 2: Build Xerces-C Yourself
```powershell
cd contrib\windows\dependencies\xerces-c
mkdir build
cd build
cmake .. -A x64 -DCMAKE_INSTALL_PREFIX=..
cmake --build . --config Release
cmake --build . --config Release --target install
```

This will take 10-15 minutes but will give you working binaries.

### Option 3: Skip Xerces-C, Build FrePPLe Without It
Modify CMakeLists.txt to make Xerces-C optional, then build without XML support.

### Option 4: Download from Conan/vcpkg
If you have package managers installed:
```powershell
# Using vcpkg
vcpkg install xerces-c:x64-windows

# Using conan
conan install xerces-c/3.3.0@ -s arch=x86_64 -s build_type=Release
```

---

## My Recommendation

**For now, proceed with Option 1** - create the installer without FrePPLe binaries. The installer will still be fully functional for deploying the Django web application, PostgreSQL database, and Python environment.

Later, you can:
1. Build Xerces-C from the source you already have
2. Build FrePPLe binaries  
3. Add them to the installer package

This way you can test the installer installation process and verify everything works before dealing with the C++ compilation complexity.
