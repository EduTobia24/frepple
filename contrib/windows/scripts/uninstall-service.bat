@echo off
REM Uninstall FrePPLe Windows services

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1

echo Uninstalling FrePPLe services...

REM Stop and remove FrePPLe service
net stop FrePPLeService 2>nul
sc delete FrePPLeService 2>nul

REM Stop and remove PostgreSQL service
net stop PostgreSQL-FrePPLe 2>nul
sc delete PostgreSQL-FrePPLe 2>nul

REM Check if user wants to keep data
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v KeepData 2^>nul') do set KEEP_DATA=%%b

if "%KEEP_DATA%"=="0" (
    echo Removing data directory...
    rmdir /s /q "%INSTALL_DIR%\pgsql\data" 2>nul
    rmdir /s /q "%INSTALL_DIR%\logs" 2>nul
)

echo Service uninstallation complete.
exit /b 0
