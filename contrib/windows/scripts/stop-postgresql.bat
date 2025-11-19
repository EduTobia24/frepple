@echo off
REM Stop PostgreSQL service or process

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1
set PGBIN=%INSTALL_DIR%\pgsql\bin
set PGDATA=%INSTALL_DIR%\pgsql\data

echo Stopping PostgreSQL...

REM Try to stop service first
net stop PostgreSQL-FrePPLe 2>nul

REM If not a service, try pg_ctl
if exist "%PGBIN%\pg_ctl.exe" (
    "%PGBIN%\pg_ctl.exe" -D "%PGDATA%" stop -m fast 2>nul
)

echo PostgreSQL stopped.
exit /b 0
