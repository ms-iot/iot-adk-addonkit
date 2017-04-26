@echo off

goto START

:Usage
echo Usage: flashSD [Product] [BuildType] [DriveNr]
echo    ProductName....... Required, Name of the product
echo    BuildType......... Required, Retail/Test
echo    DriveNr........... PhysicalDrive number to which the USB is mounted
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        flashSD samplea test 2

exit /b 1

:START

REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if [%3] == [] goto Usage
if not defined FFUNAME ( set FFUNAME=Flash)

set IMG_FILE=%BLD_DIR%\%1\%2\%FFUNAME%.ffu
if exist "%IMG_FILE%" (
    echo Running Dism : %1 on PhysicalDrive%3
    call dism /apply-image /imagefile:"%IMG_FILE%" /ApplyDrive:\\.\PhysicalDrive%3 /SkipPlatformCheck
)
exit /b
