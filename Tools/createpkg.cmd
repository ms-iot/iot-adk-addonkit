@echo off

goto START

:Usage
echo Usage: createpkg [CompName.SubCompName]/[packagefile.pkg.xml]/[packagefile.wm.xml] [version]
echo    packagefile.pkg.xml/.wm.xml....... Package definition XML file
echo    CompName.SubCompName.............. Package ComponentName.SubComponent Name
echo        Either one of the above should be specified
echo    [version]......................... Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?].............................. Displays this usage string.
echo    Example:
echo        createpkg sample.pkg.xml
echo        createpkg sample.wm.xml
echo        createpkg sample.pkg.xml 10.0.1.0
echo        createpkg sample.wm.xml 10.0.1.0
echo        createpkg Custom.Cmd

exit /b 1

:START
if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)
setlocal
pushd
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] (
    REM Using version info set in BSP_VERSION
    set PKG_VER=%BSP_VERSION%
) else (
    REM Use the version provided in the paramter
    REM TODO validate version format
    set PKG_VER=%2
)
set INPUT=%1
set EXTN=%INPUT:~-8%
set EXTN1=%INPUT:~-7%

if [%EXTN%] == [.pkg.xml] (
    set INPUT_FILE=%~nx1
    set INPUT=%INPUT:.pkg.xml=%
    cd /D %~dp1
) else if [%EXTN1%] == [.wm.xml] (
    set INPUT_FILE=%~nx1
    set INPUT=%INPUT:.wm.xml=%
    cd /D %~dp1
) else (
    set INPUT_FILE=%1.wm.xml
    if exist "%SRC_DIR%\Packages\%1\%1.wm.xml" (
        cd /D "%SRC_DIR%\Packages\%1"
    ) else if exist "%COMMON_DIR%\Packages\%1\%1.wm.xml" (
        cd /D "%COMMON_DIR%\Packages\%1"
    ) else (
        echo Error : %1 is not a valid input.
        goto Usage
    )
)

if not defined PRODUCT (
    REM Pick the first one as the product.
    for /f %%a in ('dir /B /O-N %SRC_DIR%\Products') do ( set PRODUCT=%%a)
)

if not defined RELEASE_DIR (
    set RELEASE_DIR=%CD%
)

echo Creating %INPUT_FILE% Package with version %PKG_VER% for %PRODUCT%
set PPKG_FILE=%INPUT_FILE:.wm.xml=.ppkg%
REM check if customizations.xml is present, if so create provisioning package
if exist "customizations.xml" (
    echo  Creating %PPKG_FILE%...
    call createprovpkg.cmd customizations.xml %PPKGBLD_DIR%\%PPKG_FILE% > %PPKGBLD_DIR%\logs\%PPKG_FILE%.log
)

if not exist "%INPUT%.wm.xml" (
    call convertpkg.cmd "%INPUT_FILE%"
)

set BUILDTIME=%date:~-2,2%%date:~4,2%%date:~7,2%-%time:~0,2%%time:~3,2%

call pkggen.exe "%INPUT%.wm.xml" /output:"%PKGBLD_DIR%" /version:%PKG_VER% /build:fre /cpu:%BSP_ARCH% /variables:"_RELEASEDIR=%RELEASE_DIR%\;PROD=%PRODUCT%;PRJDIR=%SRC_DIR%;COMDIR=%COMMON_DIR%;BSPVER=%PKG_VER%;BSPARCH=%BSP_ARCH%;OEMNAME=%OEM_NAME%;BUILDTIME=%BUILDTIME%;BLDDIR=%BLD_DIR%" /onecore /universalbsp

if errorlevel 0 (
    echo Package creation completed
) else (
    echo Package creation failed with error %ERRORLEVEL%
    goto :Error
)
popd
endlocal
exit /b 0

:Error
popd
endlocal
exit /b -1
