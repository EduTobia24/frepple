@echo off
REM Start FrePPLe services

echo Starting FrePPLe services...

REM Start PostgreSQL service
net start PostgreSQL-FrePPLe
if %errorlevel% neq 0 (
    echo Failed to start PostgreSQL service.
    exit /b 1
)

REM Wait a moment for PostgreSQL to initialize
timeout /t 3 /nobreak >nul

REM Start FrePPLe service
net start FrePPLeService
if %errorlevel% neq 0 (
    echo Failed to start FrePPLe service.
    exit /b 1
)

echo FrePPLe services started successfully.
echo Open your browser to http://localhost:8000
exit /b 0
