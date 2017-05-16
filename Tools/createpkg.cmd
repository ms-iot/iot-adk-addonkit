@echo off

goto START

:Usage
echo Usage: createpkg [CompName.SubCompName]/[packagefile.pkg.xml] [version]
echo    packagefile.pkg.xml....... Package definition XML file
echo    CompName.SubCompName...... Package ComponentName.SubComponent Name
echo        Either one of the above should be specified
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        createpkg sample.pkg.xml
echo        createpkg sample.pkg.xml 10.0.1.0
echo        createpkg Appx.Main

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

if [%EXTN%] == [.pkg.xml] (
    set INPUT_FILE=%~nx1
    set INPUT=%INPUT:.pkg.xml=%
    cd /D %~dp1
) else (
    set INPUT_FILE=%1.pkg.xml
    if exist "%SRC_DIR%\Packages\%1\%1.pkg.xml" (
        cd /D "%SRC_DIR%\Packages\%1"
    ) else if exist "%COMMON_DIR%\Packages\%1\%1.pkg.xml" (
        cd /D "%COMMON_DIR%\Packages\%1"
    ) else (
        echo Error : %1 is not a valid input.
        goto Usage
    )
)

if not defined PRODUCT (
    set PRODUCT=SampleA
)

if not defined RELEASE_DIR (
    set RELEASE_DIR=%CD%
)

echo Creating %INPUT_FILE% Package with version %PKG_VER% for %PRODUCT%

REM check if customizations.xml is present, if so create provisioning package
if exist "%CUSTOMIZATIONS%.xml" (
    if not exist "%INPUT%.ppkg" (
        echo  Creating %INPUT%.ppkg...
        call createprovpkg.cmd %CUSTOMIZATIONS%.xml %INPUT%.ppkg
   )
)

call pkggen.exe "%INPUT_FILE%" /config:"%PKG_CONFIG_XML%" /output:"%PKGBLD_DIR%" /version:%PKG_VER% /build:fre /cpu:%BSP_ARCH% /variables:"_RELEASEDIR=%RELEASE_DIR%\;PROD=%PRODUCT%;PRJDIR=%SRC_DIR%;COMDIR=%COMMON_DIR%;BSPVER=%PKG_VER%;BSPARCH=%BSP_ARCH%;OEMNAME=%OEM_NAME%" /onecore

if errorlevel 0 (
    REM remove unused .spkg files
    del %PKGBLD_DIR%\*.spkg
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
