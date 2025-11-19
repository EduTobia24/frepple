@echo off
REM Stop FrePPLe services

echo Stopping FrePPLe services...

REM Stop FrePPLe service
net stop FrePPLeService
if %errorlevel% neq 0 (
    echo FrePPLe service was not running or failed to stop.
)

REM Stop PostgreSQL service
net stop PostgreSQL-FrePPLe
if %errorlevel% neq 0 (
    echo PostgreSQL service was not running or failed to stop.
)

echo FrePPLe services stopped.
exit /b 0
