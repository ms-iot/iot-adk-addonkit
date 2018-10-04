@echo off
REM Run open-ws before running this script
REM This script creates the folder structure and copies the template files for a new bsp

goto START

:Usage
echo Usage: newbsp BSPName
echo    BSPName........... Required, Name of the BSP to be used
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newbsp CustomRPi2
echo Existing BSPs are
dir /b /AD %BSPSRC_DIR%

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Add-IoTBSP" %*

exit /b 0
