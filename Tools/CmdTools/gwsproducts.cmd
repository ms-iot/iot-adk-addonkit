@echo off
REM Run open-ws before running this script

goto START

:Usage
echo Usage: gwproducts [WorkSpace]
echo    Gets the the list of product names in the workspace.
echo    WorkSpace ............ Optional, specifies the workspace to search.
echo                           Default is from %SAMPLEWKS%.
echo    [/?]............ Displays this usage string.

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Get-IoTWorkspaceProducts" %*

exit /b 0
