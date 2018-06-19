@echo off

goto START

:Usage
echo Usage: exportidm [Product] 
echo    ProductName....... Required, Name of the product to be created.
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        exportidm SampleA 

exit /b 1

:START
if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not exist %SRC_DIR%\Products\%1 (
   echo %1 not found. Available products listed below
   dir /b /AD %SRC_DIR%\Products
   goto Usage
)

powershell -executionpolicy unrestricted  -Command ("%TOOLS_DIR%\DeviceModel.ps1 %1")
exit /b

