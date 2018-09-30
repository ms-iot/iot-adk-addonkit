@echo off
REM This script sets env for the specified arch based on workspace settings

goto START

:Usage
echo Usage: setenv arch
echo    arch....... Required, %SUPPORTED_ARCH%
echo    [/?]....... Displays this usage string.
echo    Example:
echo        setenv x86

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
set SUPPORTED_ARCH=arm x86 x64

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Set-IoTEnvironment" "%1"
if exist %IOTWKSPACE%\Build\SetEnvVars.cmd (
    REM Load the new env variables from the generated env file
    echo Running %IOTWKSPACE%\Build\SetEnvVars.cmd
    call "%IOTWKSPACE%\Build\SetEnvVars.cmd"
) else ( echo Error in setting the env )

exit /b
