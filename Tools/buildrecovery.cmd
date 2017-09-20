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
    exit /b 1
)

if not defined FFUNAME ( set FFUNAME=Flash)
set PRODUCT=%1

if not exist %SRC_DIR%\Products\%PRODUCT% (
   echo %PRODUCT% not found. Available products listed below
   dir /b /AD %SRC_DIR%\Products
   goto Usage
)

if not exist %SRC_DIR%\Products\%PRODUCT%\prodconfig.txt (
    echo %CLRRED%Error:Please create prodconfig.txt with BSP info.%CLREND%
    goto Usage
)

for /f "tokens=1,2 delims== " %%i in (%SRC_DIR%\Products\%PRODUCT%\prodconfig.txt) do (
    set %%i=%%j
)

set OUTPUTDIR=%BLD_DIR%\%1\%2
set IMG_FILE=%OUTPUTDIR%\%FFUNAME%.ffu

if not exist "%IMG_FILE%" (
    echo Building the base FFU
    call buildimage %1 %2
)

if not exist "%IMG_FILE%" (
REM File not found even after invoking buildimage. 
    echo.%CLRRED%Error: Building the base FFU failed.%CLREND%
    exit /b 1
)

if not exist %BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE\winpe.wim (
    echo.%CLRRED%Error: WinPE not available at %BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE\winpe.wim. See newwinpe.cmd %CLREND%
    exit /b 1
)

set IMG_RECOVERY_FILE=%OUTPUTDIR%\%FFUNAME%_Recovery.ffu
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

if not exist "%MOUNT_PATH%\mmos\" (
    echo.%CLRRED%Error: Recovery partition MMOS missing in device layout.%CLREND%
    goto Error
)

if /I [%WIMMODE%] == [Import] (
    REM Wimfiles provided. Copy the wim files from that directory
    echo. Importing wim files from %WIMDIR%
    copy %WIMDIR%\EFIESP.wim %MOUNT_PATH%\mmos >nul
    copy %WIMDIR%\MainOS.wim %MOUNT_PATH%\mmos >nul
    copy %WIMDIR%\Data.wim %MOUNT_PATH%\mmos >nul
    copy %WIMDIR%\RecoveryImageVersion.txt %MOUNT_PATH%\mmos >nul
    
) else (
    REM wim files not provided. Extract the wim files from the FFU itself.
    if defined EFI_PAR_NR (
        echo sel dis %DISK_NR% > %OUTPUTDIR%\diskpartassign.txt
        echo sel par %EFI_PAR_NR% >> %OUTPUTDIR%\diskpartassign.txt
        echo assign letter=x >> %OUTPUTDIR%\diskpartassign.txt
        echo exit >> %OUTPUTDIR%\diskpartassign.txt

        echo sel dis %DISK_NR% > %OUTPUTDIR%\diskpartunassign.txt
        echo sel par %EFI_PAR_NR% >> %OUTPUTDIR%\diskpartunassign.txt
        echo remove letter=x >> %OUTPUTDIR%\diskpartunassign.txt
        echo exit >> %OUTPUTDIR%\diskpartunassign.txt

        echo Extracting EFIESP wim
        diskpart < %OUTPUTDIR%\diskpartassign.txt
        if exist X:\EFI (
            dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\efiesp.wim /CaptureDir:X:\ /Name:"\EFIESP"
        ) else (
            echo.%CLRYEL%Warning:EFI_PAR_NR is incorrect. EFIESP wim is skipped%CLREND% 
        )
        diskpart < %OUTPUTDIR%\diskpartunassign.txt
    ) else (
        echo.%CLRYEL%Warning: EFI partition number EFI_PAR_NR not specified in prodconfig.txt. Skipping EFIESP.wim%CLREND%
    )

    echo Extracting data wim
    dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\data.wim /CaptureDir:%MOUNT_PATH%Data\ /Name:"DATA" /Compress:max

    echo Extracting MainOS wim, this can take a while too..
    dism /Capture-Image /ImageFile:%MOUNT_PATH%\mmos\mainos.wim /CaptureDir:%MOUNT_PATH% /Name:"MainOS" /Compress:max

    echo %BSP_VERSION% > %MOUNT_PATH%\mmos\RecoveryImageVersion.txt
    if /I [%WIMMODE%] == [Export] (
        REM Wimfiles provided. Copy the wim files from that directory
        echo. Exporting wim files to %WIMDIR%
        if not exist %WIMDIR% ( mkdir %WIMDIR% )
        copy %MOUNT_PATH%\mmos\EFIESP.wim %WIMDIR% >nul
        copy %MOUNT_PATH%\mmos\MainOS.wim %WIMDIR% >nul
        copy %MOUNT_PATH%\mmos\Data.wim %WIMDIR% >nul
        copy %MOUNT_PATH%\mmos\RecoveryImageVersion.txt %WIMDIR% >nul
    )
)
echo Copying winpe.wim..
copy %BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE\winpe.wim %MOUNT_PATH%\mmos >nul
copy %BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE\startrecovery.cmd %MOUNT_PATH%\mmos >nul

echo Unmounting %DISK_DRIVE%
wpimage dismount -physicaldrive %DISK_DRIVE% -imagepath %IMG_RECOVERY_FILE% -nosign
del %OUTPUTDIR%\mountlog.txt

endlocal
exit /b

:Error
echo Unmounting %DISK_DRIVE% without saving
wpimage dismount -physicaldrive %DISK_DRIVE% 
del %OUTPUTDIR%\mountlog.txt
endlocal
exit /b 1
