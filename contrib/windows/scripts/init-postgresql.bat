@echo off
REM Initialize PostgreSQL database cluster

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1
set PGDATA=%INSTALL_DIR%\pgsql\data
set PGBIN=%INSTALL_DIR%\pgsql\bin
set PGLOG=%INSTALL_DIR%\logs\postgresql.log

echo Initializing PostgreSQL database cluster...
echo Install directory: %INSTALL_DIR%
echo Data directory: %PGDATA%

REM Create data directory if it doesn't exist
if not exist "%PGDATA%" (
    mkdir "%PGDATA%"
)

REM Create logs directory
if not exist "%INSTALL_DIR%\logs" (
    mkdir "%INSTALL_DIR%\logs"
)

REM Check if database is already initialized
if exist "%PGDATA%\PG_VERSION" (
    echo PostgreSQL database already initialized.
    goto :configure_postgresql
)

REM Initialize database cluster with trust authentication (will change later)
echo Running initdb...
"%PGBIN%\initdb.exe" -D "%PGDATA%" -U postgres -E UTF8 --locale=C -A trust
if %errorlevel% neq 0 (
    echo Failed to initialize PostgreSQL database.
    echo Check log at: %INSTALL_DIR%\logs\postgresql-init.log
    exit /b 1
)

:configure_postgresql
echo Configuring PostgreSQL...

REM Read configuration from registry
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabasePort 2^>nul') do set DB_PORT=%%b
if not defined DB_PORT set DB_PORT=5433

REM Check if port is already in use
netstat -ano | findstr ":%DB_PORT% " >nul
if %errorlevel% equ 0 (
    echo WARNING: Port %DB_PORT% is already in use. PostgreSQL may fail to start.
    echo Please ensure no other PostgreSQL instance is using this port.
)

REM Update postgresql.conf
echo port = %DB_PORT% >> "%PGDATA%\postgresql.conf"
echo listen_addresses = 'localhost' >> "%PGDATA%\postgresql.conf"
echo max_connections = 400 >> "%PGDATA%\postgresql.conf"
echo shared_buffers = 256MB >> "%PGDATA%\postgresql.conf"
echo work_mem = 64MB >> "%PGDATA%\postgresql.conf"
echo maintenance_work_mem = 128MB >> "%PGDATA%\postgresql.conf"
echo effective_cache_size = 1GB >> "%PGDATA%\postgresql.conf"
echo log_destination = 'stderr' >> "%PGDATA%\postgresql.conf"
echo logging_collector = on >> "%PGDATA%\postgresql.conf"
echo log_directory = '%INSTALL_DIR%\logs' >> "%PGDATA%\postgresql.conf"
echo log_filename = 'postgresql-%%Y-%%m-%%d.log' >> "%PGDATA%\postgresql.conf"

REM Note: pg_hba.conf initially uses trust authentication (set by initdb -A trust)
REM We'll update it to password authentication after creating users

REM Start PostgreSQL temporarily to create user and database
echo Starting PostgreSQL on port %DB_PORT%...
"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" -l "%PGLOG%" -w -t 30 start
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start PostgreSQL within 30 seconds.
    echo.
    echo Possible causes:
    echo - Port %DB_PORT% is already in use by another application
    echo - Another PostgreSQL instance is running
    echo - Check log file at: %PGLOG%
    echo.
    echo To fix: Stop any existing PostgreSQL services or choose a different port.
    exit /b 1
)
echo PostgreSQL started successfully on port %DB_PORT%.

REM Read database configuration from registry
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabaseUser 2^>nul') do set DB_USER=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabasePassword 2^>nul') do set DB_PASSWORD=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v DatabaseName 2^>nul') do set DB_NAME=%%b

if not defined DB_USER set DB_USER=frepple
if not defined DB_PASSWORD set DB_PASSWORD=frepple
if not defined DB_NAME set DB_NAME=frepple

REM Create database user and databases
echo Creating database user and databases...
"%PGBIN%\psql.exe" -U postgres -d postgres -c "CREATE USER %DB_USER% WITH PASSWORD '%DB_PASSWORD%' CREATEROLE;" >nul 2>&1
if %errorlevel% equ 0 (
    echo User %DB_USER% created.
) else (
    echo User %DB_USER% may already exist or could not be created.
)

"%PGBIN%\psql.exe" -U postgres -d postgres -c "CREATE DATABASE %DB_NAME% OWNER %DB_USER% ENCODING 'UTF8';" >nul 2>&1
if %errorlevel% equ 0 (
    echo Database %DB_NAME% created.
)

"%PGBIN%\psql.exe" -U postgres -d postgres -c "CREATE DATABASE %DB_NAME%_scenario1 OWNER %DB_USER% ENCODING 'UTF8';" >nul 2>&1
"%PGBIN%\psql.exe" -U postgres -d postgres -c "CREATE DATABASE %DB_NAME%_scenario2 OWNER %DB_USER% ENCODING 'UTF8';" >nul 2>&1
echo Scenario databases created.

REM Now update pg_hba.conf to require password authentication
echo Configuring password authentication...
echo # FrePPLe local connections > "%PGDATA%\pg_hba.conf"
echo host    all             all             127.0.0.1/32            scram-sha-256 >> "%PGDATA%\pg_hba.conf"
echo host    all             all             ::1/128                 scram-sha-256 >> "%PGDATA%\pg_hba.conf"
echo local   all             all                                     scram-sha-256 >> "%PGDATA%\pg_hba.conf"

REM Stop PostgreSQL
echo Stopping PostgreSQL...
"%PGBIN%\pg_ctl.exe" -D "%PGDATA%" -w stop
if %errorlevel% neq 0 (
    echo Warning: PostgreSQL may not have stopped cleanly.
)

echo PostgreSQL initialization complete.
exit /b 0
