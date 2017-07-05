@echo off

goto START

:Usage
echo Usage: extractwim [Product] [BuildType]
echo    ProductName....... Required, Name of the product
echo    BuildType......... Required, Retail/Test
echo    [/?].............. Displays this usage string.
echo    Example:
echo        extractwim samplea test

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if /I not [%2] == [Retail] ( if /I not [%2] == [Test] goto Usage )

REM Checking prerequisites
if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)

if not defined FFUNAME ( set FFUNAME=Flash)
set OUTPUTDIR=%BLD_DIR%\%1\%2
set IMG_FILE=%BLD_DIR%\%1\%2\%FFUNAME%.ffu
echo Mounting %IMG_FILE% (this can take some time)..
call wpimage mount "%IMG_FILE%" > %OUTPUTDIR%\mountlog.txt

REM This will break if there is space in the user account (eg.C:\users\test acct\)
for /f "tokens=3,4,* skip=9 delims= " %%i in (%OUTPUTDIR%\mountlog.txt) do (
    if [%%i] == [Path:] (
        set MOUNT_PATH=%%j
    ) else if [%%i] == [Name:] (
        set DISK_DRIVE=%%j
    )
)

echo Mounted at %MOUNT_PATH% as %DISK_DRIVE%..
echo Extracting data wim
dism /Capture-Image /ImageFile:%OUTPUTDIR%\data.wim /CaptureDir:%MOUNT_PATH%Data\ /Name:"DragonBoard DATA" /Compress:max
echo Extracting MainOS wim, this can take a while too..
dism /Capture-Image /ImageFile:%OUTPUTDIR%\mainos.wim /CaptureDir:%MOUNT_PATH% /Name:"DragonBoard MainOS" /Compress:max

echo Unmounting %DISK_DRIVE%
wpimage dismount -physicaldrive %DISK_DRIVE%
REM del %OUTPUTDIR%\mountlog.txt
echo %BSP_VERSION% > %OUTPUTDIR%\version.txt

goto End

:Error
endlocal
echo "extractwim %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
