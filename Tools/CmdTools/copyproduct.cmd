@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: copyproduct [-Source] [-Destination] [-ProductName] 
echo    Imports product into the current workspace
echo    Source ........... Source workspace dir to copy from.
echo    Destination ...... Desitnation workspace dir to copy to.
echo    ProductName .......... product to copy
echo    [/?]............ Displays this usage string.

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if [%3] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Copy-IoTProduct" %*

exit /b 0
