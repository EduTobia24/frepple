@echo off
REM Install Visual C++ Redistributable if needed

echo Checking for Visual C++ Redistributable...

REM Check if VC++ 2015-2022 is installed
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed >nul 2>&1
if %errorlevel% equ 0 (
    echo Visual C++ Redistributable is already installed.
    exit /b 0
)

echo Visual C++ Redistributable not found. Installation may be required.
echo Please install Visual C++ Redistributable 2015-2022 from:
echo https://aka.ms/vs/17/release/vc_redist.x64.exe

exit /b 0
