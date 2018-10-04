@echo off

goto :START

:Usage
echo Usage: retailsign [On/Off]
echo    On ................... Enables Cross Cert for signing
echo    Off................... Disables Cross Cert for signing and enables OEM Test Signing
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        retailsign On
echo        retailsign Off

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
call RunPSCommand.cmd "Set-IoTRetailSign" "%1"
if exist %IOTWKSPACE%\Build\SetPrompt.cmd (
    REM Load the new env variables from the generated env file
    REM echo Running %IOTWKSPACE%\Build\SetPrompt.cmd
    call "%IOTWKSPACE%\Build\SetPrompt.cmd"
) else ( echo Error in setting the env )

exit /b 0



