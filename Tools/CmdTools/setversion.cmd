@echo off
REM This script sets version for the OEM custom packages for the current arch and store it in workspace settings

goto START

:Usage
echo Usage: setversion <version>
echo    <version>....... Required, Four part version number
echo    [/?]............ Displays this usage string.
echo    Example:
echo        setversion 10.0.1.0

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Set-IoTCabVersion" "%1"
if exist %IOTWKSPACE%\Build\Version.cmd (
    REM Load the new env variables from the generated env file
    echo Running %IOTWKSPACE%\Build\Version.cmd
    call "%IOTWKSPACE%\Build\Version.cmd"
) else ( echo Error in setting version )

exit /b
