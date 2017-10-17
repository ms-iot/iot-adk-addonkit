:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new product
:: usage : newproduct <product name> <bsp name>
@echo off

goto START

:Usage
echo Usage: newproduct ProductName [BSPName]
echo    ProductName....... Required, Name of the product to be created.
echo    BSPName........... Optional, Name of the BSP to be used. Default : QCDB410C for arm, MBM for x86
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newproduct SampleA MBM
echo Existing products are
dir /b /AD %SRC_DIR%\Products

echo Existing BSPs are
dir /b /AD %SRC_DIR%\BSP

exit /b 1

:START
setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] (
    if [%ARCH%] == [arm] (
        set BSPNAME=QCDB410C
    ) else if [%ARCH%] == [x86] (
        set BSPNAME=MBM
    ) else (
        echo No suitable BSP found. Specify required BSP
        goto Usage
    )
) else (
    set BSPNAME=%2
)

if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)
:: Error Checks

if /i exist %SRC_DIR%\Products\%1 (
    echo Error : %1 already exists;
    goto End
)

if /i not exist %SRC_DIR%\BSP\%BSPNAME% (
    echo Error : %BSPNAME% not found
    goto End
)

:: Start processing command
echo Creating %1 Product with BSP %BSPNAME%
set PRODUCT=%1
set PRODSRC_DIR=%SRC_DIR%\Products\%PRODUCT%

mkdir "%PRODSRC_DIR%"
mkdir "%PRODSRC_DIR%\prov"

copy %BSPSRC_DIR%\%BSPNAME%\OEMInputSamples\RetailOEMInput.xml %PRODSRC_DIR%\RetailOEMInput.xml >nul
copy %BSPSRC_DIR%\%BSPNAME%\OEMInputSamples\TestOEMInput.xml %PRODSRC_DIR%\TestOEMInput.xml >nul

copy "%IOTADK_ROOT%\Templates\oemcustomization.cmd" %PRODSRC_DIR%\oemcustomization.cmd >nul
REM Get a new GUID for the Provisioning config file
powershell -Command "[System.Guid]::NewGuid().toString() | Out-File %PRODSRC_DIR%\uuid.txt -Encoding ascii"
set /p NEWGUID=<%PRODSRC_DIR%\uuid.txt
del %PRODSRC_DIR%\uuid.txt

powershell -Command "(gc %IOTADK_ROOT%\Templates\%CUSTOMIZATIONS%.xml) -replace '{Product}', '%PRODUCT%' -replace 'GUID', '%NEWGUID%' -replace '{OEMNAME}', '%OEM_NAME%' | Out-File %PRODSRC_DIR%\prov\%CUSTOMIZATIONS%.xml -Encoding utf8"

REM Store BSP info for the product for later used
echo BSP=%BSPNAME%> %PRODSRC_DIR%\prodconfig.txt

REM Invoke BSP specific build hooks
if exist %SRC_DIR%\BSP\%BSPNAME%\tools\np_hook.cmd (
    echo. Running %BSPNAME% specifics
    call %SRC_DIR%\BSP\%BSPNAME%\tools\np_hook.cmd
)

echo %1 product directories ready
goto End


:Error
endlocal
echo "newproduct %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
