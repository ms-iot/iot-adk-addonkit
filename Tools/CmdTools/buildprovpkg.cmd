@echo off

goto START

:Usage
echo Usage: buildprovpkg [customizations.xml] [Output.ppkg]
echo    customizations.xml...... Input settings xml file for provisioning
echo    Output.ppkg............. Filename for the generated ppkg file
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildprovpkg C:\MyCustomizations.xml C:\MyProv.ppkg

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
call RunPSCommand.cmd "New-IoTProvisioningPackage" %*
exit /b 0