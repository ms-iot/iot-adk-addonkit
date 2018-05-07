@echo off
goto START

:USAGE
echo Usage: setenv arch
echo    arch....... Required, %SUPPORTED_ARCH%
echo    [/?]........Displays this usage string.
echo    Example:
echo        setenv arm

exit /b 1

:START

if [%1] == [/?] goto USAGE
if [%1] == [-?] goto USAGE
if [%1] == [] goto USAGE

set SUPPORTED_ARCH=arm x86 x64

for %%A in (%SUPPORTED_ARCH%) do (
    if /I [%%A] == [%1] (
        set FOUND=%1
    )
)

if not defined FOUND (
    echo.%CLRRED%Error: %1 not supported%CLREND%
    goto USAGE
) else (
    echo Configuring for %1 architecture
)
set FOUND=
set ARCH=%1
set BSP_ARCH=%1
echo.KitsRoot       : [%KITSROOT%]
echo.WDKContentRoot : [%WDKContentRoot%]

if defined WDKContentRoot (
    set "TOOLSROOT=%WDKContentRoot%"
) else (
    set "TOOLSROOT=%KITSROOT%"
)

REM Environment configurations
set PATH=%TOOLSROOT%tools\bin\i386;%PATH%
set AKROOT=%KITSROOT%
set WPDKCONTENTROOT=%TOOLSROOT%
set PKG_CONFIG_XML=%TOOLSROOT%Tools\bin\i386\pkggen.cfg.xml
set WINPE_ROOT=%KITSROOT%Assessment and Deployment Kit\Windows Preinstallation Environment

if /I [%1] == [x64] ( set BSP_ARCH=amd64)

REM The following variables ensure the package is appropriately signed
set SIGN_OEM=1
set SIGN_WITH_TIMESTAMP=0

REM Local project settings
if not defined MSPACKAGE ( set "MSPACKAGE=%KITSROOT%MSPackages" )
set MSPKG_DIR=%MSPACKAGE%\Retail\%BSP_ARCH%\fre
set COMMON_DIR=%IOTADK_ROOT%\Common
set SRC_DIR=%IOTADK_ROOT%\Source-%1
set PKGSRC_DIR=%SRC_DIR%\Packages
set BSPSRC_DIR=%SRC_DIR%\BSP
set PKGUPD_DIR=%SRC_DIR%\Updates
set BLD_DIR=%IOTADK_ROOT%\Build\%BSP_ARCH%
set PKGBLD_DIR=%BLD_DIR%\pkgs
set PPKGBLD_DIR=%BLD_DIR%\ppkgs
set PKGLOG_DIR=%PKGBLD_DIR%\logs
set TOOLS_DIR=%IOTADK_ROOT%\Tools
set TMP=%BLD_DIR%\Temp
set TEMP=%BLD_DIR%\Temp
if not exist %TMP% ( mkdir %TMP% )

if not exist %PPKGBLD_DIR% ( mkdir %PPKGBLD_DIR% )
if not exist %PPKGBLD_DIR%\logs ( mkdir %PPKGBLD_DIR%\logs )
if not exist %PKGLOG_DIR% ( mkdir %PKGLOG_DIR% )

REM Set the location of the BSP packages, currently set to the build folder. Override this to point to actual location.
if not defined BSPPKG_DIR (
    set BSPPKG_DIR=%PKGBLD_DIR%
)
set MIN_ADK_VERSION=16299
REM Check ADK version
if /i %ADK_VERSION% LSS %MIN_ADK_VERSION% (
    echo.%CLRRED%Error: ADK version %ADK_VERSION% is not supported with this tools version. Minimum  version required is %MIN_ADK_VERSION%%CLREND%
    pause
    exit
)

set CUSTOMIZATIONS=customizations

call setversion.cmd
call retailsign.cmd Off

echo BSP_ARCH    : %BSP_ARCH%
echo BSP_VERSION : %BSP_VERSION%
echo BSPPKG_DIR  : %BSPPKG_DIR%
echo MSPKG_DIR   : %MSPKG_DIR%
echo.

exit /b 0
