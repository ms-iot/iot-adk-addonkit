@echo off

goto START

:Usage
echo Usage: buildprovpkg [CompName.SubCompName]/[ProductName]/[Dir]/[All]/Clean
echo    CompName.SubCompName...... Package Name under Packages directory
echo    ProductName............... Product Name under Products directory
echo    Dir....................... Dir path containing customizations.xml
echo    All....................... All prov packages under \Packages directory and \Products directory are built
echo    Clean..................... Removes all ppkg files
echo        One of the above should be specified
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildprovpkg Provisioning.Enroll
echo        buildprovpkg SampleA
echo        buildprovpkg All
echo        buildprovpkg Clean

exit /b 1

:START
setlocal
pushd
if not exist %PPKGBLD_DIR% ( mkdir %PPKGBLD_DIR% )
if not exist %PPKGBLD_DIR%\logs ( mkdir %PPKGBLD_DIR%\logs )
if not exist %PKGLOG_DIR% ( mkdir %PKGLOG_DIR% )

set COMMON_PKG=%COMMON_DIR%\Packages
set PRODUCTS_DIR=%SRC_DIR%\Products

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I [%1] == [All] (
    echo Processing all provisioning packages
    cd %COMMON_PKG%
    dir /b /AD  > %PPKGBLD_DIR%\commonprovlist.txt
    cd %PKGSRC_DIR%
    dir /b /AD  >> %PPKGBLD_DIR%\commonprovlist.txt
    REM cd %PRODUCTS_DIR%
    REM dir /b /AD  >> %PPKGBLD_DIR%\commonprovlist.txt

    for /f "delims=" %%i in (%PPKGBLD_DIR%\commonprovlist.txt) do (
        call :SUB_PROCESSLIST %%i
    )
    del %PPKGBLD_DIR%\commonprovlist.txt
) else if /I [%1] == [Clean] (
    del /S /Q %COMMON_DIR%\*.ppkg %COMMON_DIR%\*.cat >nul 2>nul
    del /S /Q %PKGSRC_DIR%\*.ppkg %PKGSRC_DIR%\*.cat >nul 2>nul
    del /S /Q %PRODUCTS_DIR%\*.ppkg %PRODUCTS_DIR%\*.cat >nul 2>nul
    del /S /Q "%HOMEDRIVE%%HOMEPATH%\Documents\Windows Imaging and Configuration Designer (WICD)\Common\*.log" >nul 2>nul
    if exist %PPKGBLD_DIR% (
        del /S /Q "%PPKGBLD_DIR%\*.*" >nul
        echo. All provisioning files cleaned.
    ) else echo Nothing to clean.

) else (
    call :SUB_PROCESSLIST %1 Report
)
popd
endlocal
exit /b

:SUB_PROCESSLIST
if exist "%COMMON_PKG%\%1\customizations.xml" (
    set CUSTOMXMLPATH=%COMMON_PKG%\%1
    set PPKGNAME=%1
) else if exist "%PKGSRC_DIR%\%1\customizations.xml" (
    set CUSTOMXMLPATH=%PKGSRC_DIR%\%1
    set PPKGNAME=%1
) else if exist "%PRODUCTS_DIR%\%1\prov\customizations.xml" (
    set CUSTOMXMLPATH=%PRODUCTS_DIR%\%1\prov
    set PPKGNAME=%1Prov
) else if exist "%1\customizations.xml" (
    set CUSTOMXMLPATH=%1
    set PPKGNAME=Prov
) else (
    if [%2] == [Report] ( echo. Skipping %1 : customizations.xml not found )
    exit /b
)

echo. Processing %1
call createprovpkg.cmd %CUSTOMXMLPATH%\customizations.xml %PPKGBLD_DIR%\%PPKGNAME%.ppkg > %PPKGBLD_DIR%\logs\%PPKGNAME%.ppkg.log
if errorlevel 1 ( echo.%CLRRED%Error : Failed to create %PPKGNAME%.ppkg. See %PPKGBLD_DIR%\%PPKGNAME%.ppkg.log%CLREND% )

exit /b
