@echo off

goto START

:Usage
echo Usage: VerifyRecovery [Product] [BuildType] [WimMode] [WimDir]
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    WimMode........... Optional, Import/Export - import wim files or export wim files
echo    WimDir............ Required if WimMode specified, Directory containing MainOS/Data/EFIESP wims
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        VerifyRecovery SampleA Test
echo        VerifyRecovery SampleA Retail export C:\Wimfiles
echo        VerifyRecovery SampleB Retail import C:\Wimfiles

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
    echo %CLRRED%Error:Missing prodconfig.txt.%CLREND%
    goto Usage
)

for /f "tokens=1,2 delims== " %%i in (%SRC_DIR%\Products\%PRODUCT%\prodconfig.txt) do (
    set %%i=%%j
)

set OUTPUTDIR=%BLD_DIR%\%PRODUCT%\%2
set IMG_RECOVERY_FILE=%OUTPUTDIR%\%FFUNAME%_Recovery.ffu
set WINPEDIR=%BLD_DIR%\%BSP%
set WINPEFILES=%WINPEDIR%\recovery
REM set VERIFYOPTION=/CheckIntegrity /Verify
set VERIFYOPTION=
set VERIFYRESULT1=Pass
set VERIFYRESULT2=Pass
set VERIFYRESULT3=Pass

for /f "tokens=2 delims=<,> " %%i in ('findstr /L /I "<SOC>" %SRC_DIR%\Products\%PRODUCT%\%2OEMInput.xml') do (
    set SOCNAME=%%i
)

echo. Processing %SOCNAME% device layout in %BSP% bsp...

REM always call this to ensure that there is no stale files
call partitioninfo.cmd %BSP% %SOCNAME%
if %errorlevel% neq 0 ( exit /b 1 )


for /f "tokens=1,2 delims=, " %%i in (%WINPEFILES%\devicelayout.csv) do (
    REM echo PARID_%%i=%%j
    set PARID_%%i=%%j
)

if not exist "%IMG_RECOVERY_FILE%" (
    echo. %CLRRED%Error: RecoveryImage %IMG_RECOVERY_FILE% to validate is not available.%CLREND%
    exit /b 1
)

cd /D %OUTPUTDIR%
echo Mounting %IMG_RECOVERY_FILE% (this can take some time)..
call wpimage mount "%IMG_RECOVERY_FILE%" > %OUTPUTDIR%\recoverymountlog_verify.txt

REM This will break if there is space in the user account (eg.C:\users\test acct\)
for /f "tokens=3,4,* skip=9 delims= " %%i in (%OUTPUTDIR%\recoverymountlog_verify.txt) do (
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

call %WINPEDIR%\pc_setdrives.cmd
powershell -Command "(gc %WINPEDIR%\pc_diskpart_assign.txt) -replace 'DISKNR', '%DISK_NR%' | Out-File %WINPEDIR%\diskpart_assign.txt -Encoding utf8"
powershell -Command "(gc %WINPEDIR%\pc_diskpart_remove.txt) -replace 'DISKNR', '%DISK_NR%' | Out-File %WINPEDIR%\diskpart_remove.txt -Encoding utf8"

echo. Assigning drive letters 
diskpart < %WINPEDIR%\diskpart_assign.txt > %OUTPUTDIR%\verifyrecoverydiskpart.log
if %errorlevel% neq 0 (
    echo Error in assiging drive letters.. Removing drive letters
    diskpart < %WINPEDIR%\diskpart_remove.txt >> %OUTPUTDIR%\verifyrecoverydiskpart.log
    goto Error
)

echo extracting the wims from the MMOS dir
set EXTRACTDIR=%OUTPUTDIR%\extract
if exist %EXTRACTDIR% ( rmdir /s /q %EXTRACTDIR% )
mkdir %EXTRACTDIR%
copy %DL_MMOS%:\mainos.wim %EXTRACTDIR%\
copy %DL_MMOS%:\efiesp.wim %EXTRACTDIR%\
copy %DL_MMOS%:\data.wim %EXTRACTDIR%\
echo Applying EFIESP.wim to %DL_MMOS% drive
dism /apply-image /ImageFile:%EXTRACTDIR%\efiesp.wim /index:1 /ApplyDir:%DL_EFIESP%:\ %VERIFYOPTION% || set VERIFYRESULT1=Failed
echo Applying Data.wim to %DL_Data% drive
dism /apply-image /ImageFile:%EXTRACTDIR%\data.wim /index:1 /ApplyDir:%DL_Data%:\ /Compact %VERIFYOPTION% || set VERIFYRESULT2=Failed
echo Applying MainOS.wim to %DL_MainOS% drive
dism /apply-image /ImageFile:%EXTRACTDIR%\mainos.wim /index:1 /ApplyDir:%DL_MainOS%:\ /Compact %VERIFYOPTION% || set VERIFYRESULT3=Failed
echo Removing drive letters
diskpart < %WINPEDIR%\diskpart_remove.txt >> %OUTPUTDIR%\verifyrecoverydiskpart.log

echo Unmounting %DISK_DRIVE%
wpimage dismount -physicaldrive %DISK_DRIVE% 
del %OUTPUTDIR%\recoverymountlog_verify.txt

echo .
echo Result for: %IMG_RECOVERY_FILE%
echo Result of EFIESP.wim verification: %VERIFYRESULT1%
echo Result of DATA.wim verification: %VERIFYRESULT2%
echo Result of MAINOS.wim verification: %VERIFYRESULT3%
echo .

popd
endlocal
exit /b

:Error
echo Unmounting %DISK_DRIVE% without saving
wpimage dismount -physicaldrive %DISK_DRIVE% 
del %OUTPUTDIR%\recoverymountlog_verify.txt
popd
endlocal
exit /b 1
