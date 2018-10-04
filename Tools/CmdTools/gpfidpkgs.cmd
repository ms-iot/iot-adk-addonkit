@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: gpfidpkgs [-FeatureID] 
echo    Gets the product packages corresponding to the specified feature id
echo    FeatureID ............ Valid Product feature ID.
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
call RunPSCommand.cmd "Get-IoTProductPackagesForFeature" %*

exit /b 0
