@echo off
REM Run open-ws before running this script
REM This script creates the driver package

goto START

:Usage
echo Usage: migrate  <dir>
echo    Migrates the iot-adk-addonkit to the latest version, 
echo    Dir ............ iot-adk-addonkit directory
echo    [/?]............ Displays this usage string.

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Redo-IoTWorkspace" %*

exit /b 0
