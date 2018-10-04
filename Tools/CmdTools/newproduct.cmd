@echo off
REM Run open-ws before running this script
REM This script creates the folder structure and copies the template files for a new product

goto START

:Usage
echo Usage: newproduct ProductName [BSPName]
echo    ProductName....... Required, Name of the product to be created.
echo    BSPName........... Required, Name of the BSP to be used.
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newproduct SampleA QCDB410C
echo Existing products are
dir /b /AD %SRC_DIR%\Products

echo Existing BSPs are
dir /b /AD %SRC_DIR%\BSP

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
call RunPSCommand.cmd "Add-IoTProduct" %*

exit /b 0
