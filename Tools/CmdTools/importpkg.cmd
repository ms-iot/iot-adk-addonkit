@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: importpkg [-PkgName]  [[-SourceWkspace] ]
echo    Imports package into the current workspace
echo    PkgName ............ package to import
echo    SourceWkspace ...... Optional, source workspace dir to import from. Default is %SAMPLEWKS%
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
call RunPSCommand.cmd "Import-IoTOEMPackage" %*

exit /b 0
