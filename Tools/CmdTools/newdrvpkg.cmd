@echo off
REM Run open-ws before running this script
REM This script creates the driver package

goto START

:Usage
echo Usage: newdrvpkg filename.inf [CompName.SubCompName] [BSPName]
echo    filename.inf............ Required, input inf file
echo    CompName.SubCompName.... Optional, default is Drivers.filename; Mandatory if BSPName is specified
echo    BSPName................. Optional, if specified, the driver package will be at BSPName\Packages directory
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newdrvpkg C:\test\testdrv.inf
echo        newdrvpkg C:\test\testdrv.inf Drivers.TestDriver
echo        newdrvpkg C:\test\testdrv.inf ModelA.TestDriver ModelA

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Add-IoTDriverPackage" %*

exit /b 0
