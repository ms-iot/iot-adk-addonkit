REM
REM This is a hook for createimage.cmd to perform bsp specific actions. 
REM Should be called only from createimage.cmd
REM

REM Assert that we are building QCDB410C based image
if [%PROD_BSP%] NEQ [QCDB410C] ( 
    echo %CLRRED% Error - Incorrect BSP %CLREND%
    exit /b 1
)

if exist %PRODSRC_DIR%\SMBIOS.cfg (
    call buildpkg.cmd %IOTADK_ROOT%\Templates\bsp\QCDB410C\Custom.SMBIOS.wm.xml
) else (
    echo. Using existing SMBIOS settings
)

exit /b 0
