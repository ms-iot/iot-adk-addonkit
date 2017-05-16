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
setlocal
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
if not defined MSPACKAGE ( set "MSPACKAGE=%KITSROOT%MSPackages" )
set IMGAPP_CUST=

if not exist %SRC_DIR%\Products\%PRODUCT% (
   echo %PRODUCT% not found. Available products listed below
   dir /b /AD %SRC_DIR%\Products
   goto Usage
)
REM Start processing command
echo Creating %1 %2 Image
echo Build Start Time : %TIME%

echo Building Packages with product specific contents
if exist %PRODSRC_DIR%\oemcustomization.cmd (
    call buildpkg.cmd Custom.Cmd
)

if exist %PRODSRC_DIR%\prov\%CUSTOMIZATIONS%.xml (
    call createprovpkg.cmd %PRODSRC_DIR%\prov\%CUSTOMIZATIONS%.xml %PRODSRC_DIR%\prov\%PRODUCT%Prov.ppkg
    call buildpkg.cmd Provisioning.Auto
)

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
) ELSE (
   REM run x64
   call DeviceNodeCleanup.x64.exe
)

echo Build End Time : %TIME%
echo Image creation completed
goto End

:Error
endlocal
echo "CreateImage %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0