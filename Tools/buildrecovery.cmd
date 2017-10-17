@echo off

goto START

:Usage
echo Usage: buildrecovery [Product] [BuildType] [WimMode] [WimDir]
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    WimMode........... Optional, Import/Export - import wim files or export wim files
echo    WimDir............ Required if WimMode specified, Directory containing MainOS/Data/EFIESP wims
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildrecovery SampleA Test
echo        buildrecovery SampleA Retail export C:\Wimfiles
echo        buildrecovery SampleB Retail import C:\Wimfiles

exit /b 1

:START
setlocal
pushd
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if /I not [%2] == [Retail] ( if /I not [%2] == [Test] goto Usage )

set WIMMODE=%3
set WIMDIR=%4
if not [%WIMMODE%] == [] (
    if [%WIMDIR%] == [] ( goto Usage )
    if /I [%WIMMODE%] == [Import] (
        if not exist %WIMDIR%\efiesp.wim goto Usage
        if not exist %WIMDIR%\mainos.wim goto Usage
        if not exist %WIMDIR%\data.wim goto Usage
    ) else if /I not [%WIMMODE%] == [Export] goto Usage
)

if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    goto END
)

if not defined FFUNAME ( set FFUNAME=Flash)
set PRODUCT=%1

if not exist %SRC_DIR%\Products\%PRODUCT% (
   echo %PRODUCT% not found. Available products listed below
   dir /b /AD %SRC_DIR%\Products
   goto Usage
)

if not exist %SRC_DIR%\Products\%PRODUCT%\prodconfig.txt (
    echo %CLRRED%Error:Missing prodconfig.txt.%CLREND%
    goto Usage
)

for /f "tokens=1,2 delims== " %%i in (%SRC_DIR%\Products\%PRODUCT%\prodconfig.txt) do (
    set %%i=%%j
)

set OUTPUTDIR=%BLD_DIR%\%PRODUCT%\%2
set WINPEDIR=%BLD_DIR%\%BSP%
set WINPEFILES=%WINPEDIR%\recovery
set IMG_FILE=%OUTPUTDIR%\%FFUNAME%.ffu

for /f "tokens=2 delims=<,> " %%i in ('findstr /L /I "<SOC>" %SRC_DIR%\Products\%PRODUCT%\%2OEMInput.xml') do (
    set SOCNAME=%%i
)

echo. Processing %SOCNAME% device layout in %BSP% bsp...

REM Creating WinPE script always to ensure that there is no stale generated files
echo Creating WinPE.wim
call newwinpe.cmd %BSP% %SOCNAME%
if %errorlevel% neq 0 goto END

if not exist "%IMG_FILE%" (
    echo Building the base FFU
    call buildimage %PRODUCT% %2
)

if not exist "%IMG_FILE%" (
    echo.%CLRRED%Error: Building the base FFU failed.%CLREND%
    goto END
)

set IMG_RECOVERY_FILE=%OUTPUTDIR%\%FFUNAME%_Recovery.ffu
cd /D %OUTPUTDIR%

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
set DISK_NR=%DISK_DRIVE:~-1%
set MMOSDIR=%MOUNT_PATH%\mmos
if not exist "%MMOSDIR%" (
    echo.%CLRRED%Error: Recovery partition MMOS missing in device layout.%CLREND%
    goto Error
)

call %WINPEDIR%\pc_setdrives.cmd

