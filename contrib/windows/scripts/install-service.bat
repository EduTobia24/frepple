@echo off
REM Install FrePPLe as Windows service using NSSM

setlocal EnableDelayedExpansion

set INSTALL_DIR=%~1
set NSSM=%INSTALL_DIR%\scripts\nssm.exe
set VENV_DIR=%INSTALL_DIR%\venv
set PYTHON_EXE=%VENV_DIR%\Scripts\python.exe
set MANAGE_PY=%INSTALL_DIR%\bin\frepplectl.py

echo Installing FrePPLe as Windows service...

REM Read configuration from registry
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v WebServerPort 2^>nul') do set WEB_PORT=%%b
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\FrePPLe" /v WorkerProcesses 2^>nul') do set WORKERS=%%b

if not defined WEB_PORT set WEB_PORT=8000
if not defined WORKERS set WORKERS=4

REM Install PostgreSQL service first
echo Installing PostgreSQL service...
sc create "PostgreSQL-FrePPLe" binPath= "%INSTALL_DIR%\pgsql\bin\pg_ctl.exe runservice -N PostgreSQL-FrePPLe -D %INSTALL_DIR%\pgsql\data" start= auto
sc description "PostgreSQL-FrePPLe" "PostgreSQL database server for FrePPLe"

REM Start PostgreSQL service
sc start "PostgreSQL-FrePPLe"
timeout /t 5 /nobreak >nul

REM Create batch script to run FrePPLe
set START_SCRIPT=%INSTALL_DIR%\scripts\frepple-service.bat
echo @echo off > "%START_SCRIPT%"
echo setlocal >> "%START_SCRIPT%"
echo set FREPPLE_HOME=%INSTALL_DIR%\bin >> "%START_SCRIPT%"
echo set FREPPLE_APP=%INSTALL_DIR%\share\frepple >> "%START_SCRIPT%"
echo set FREPPLE_CONFIGDIR=%INSTALL_DIR%\etc\frepple >> "%START_SCRIPT%"
echo set FREPPLE_LOGDIR=%INSTALL_DIR%\logs >> "%START_SCRIPT%"
echo set DJANGO_SETTINGS_MODULE=freppledb.settings >> "%START_SCRIPT%"
echo set PYTHONPATH=%INSTALL_DIR%\share\frepple >> "%START_SCRIPT%"
echo cd "%INSTALL_DIR%\share\frepple" >> "%START_SCRIPT%"
echo call "%VENV_DIR%\Scripts\activate.bat" >> "%START_SCRIPT%"
echo "%PYTHON_EXE%" "%MANAGE_PY%" runserver 0.0.0.0:%WEB_PORT% --noreload >> "%START_SCRIPT%"

REM If NSSM is available, use it; otherwise create a basic service
if exist "%NSSM%" (
    echo Installing service with NSSM...
    "%NSSM%" install FrePPLeService "%START_SCRIPT%"
    "%NSSM%" set FrePPLeService AppDirectory "%INSTALL_DIR%\share\frepple"
    "%NSSM%" set FrePPLeService DisplayName "FrePPLe Web Service"
    "%NSSM%" set FrePPLeService Description "FrePPLe Advanced Planning and Scheduling web application"
    "%NSSM%" set FrePPLeService Start SERVICE_AUTO_START
    "%NSSM%" set FrePPLeService DependOnService "PostgreSQL-FrePPLe"
    "%NSSM%" set FrePPLeService AppStdout "%INSTALL_DIR%\logs\frepple-service.log"
    "%NSSM%" set FrePPLeService AppStderr "%INSTALL_DIR%\logs\frepple-service-error.log"
) else (
    echo NSSM not found, creating basic service...
    sc create "FrePPLeService" binPath= "cmd /c \"%START_SCRIPT%\"" start= auto depend= "PostgreSQL-FrePPLe"
    sc description "FrePPLeService" "FrePPLe Advanced Planning and Scheduling web application"
)

echo Service installation complete.
echo Use 'net start FrePPLeService' to start the service.
exit /b 0
