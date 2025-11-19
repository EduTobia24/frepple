@echo off
REM Initialize FrePPLe database schema

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1
set VENV_DIR=%INSTALL_DIR%\venv
set FREPPLECTL=%INSTALL_DIR%\bin\frepplectl.py
set PGBIN=%INSTALL_DIR%\pgsql\bin
set PGDATA=%INSTALL_DIR%\pgsql\data

echo Initializing FrePPLe database...

REM Start PostgreSQL if not running
echo Starting PostgreSQL...
"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" -l "%INSTALL_DIR%\logs\postgresql.log" start
timeout /t 5 /nobreak >nul

REM Set environment variables
set FREPPLE_HOME=%INSTALL_DIR%\bin
set FREPPLE_APP=%INSTALL_DIR%\share\frepple
set FREPPLE_CONFIGDIR=%INSTALL_DIR%\etc\frepple
set FREPPLE_LOGDIR=%INSTALL_DIR%\logs
set DJANGO_SETTINGS_MODULE=freppledb.settings
set PYTHONPATH=%INSTALL_DIR%\share\frepple

REM Read database configuration from registry
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabaseName 2^>nul') do set DB_NAME=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabaseUser 2^>nul') do set DB_USER=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabasePassword 2^>nul') do set DB_PASSWORD=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabasePort 2^>nul') do set DB_PORT=%%b

if not defined DB_NAME set DB_NAME=frepple
if not defined DB_USER set DB_USER=frepple
if not defined DB_PASSWORD set DB_PASSWORD=frepple
if not defined DB_PORT set DB_PORT=5432

set POSTGRES_DBNAME=%DB_NAME%
set POSTGRES_USER=%DB_USER%
set POSTGRES_PASSWORD=%DB_PASSWORD%
set POSTGRES_HOST=localhost
set POSTGRES_PORT=%DB_PORT%

REM Activate virtual environment
call "%VENV_DIR%\Scripts\activate.bat"

REM Run migrations to create database schema
echo Running database migrations...
cd "%INSTALL_DIR%\share\frepple"
python "%FREPPLECTL%" migrate --noinput
if %errorlevel% neq 0 (
    echo Failed to run database migrations.
    exit /b 1
)

REM Create admin user if specified
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v AdminUsername 2^>nul') do set ADMIN_USER=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v AdminPassword 2^>nul') do set ADMIN_PASS=%%b

if defined ADMIN_USER (
    echo Creating admin user...
    python "%FREPPLECTL%" shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.filter(username='%ADMIN_USER%').exists() or User.objects.create_superuser('%ADMIN_USER%', 'admin@frepple.local', '%ADMIN_PASS%')"
)

REM Collect static files
echo Collecting static files...
set FREPPLE_STATIC=%INSTALL_DIR%\share\frepple\static
python "%FREPPLECTL%" collectstatic --noinput --clear --ignore "*.less" --verbosity=0
if %errorlevel% neq 0 (
    echo Failed to collect static files.
    exit /b 1
)

echo FrePPLe database initialization complete.
exit /b 0
