@echo off
REM Launches IoTCoreShell in cmd

goto START

:Usage
echo Usage: LaunchTool TargetDir\IoTWorkspace.xml
echo    TargetDir........... Optional, Name of the IoTWorkspace.xml
echo    [/?]................ Displays this usage string.
echo    Example:
echo        LaunchTool C:\MyWkspace\IoTWorkspace.xml

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
set INPUT=%1
if [%1] == [] ( set INPUT=%~dp0..\..\Workspace\IoTWorkspace.xml )

set CLRRED=[91m
set CLRYEL=[93m
set CLREND=[0m
set CLRZ=[0m

TITLE IoTCoreShell
doskey /macrofile=%~dp0alias.txt
set PATH=%~dp0;%PATH%
cd /D %~dp0
call open-ws.cmd %INPUT%




