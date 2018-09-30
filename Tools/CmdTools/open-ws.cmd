@echo off
REM This script opens an existing workspace

goto START

:Usage
echo Usage: open-ws TargetDir\IoTWorkspace.xml
echo    TargetDir........... Required, Name of the directory where the workspace is created
echo    [/?]................ Displays this usage string.
echo    Example:
echo        open-ws C:\MyWkspace\IoTWorkspace.xml

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

call RunPSCommand.cmd "Open-IoTWorkspace" "%1"
REM Load the new env variables from the generated env file
echo Running %~dp1Build\SetEnvVars.cmd
call "%~dp1Build\SetEnvVars.cmd"
cd /D %IOTWKSPACE%
exit /b
