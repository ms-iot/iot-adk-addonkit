REM
REM This is a hook for newproduct.cmd to perform bsp specific actions. 
REM Should be called only from newproduct.cmd
REM

REM Assert that we are building QCDB410C based image
if [%BSPNAME%] NEQ [QCDB410C] ( 
    echo %CLRRED% Error - Incorrect BSP %CLREND%
    exit /b 1
)

echo. Provide SMBIOS fields
set SKU_NAME=%PRODUCT%SKU
set FAMILY_NAME=%OEM_NAME%Family
set BB_PRODNAME=QCDB410C
choice /T 10 /D N /M "Do you want to provide SMBIOS data? "
if errorlevel 2 (
    REM Do nothing
) else (
    set /p SKU_NAME=Enter System SKU:
    set /p FAMILY_NAME=Enter System Family:
    set /p BB_PRODNAME=Enter Baseboard Product:
)

echo. SMBIOS Fields set are
echo. System Manufacturer: %OEM_NAME%
echo. System Product Name: %PRODUCT%
echo. System SKU         : %SKU_NAME%
echo. System Family      : %FAMILY_NAME%
echo. Baseboard Product  : %BB_PRODNAME%

echo. You can edit these fields later by changing %PRODSRC_DIR%\SMBIOS.cfg. 
powershell -Command "(gc %BSPSRC_DIR%\%BSPNAME%\OEMInputSamples\SMBIOS.cfg) -replace '{Product}', '%PRODUCT%' -replace '{OEMNAME}', '%OEM_NAME%' -replace '{SKU}', '%SKU_NAME%' -replace '{Family}', '%FAMILY_NAME%' -replace '{BbProd}', '%BB_PRODNAME%' | Out-File %PRODSRC_DIR%\SMBIOS.cfg -Encoding utf8"

exit /b 0
