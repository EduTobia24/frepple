# FrePPLe Windows Installer - Implementation Summary

## Overview

A complete Inno Setup-based Windows installer has been created for FrePPLe, enabling easy deployment on Windows systems with all dependencies included.

## Files Created

### Main Installer Script
- **`contrib/windows/frepple-installer.iss`** - Complete Inno Setup script
  - Multi-language support (10 languages)
  - Component selection (Core, PostgreSQL, Python, Shortcuts)
  - Interactive configuration wizards
  - Automatic service installation
  - Registry integration
  - Firewall configuration

### Installation Scripts (`contrib/windows/scripts/`)
1. **`install-vcredist.bat`** - Checks/installs Visual C++ Runtime
2. **`init-postgresql.bat`** - Initializes PostgreSQL database cluster
3. **`setup-python-env.bat`** - Creates Python virtual environment
4. **`init-frepple-db.bat`** - Runs Django migrations and creates schema
5. **`install-service.bat`** - Installs Windows services (PostgreSQL + FrePPLe)
6. **`uninstall-service.bat`** - Removes services during uninstall
7. **`start-frepple.bat`** - Starts all FrePPLe services
8. **`stop-frepple.bat`** - Stops all FrePPLe services
9. **`stop-postgresql.bat`** - Stops PostgreSQL service

### Documentation
1. **`contrib/windows/README.txt`** - User-facing installation guide
2. **`contrib/windows/BUILD.md`** - Developer build instructions
3. **`contrib/windows/dependencies/README.md`** - Dependencies guide

### Build Integration
- **`contrib/windows/CMakeLists.txt`** - CMake build integration
- Updated root **`CMakeLists.txt`** to include Windows subdirectory

## Key Features

### 1. Complete Dependency Management
- ✅ PostgreSQL 16 embedded (portable installation)
- ✅ Python 3.12 runtime with virtual environment
- ✅ All Python packages from requirements.txt
- ✅ Xerces-C XML parser library
- ✅ PostgreSQL client libraries (libpq)

### 2. Interactive Configuration
The installer includes custom wizard pages for:
- **PostgreSQL Settings**: Database name, port
- **Database Credentials**: Username and password
- **Web Server**: Port and worker processes
- **Admin Account**: Initial administrator credentials

### 3. Automatic Service Setup
- PostgreSQL service (PostgreSQL-FrePPLe)
- FrePPLe web service (FrePPLeService)
- Automatic startup on Windows boot
- Service dependencies properly configured

### 4. Security Features
- Generates random SECRET_KEY for Django
- Configures PostgreSQL with password authentication
- Optional Windows Firewall exception
- Secure default configurations

### 5. User Experience
- Professional installer UI (WizardStyle=modern)
- Desktop and Start Menu shortcuts
- One-click browser launch to application
- Start/Stop shortcuts in Start Menu
- Comprehensive documentation included

### 6. Uninstallation
- Clean removal of services
- Option to preserve or delete data
- Removes registry entries
- Removes firewall rules

## Installation Flow

```
1. Welcome Screen
2. License Agreement (MIT)
3. Component Selection
   ├─ Core (required)
   ├─ PostgreSQL (optional)
   ├─ Python (required)
   └─ Shortcuts
4. Configuration Wizards
   ├─ PostgreSQL Configuration
   ├─ Database User
   ├─ Web Server Settings
   └─ Admin Account
5. Installation Directory
6. Ready to Install
7. Installing Files
   ├─ Copy binaries
   ├─ Copy Django app
   ├─ Copy dependencies
8. Post-Installation
   ├─ Install VC++ Runtime
   ├─ Initialize PostgreSQL
   ├─ Setup Python venv
   ├─ Install Python packages
   ├─ Run Django migrations
   ├─ Collect static files
   ├─ Install Windows services
   ├─ Add firewall exception
   └─ Start services
9. Finish
   └─ Launch browser
```

## Building the Installer

### Prerequisites Needed (Before Building)

1. **Download Dependencies** (not in git repo):
   ```
   dependencies/
   ├── postgresql/     # From EnterpriseDB (16.x)
   ├── python/         # Python 3.12 embeddable
   ├── xerces-c/       # Xerces-C DLLs
   └── libpq/          # PostgreSQL client DLLs
   ```

2. **Install Inno Setup 6**:
   - Download: https://jrsoftware.org/isdl.php
   - Install to default location

