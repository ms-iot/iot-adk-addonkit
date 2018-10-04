@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: importcfg [-Product]  [-ZipFile] 
echo    Imports Device update center CUSConfig.zip file into product directory
echo    Product ............ Product name
echo    ZipFile ............ CUSConfig.zip file downloaded from the Device Update Center portal.
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
call RunPSCommand.cmd "Import-IoTDUCConfig" %*

exit /b 0
