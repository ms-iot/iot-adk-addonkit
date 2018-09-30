@echo off
REM Run open-ws before running this script
REM This script creates the folder structure and copies the template files for a new package


goto START

:Usage
echo Usage: newappxpkg filename.appx [fga/bgt/none] [CompName.SubCompName] [skipcert]
echo    filename.appx........... Required, Input appx package/appxbundle. 
echo    fga/bgt/none............ Required, Startup ForegroundApp / Startup BackgroundTask / No startup
echo    CompName.SubCompName.... Optional, default is Appx.AppxName; Mandatory if you want to specify skipcert
echo    skipcert................ Optional, specify this to skip adding cert information to wm xml file
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newappxpkg C:\test\MainAppx_1.0.0.0_arm.appx fga Appx.Main
echo        newappxpkg C:\test\MainAppx_1.0.0.0_arm.appx none 
echo Existing packages are
dir /b /AD %SRC_DIR%\Packages

exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Add-IoTAppxPackage" %*

exit /b 0
