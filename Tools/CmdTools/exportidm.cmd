@echo off

goto START

:Usage
echo Usage: exportidm [Product]
echo    ProductName....... Required, Name of the product

echo    [/?]...................... Displays this usage string.
echo    Example:
echo        exportpkgs SampleA 
exit /b 1

:START

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Export-IoTDeviceModel" %*

exit /b 0
