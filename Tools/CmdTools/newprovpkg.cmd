@echo off
REM Run open-ws before running this script
REM This script creates the folder structure and copies the template files for a new package

goto START

:Usage
echo Usage: newprovpkg CompName.SubCompName
echo    CompName.SubCompName....... Required, Component Name.SubComponent Name for the package
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newprovpkg Prov.Enroll
echo Existing packages are
dir /b /AD %COMMON_DIR%\Packages

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Add-IoTProvisioningPackage" %*

exit /b 0
