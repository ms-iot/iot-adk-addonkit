@echo off

goto START

:Usage
echo Usage: convertpkg [Dir]
echo    Dir.................. Directory containing .pkg.xml files
echo    [/?]................. Displays this usage string.
echo    Example:
echo        convertpkg C:\MyDir

exit /b 1

:START
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Convert-IoTPkg2Wm" %*
exit /b 0