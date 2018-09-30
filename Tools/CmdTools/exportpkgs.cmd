@echo off

goto START

:Usage
echo Usage: exportpkgs [Product] [BuildType]
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test

echo    [/?]...................... Displays this usage string.
echo    Example:
echo        exportpkgs SampleA Test 
echo        exportpkgs SampleA Retail 
echo Run this command only after a successful ffu creation. (See buildimage.cmd)

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
call RunPSCommand.cmd "Export-IoTDUCCab" %*

exit /b 0