if /I [%WIMMODE%] == [Import] (
    REM Wimfiles provided. Copy the wim files from that directory
    echo. Importing wim files from %WIMDIR%
    copy %WIMDIR%\efiesp.wim %MMOSDIR% >nul
    copy %WIMDIR%\mainos.wim %MMOSDIR% >nul
    copy %WIMDIR%\data.wim %MMOSDIR% >nul
    copy %WIMDIR%\RecoveryImageVersion.txt %MMOSDIR% >nul

) else (
    REM wim files not provided. Extract the wim files from the FFU itself.

    powershell -Command "(gc %WINPEDIR%\pc_diskpart_assign.txt) -replace 'DISKNR', '%DISK_NR%' | Out-File %WINPEDIR%\diskpart_assign.txt -Encoding utf8"
    powershell -Command "(gc %WINPEDIR%\pc_diskpart_remove.txt) -replace 'DISKNR', '%DISK_NR%' | Out-File %WINPEDIR%\diskpart_remove.txt -Encoding utf8"

    echo. Assigning drive letters
    diskpart < %WINPEDIR%\diskpart_assign.txt > %OUTPUTDIR%\buildrecoverydiskpart.log
    if %errorlevel% neq 0 (
        REM something went wrong. So try diskpart remove and proceed to exit.
        echo.%CLRRED%Diskpart failed. Please check %OUTPUTDIR%\buildrecoverydiskpart.log.%CLREND%
        diskpart < %WINPEDIR%\diskpart_remove.txt >> %OUTPUTDIR%\buildrecoverydiskpart.log
        goto Error
    )

    echo Extracting EFIESP wim from %DL_EFIESP%:\
    dism /Capture-Image /ImageFile:%OUTPUTDIR%\efiesp.wim /CaptureDir:%DL_EFIESP%:\ /Name:"EFIESP"

    echo Extracting data wim
    dism /Capture-Image /ImageFile:%OUTPUTDIR%\data.wim /CaptureDir:%MOUNT_PATH%Data\ /Name:"DATA" /Compress:max

    echo Extracting MainOS wim, this can take a while too..
    dism /Capture-Image /ImageFile:%OUTPUTDIR%\mainos.wim /CaptureDir:%MOUNT_PATH% /Name:"MainOS" /Compress:max

    echo Removing drive letters
    diskpart < %WINPEDIR%\diskpart_remove.txt >> %OUTPUTDIR%\buildrecoverydiskpart.log

    echo %BSP_VERSION% > %OUTPUTDIR%\RecoveryImageVersion.txt
    copy %OUTPUTDIR%\efiesp.wim %MMOSDIR% >nul
    copy %OUTPUTDIR%\mainos.wim %MMOSDIR% >nul
    copy %OUTPUTDIR%\data.wim %MMOSDIR% >nul
    copy %OUTPUTDIR%\RecoveryImageVersion.txt %MMOSDIR% >nul

    if /I [%WIMMODE%] == [Export] (
        REM Wimfiles provided. Copy the wim files from that directory
        echo. Exporting wim files to %WIMDIR%
        if not exist %WIMDIR% ( mkdir %WIMDIR% )
        copy %OUTPUTDIR%\efiesp.wim %WIMDIR% >nul
        copy %OUTPUTDIR%\mainos.wim %WIMDIR% >nul
        copy %OUTPUTDIR%\data.wim %WIMDIR% >nul
        copy %OUTPUTDIR%\RecoveryImageVersion.txt %WIMDIR% >nul
    )
)
echo Copying winpe.wim..
copy %WINPEDIR%\winpe.wim %MMOSDIR% >nul
copy "%IOTADK_ROOT%\Templates\startrecovery.cmd" %MMOSDIR% >nul

if exist %SRC_DIR%\BSP\%BSP%\tools\br_addfiles.cmd (
   echo. Adding %BSP% specifics 
   call %SRC_DIR%\BSP\%BSP%\tools\br_addfiles.cmd
)

echo Unmounting %DISK_DRIVE%
wpimage dismount -physicaldrive %DISK_DRIVE% -imagepath %IMG_RECOVERY_FILE% -nosign
del %OUTPUTDIR%\mountlog.txt

popd
endlocal
exit /b

:Error
echo Unmounting %DISK_DRIVE% without saving
wpimage dismount -physicaldrive %DISK_DRIVE%
del %OUTPUTDIR%\mountlog.txt
:END
popd
endlocal
exit /b 1
