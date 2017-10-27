@echo off

goto START

:Usage
echo Usage: createimage ProductName BuildType
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    [/?].............. Displays this usage string.
echo    Example:
echo        createimage SampleA Retail

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if /I not [%2] == [Retail] ( if /I not [%2] == [Test] goto Usage )

REM Checking prerequisites
if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)

set PRODUCT=%1
set PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%
set PRODBLD_DIR=%BLD_DIR%\%1\%2

if not defined FFUNAME ( set FFUNAME=Flash)

set IMGAPP_CUST=

if not exist %SRC_DIR%\Products\%PRODUCT% (
   echo %PRODUCT% not found. Available products listed below
   dir /b /AD %SRC_DIR%\Products
   goto Usage
)
if defined USEUPDATE (
  if not exist %PKGUPD_DIR%\%USEUPDATE% (
    echo %CLRRED%Error: %USEUPDATE% not found. Set USEUPDATE value correctly %CLREND%
    goto Usage
  )
)
REM Read the config info for BSP
for /f "tokens=1,2 delims== " %%i in (%SRC_DIR%\Products\%PRODUCT%\prodconfig.txt) do (
    set PROD_%%i=%%j
)

REM Start processing command
echo Creating %1 %2 Image
echo Build Start Time : %TIME%

if defined USEUPDATE (
    echo %CLRYEL%Using Update folder : %USEUPDATE% %CLREND%
    set /P PKG_VER=<%PKGUPD_DIR%\%USEUPDATE%\versioninfo.txt
    call buildupdate %USEUPDATE%
    echo Copying %USEUPDATE% packages
    copy %BLD_DIR%\%USEUPDATE%-!PKG_VER!\*.cab %PKGBLD_DIR% >nul 2>nul
    set PRODBLD_DIR=%BLD_DIR%\%1\%2-!PKG_VER!
) else (
    set PKG_VER=%BSP_VERSION%
)

echo Building Packages with product specific contents with version %PKG_VER%

REM Invoke BSP specific build hooks
if exist %SRC_DIR%\BSP\%PROD_BSP%\tools\ci_hook.cmd (
    echo. Running %PROD_BSP% specifics
    call %SRC_DIR%\BSP\%PROD_BSP%\tools\ci_hook.cmd
)

call buildpkg.cmd Registry.Version %PKG_VER%

if exist %PRODSRC_DIR%\oemcustomization.cmd (
    call buildpkg.cmd Custom.Cmd
)

if exist %PRODSRC_DIR%\prov\%CUSTOMIZATIONS%.xml (
    call buildprovpkg.cmd %PRODUCT%
    call buildpkg.cmd Provisioning.Auto
)

if exist %PRODSRC_DIR%\CUSConfig (
    echo.Building DeviceTargeting packages
    call buildpkg.cmd %PRODSRC_DIR%\CUSConfig %PKG_VER%
    call buildfm.cmd ocp %PRODUCT% %PKG_VER%
)

REM Invoke buildfm 
call buildfm.cmd oem %PKG_VER%
if %ERRORLEVEL% neq 0 goto Error
call buildfm.cmd bsp %PROD_BSP% %PKG_VER%
if %ERRORLEVEL% neq 0 goto Error

if exist %PRODSRC_DIR%\imagecustomizations.xml (
    set IMGAPP_CUST=/OEMCustomizationXML:"%PRODSRC_DIR%\imagecustomizations.xml" /OEMVersion:"%BSP_VERSION%"
)

echo Creating Image...
REM call ImageApp with the specified parameters
call ImageApp "%PRODBLD_DIR%\%FFUNAME%.ffu" "%PRODSRC_DIR%\%2OEMInput.xml" "%MSPACKAGE%" /CPUType:%BSP_ARCH% %IMGAPP_CUST%

if %ERRORLEVEL% neq 0 goto Error

REM call DevNodeClean
if "%ProgramW6432%"=="" (
   REM run x86
   call DeviceNodeCleanup.x86.exe
) else (
   REM run x64
   call DeviceNodeCleanup.x64.exe
)

echo Build End Time : %TIME%
echo Image creation completed
echo.See %PRODBLD_DIR%\%FFUNAME%.ffu
goto End

:Error
endlocal
echo "CreateImage %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0