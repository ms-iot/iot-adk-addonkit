@echo off

goto START

:Usage
echo Usage: buildrecovery [Product] [BuildType]
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildrecovery SampleA Test
echo        buildrecovery SampleA Retail

exit /b 1

:START
setlocal
if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)

if not defined FFUNAME ( set FFUNAME=Flash)
set OUTPUTDIR=%BLD_DIR%\%1\%2
set IMG_FILE=%BLD_DIR%\%1\%2\%FFUNAME%.ffu
if not exist "%IMG_FILE%" (
    echo Building the base FFU
    call buildimage %1 %2
)
echo Extracting Wims
call extractwim.cmd %1 %2

copy %COMMON_DIR%\Packages\Recovery.Wimfiles\*.xml %OUTPUTDIR%\ >nul
echo Building Recovery package
call buildpkg %OUTPUTDIR%

set FFUNAME=%FFUNAME%Recovery
echo Building the RecoveryFFU
call buildimage %1 %2

endlocal
exit /b

:Error
endlocal
exit /b 1
