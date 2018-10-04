@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: removefid [-Product] <String> [-Config] <String> [-FeatureID] <String>
echo    Removes feature id (oem feature or Microsoft feature) to the specified product's oeminput xml file for the given configuration
echo    [/?]............ Displays this usage string.

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Remove-IoTProductFeature" %*

exit /b 0
