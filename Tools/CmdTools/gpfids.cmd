@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: gpfids [[-FeatureType]]
echo    Gets the product feature ids for the specified feature types
echo    FeatureType ............ Optional. Values : "Developer", "Test", "Retail", "Deprecated" and "All". Default is "All"
echo    [/?]............ Displays this usage string.

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Get-IoTProductFeatureIDs" %*

exit /b 0
