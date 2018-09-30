@echo off
REM This script creates a new workspace

goto START

:Usage
echo Usage: new-ws TargetDir OemName Arch
echo    TargetDir........... Required, Name of the directory where the workspace is created
echo    OemName............. Required, Name of the OEM to be used in workspace
echo    Arch................ Required, Architecture for the workspace    
echo    [/?]................ Displays this usage string.
echo    Example:
echo        new-ws TargetDir Contoso arm

exit /b 1

:START
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

call RunPSCommand.cmd "New-IoTWorkspace" %*
REM Load the new env variables from the generated env file
if exist "%1\Build\SetEnvVars.cmd" (
    echo Running %1\Build\SetEnvVars.cmd
    call "%1\Build\SetEnvVars.cmd"
)
cd /D %IOTWKSPACE%

