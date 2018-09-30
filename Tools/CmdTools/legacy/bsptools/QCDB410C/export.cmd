@echo off

goto START

:Usage
echo Usage: export [src_dir] [dest_dir]
echo    src_dir.............. Required, source directory of the qcdb410c bsp
echo    dest_dir............. Optional, destination directory to extract IoTCore specific bsp. Default is %PKGBLD_DIR%
echo    [/?].................... Displays this usage string.
echo    Example:
echo        export C:\QCDB410C_BSP
endlocal
exit /b 1

:START

setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set BSPCABS=%~dp0\FMCabList.txt
set SRC_DIR=%1

if not exist %SRC_DIR%\prebuilt (
    echo Error: Provide the directory path of BSP containing \prebuilt folder
    exit /b 1
)

if [%2] == [] (
    set DEST_DIR=%PKGBLD_DIR%
) else (
    set DEST_DIR=%2
)

if not exist %DEST_DIR% (
 mkdir %DEST_DIR%
)

for /f "delims=" %%i in (%BSPCABS%) do (
    dir /b /s %SRC_DIR%\%%i >> filelist.txt 
)

for /f "delims=" %%i in (filelist.txt) do (
    echo copying %%i..
    copy %%i %DEST_DIR% >nul 2>nul
)
echo copying Qualcomm.QC8916.OEMDevicePlatform.cab..
copy %SRC_DIR%\prebuilt\8016\cabfiles\DevicePlatformID\8016\SBC\Qualcomm.QC8916.OEMDevicePlatform.cab %DEST_DIR% >nul 2>nul
echo copying Qualcomm.QC8916.qcAlsCalibrationMTP.cab..
copy %SRC_DIR%\prebuilt\8016\cabfiles\mtp\Qualcomm.QC8916.qcAlsCalibrationMTP.cab %DEST_DIR% >nul 2>nul
echo copying Qualcomm.QC8916.qcAlsPrxAPDS9900.cab..
copy %SRC_DIR%\prebuilt\8016\cabfiles\mtp\Qualcomm.QC8916.qcAlsPrxAPDS9900.cab %DEST_DIR% >nul 2>nul
echo copying Qualcomm.QC8916.qcMagAKM8963.cab..
copy %SRC_DIR%\prebuilt\8016\cabfiles\mtp\Qualcomm.QC8916.qcMagAKM8963.cab %DEST_DIR% >nul 2>nul
echo copying Qualcomm.QC8916.qcTouchScreenRegsitry1080p.cab..
copy %SRC_DIR%\prebuilt\8016\cabfiles\mtp\Qualcomm.QC8916.qcTouchScreenRegsitry1080p.cab %DEST_DIR% >nul 2>nul


del filelist.txt
endlocal

echo Cab exports done.
exit /b 0
