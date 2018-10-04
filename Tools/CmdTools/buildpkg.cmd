@echo off

goto START

:Usage
echo Usage: buildpkg [CompName.SubCompName]/[packagefile.wm.xml]/[All]/[Clean]
echo    packagefile.wm.xml....... Package definition XML file
echo    CompName.SubCompName...... Package ComponentName.SubComponent Name
echo    All....................... All packages under \Packages directory are built
echo    Clean..................... Cleans the output directory
echo        One of the above should be specified
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildpkg sample.wm.xml
echo        buildpkg Appx.Main
echo        buildpkg All

exit /b 1

:START
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "New-IoTCabPackage" %*
exit /b 0