3. **Build FrePPLe**:
   ```powershell
   mkdir build
   cd build
   cmake .. -G "Visual Studio 17 2022"
   cmake --build . --config Release
   ```

### Build Commands

**Option 1: CMake (Recommended)**
```powershell
cmake --build . --target windows_installer
```

**Option 2: Inno Setup GUI**
```
Open contrib/windows/frepple-installer.iss
Click Build > Compile
```

**Option 3: Command Line**
```powershell
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" contrib\windows\frepple-installer.iss
```

### Output
```
build/windows/frepple-9.13.0-win64-setup.exe
```
(Approximately 600-800 MB)

## Testing Checklist

Before distribution, test:
- [ ] Fresh Windows 10/11 installation
- [ ] Installation with all components
- [ ] Installation without PostgreSQL (using existing)
- [ ] Custom port configuration
- [ ] Service installation and startup
- [ ] Web interface accessibility
- [ ] Admin login works
- [ ] Database migrations successful
- [ ] Static files served correctly
- [ ] Start/Stop scripts work
- [ ] Uninstall (keep data)
- [ ] Uninstall (remove data)

## Configuration Files Modified

The installer automatically configures:

1. **`djangosettings.py`**:
   - SECRET_KEY (random 50-char string)
   - POSTGRES_DBNAME, USER, PASSWORD, HOST, PORT
   - Database configuration for all scenarios

2. **`postgresql.conf`**:
   - Port configuration
   - Performance tuning
   - UTF-8 encoding
   - Logging settings

3. **`pg_hba.conf`**:
   - Password authentication
   - Local connections only

4. **Windows Registry**:
   - Installation path
   - Configuration settings
   - Version information

## Service Architecture

```
PostgreSQL-FrePPLe (Service)
    ├─ Runs: pg_ctl.exe
    ├─ Port: 5432 (configurable)
    ├─ Data: [InstallDir]\pgsql\data
    └─ Logs: [InstallDir]\logs\postgresql-*.log

FrePPLeService (Service)
    ├─ Depends on: PostgreSQL-FrePPLe
    ├─ Runs: Python + Django runserver
    ├─ Port: 8000 (configurable)
    ├─ Environment: [InstallDir]\venv
    └─ Logs: [InstallDir]\logs\frepple-service.log
```

## Known Limitations

1. **Python Package Installation**: Requires internet connection during installation for pip packages. Consider pre-downloading wheels for offline installation.

2. **NSSM**: Service management uses NSSM if available, otherwise falls back to basic sc.exe service creation. NSSM provides better service control but must be downloaded separately.

3. **Web Server**: Uses Django's development server (runserver). For production, consider adding option to use Daphne or Waitress.

4. **Database Backup**: No automated backup included. Users should schedule their own backups.

5. **Updates**: In-place upgrades need additional migration script. Currently, users must uninstall/reinstall.

## Future Enhancements

1. **Auto-Update**: Implement auto-update checker
2. **Backup Tool**: Add database backup/restore utility
3. **Production Server**: Bundle Daphne/Waitress instead of runserver
4. **Offline Installation**: Pre-bundle Python wheels
5. **Multi-tenancy**: Support for multiple database instances
6. **SSL/TLS**: Add HTTPS configuration wizard
7. **Container Option**: Docker Desktop integration
8. **Upgrade Path**: In-place upgrade without data loss

## Distribution

### Release Checklist
1. Test installer on clean Windows VM
2. Verify all services start correctly
3. Test with antivirus software enabled
4. Generate SHA256 checksum
5. Code sign the installer (optional)
6. Upload to GitHub Releases
7. Update website download links
8. Update documentation

### Recommended File Names
```
frepple-9.13.0-win64-setup.exe
frepple-9.13.0-win64-setup.exe.sha256
```

## Support

### For Build Issues
- Check BUILD.md for detailed instructions
- Verify all dependencies are present
- Review CMake output for errors

### For Installation Issues
- Check logs in [InstallDir]\logs\
- Verify PostgreSQL service is running
- Check firewall/antivirus settings
- Review djangosettings.py configuration

### For Runtime Issues
- Check service status: `net start | findstr FrePPLe`
- Review application logs
- Verify database connectivity
- Check port availability

## License

This installer script and supporting files are part of FrePPLe and released under the MIT License.

---

**Installation Package Ready!** 🎉

The complete Windows installer infrastructure is now in place. Once dependencies are prepared, you can build a professional, user-friendly installer for FrePPLe on Windows.
