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

REM Environment configurations
set PATH=%KITSROOT%tools\bin\i386;%PATH%
set AKROOT=%KITSROOT%
set WPDKCONTENTROOT=%KITSROOT%
set PKG_CONFIG_XML=%KITSROOT%Tools\bin\i386\pkggen.cfg.xml
set WINPE_ROOT=%KITSROOT%Assessment and Deployment Kit\Windows Preinstallation Environment

set ARCH=%1
set BSP_ARCH=%1

set HIVE_ROOT=%KITSROOT%CoreSystem\%WDK_VERSION%\%BSP_ARCH%
set WIM_ROOT=%KITSROOT%CoreSystem\%WDK_VERSION%\%BSP_ARCH%

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
set PKGLOG_DIR=%PKGBLD_DIR%\logs
set TOOLS_DIR=%IOTADK_ROOT%\Tools

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

echo BSP_ARCH    : %BSP_ARCH%
echo BSP_VERSION : %BSP_VERSION%
echo.

exit /b 0
