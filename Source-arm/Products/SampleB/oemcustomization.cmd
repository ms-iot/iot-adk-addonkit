@echo off
REM OEM Customization Script file
REM This script if included in the image, is called everytime the system boots.

reg query HKLM\Software\IoT /v FirstBootDone >nul 2>&1

if %errorlevel% == 1 (
    REM Enable Administrator User
    net user Administrator p@ssw0rd /active:yes
    reg add HKLM\Software\IoT /v FirstBootDone /t REG_DWORD /d 1 /f >nul 2>&1
)
