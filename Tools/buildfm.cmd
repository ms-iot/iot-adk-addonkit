@echo off

goto START

:Usage
echo Usage: buildfm [oem/bsp/all] [bspname] [version]
echo    [oem/bsp/all] ....... Specify oem to build oemfm/oemcommonfm files, bsp for bsp, all for building both
echo    [bspname] ........... Mandatory for bsp; not required for oem/all
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?]      ........... Displays this usage string.
echo    Example:
echo        buildfm oem
echo        buildfm bsp Rpi2
echo        buildfm all

echo Existing BSPs are
dir /b /AD %BSPSRC_DIR%
exit /b 1

:START

setlocal

if [%1] == [/?] goto Usage
if [%1] == [] goto Usage

if not exist %BLD_DIR%\InputFMs ( mkdir %BLD_DIR%\InputFMs )

if /I [%1] ==[oem] (
    call :PKG_VERSION %2
    call :BUILDFM_OEM
) else if /I [%1] == [bsp] (
    if [%2] == [] goto Usage
    if /i not exist %BSPSRC_DIR%\%2 (
        echo Error : %2 does not exist
        goto Usage
    )
    call :PKG_VERSION %3
    call :BUILDFM_BSP %2
) else if /I [%1] == [all] (
    call :PKG_VERSION %2
    call :BUILDFM_OEM
    dir /b /AD %BSPSRC_DIR% > %PKGLOG_DIR%\bsplist.txt
    for /f "delims=" %%i in (%PKGLOG_DIR%\bsplist.txt) do (
       call :BUILDFM_BSP %%i
    )
) else ( goto Usage )

del %PKGBLD_DIR%\*.spkg >nul 2>nul
del %PKGBLD_DIR%\*.merged.txt >nul 2>nul
del %BLD_DIR%\buildfm_errors.txt >nul 2>nul
if exist %PKGLOG_DIR%\bsplist.txt ( del %PKGLOG_DIR%\bsplist.txt )

endlocal
exit /b

:PKG_VERSION
if [%1] == [] (
    REM Using version info set in BSP_VERSION
    set PKG_VER=%BSP_VERSION%
) else (
    REM Use the version provided in the paramter
    REM TODO validate version format
    set PKG_VER=%1
)
exit /b 0

:BUILDFM_OEM
echo. Running FeatureMerger for OEM packages
echo.  Exporting OEMFM files
powershell -Command "(gc %PKGSRC_DIR%\OEMFM.xml) -replace '%%PKGBLD_DIR%%', '%PKGBLD_DIR%' -replace '%%OEM_NAME%%', '%OEM_NAME%' | Out-File %BLD_DIR%\InputFMs\OEMFM.xml -Encoding utf8"
powershell -Command "(gc %COMMON_DIR%\Packages\OEMCommonFM.xml) -replace '%%PKGBLD_DIR%%', '%PKGBLD_DIR%' -replace '%%OEM_NAME%%', '%OEM_NAME%' | Out-File %BLD_DIR%\InputFMs\OEMCommonFM.xml -Encoding utf8"
powershell -Command "(gc %PKGSRC_DIR%\OEMFMFileList.xml) -replace 'OEM_NAME', '%OEM_NAME%'  | Out-File %BLD_DIR%\InputFMs\OEMFMFileList.xml -Encoding utf8"

echo.  Processing OEMFMFileList.xml
FeatureMerger %BLD_DIR%\InputFMs\OEMFMFileList.xml %PKGBLD_DIR% %PKG_VER% %BLD_DIR%\MergedFMs /InputFMDir:%BLD_DIR%\InputFMs /Languages:en-us /Resolutions:1024x768 /ConvertToCBS /variables:_cputype=%BSP_ARCH%;buildtype=fre;releasetype=production > %BLD_DIR%\buildfm_oem.log

findstr /L "fatal" %BLD_DIR%\buildfm_oem.log > %BLd_DIR%\buildfm_errors.txt
for %%B in ("%BLD_DIR%\buildfm_errors.txt") do if %%~zB gtr 0 (
    echo.  %CLRRED%Error: Featuremerger failed for OEMFMFileList.xml. See %BLd_DIR%\buildfm_oem.log%CLREND%
)
exit /b 0

:BUILDFM_BSP
echo. Running FeatureMerger for %1
echo.  Exporting %1 FM files
dir /b %BSPSRC_DIR%\%1\Packages\*FM*.xml > %BLD_DIR%\%1FMFiles.txt
for /f "delims=" %%A in (%BLD_DIR%\%1FMFiles.txt) do (

    powershell -Command "(gc %BSPSRC_DIR%\%1\Packages\%%A) -replace '%%PKGBLD_DIR%%', '%PKGBLD_DIR%' -replace '%%OEM_NAME%%', '%OEM_NAME%' -replace '%%BSPPKG_DIR%%', '%BSPPKG_DIR%' -replace '%%MSPKG_DIR%%', '%MSPKG_DIR%' | Out-File %BLD_DIR%\InputFMs\%%A -Encoding utf8"
)
del %BLD_DIR%\%1FMFiles.txt >nul 2>nul
powershell -Command "(gc %BSPSRC_DIR%\%1\Packages\%1FMFileList.xml) -replace 'OEM_NAME', '%OEM_NAME%' | Out-File %BLD_DIR%\InputFMs\%1FMFileList.xml -Encoding utf8"

echo.  Processing %1FMFileList.xml
FeatureMerger %BLD_DIR%\InputFMs\%1FMFileList.xml %PKGBLD_DIR% %PKG_VER% %BLD_DIR%\MergedFMs /InputFMDir:%BLD_DIR%\InputFMs /Languages:en-us /Resolutions:1024x768 /ConvertToCBS /variables:_cputype=%BSP_ARCH%;buildtype=fre;releasetype=production > %BLD_DIR%\buildfm_bsp_%1.log

findstr /L "fatal" %BLD_DIR%\buildfm_bsp_%1.log > %BLD_DIR%\buildfm_errors.txt
for %%B in ("%BLD_DIR%\buildfm_errors.txt") do if %%~zB gtr 0 (
    echo.  %CLRRED%Error: Featuremerger failed for %1FMFileList.xml. See %BLD_DIR%\buildfm_bsp_%1.log%CLREND%
)
exit /b 0
