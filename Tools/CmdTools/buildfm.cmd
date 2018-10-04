@echo off

goto START

:Usage
echo Usage: buildfm [bspname] [-IncludeOCP]
echo    [bspname] ........... Optional, name of the bsp to be built
echo    [-IncludeOCP]......... Optional, if defined processes ocpfm.xml file
echo    [/?]      ........... Displays this usage string.
echo    Example:
echo        buildfm 
echo        buildfm Rpi2
echo        buildfm RPi2 -IncludeOCP

echo Existing BSPs are
dir /b /AD %BSPSRC_DIR%
exit /b 1

:START

setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage


if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "New-IoTFIPPackage" %*
exit /b 0
