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
set IMG_RECOVERY_FILE=%BLD_DIR%\%1\%2\%FFUNAME%_Recovery.ffu
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

REM Capture EFIESP
echo Extracting EFIESP wim
diskpart < %~dp0diskpartAssignEFIESP.txt
dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\efiesp.wim /CaptureDir:X:\ /Name:"\EFIESP"
diskpart < %~dp0diskpartUnassignEFIESP.txt
echo Extracting data wim
dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\data.wim /CaptureDir:%MOUNT_PATH%Data\ /Name:"DATA" /Compress:max
echo Extracting MainOS wim, this can take a while too..
dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\mainos.wim /CaptureDir:%MOUNT_PATH% /Name:"MainOS" /Compress:max

copy %BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE\winpe.wim %MOUNT_PATH%\mmos

echo %BSP_VERSION% > %MOUNT_PATH%\mmos\RecoveryImageVersion.txt

echo Unmounting %DISK_DRIVE%
wpimage dismount -physicaldrive %DISK_DRIVE% -imagepath %IMG_RECOVERY_FILE%
REM del %OUTPUTDIR%\mountlog.txt

goto End

:Error
endlocal
echo "extractwim %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
