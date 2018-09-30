@echo off

goto START

:Usage
echo Usage: convert 
echo    Generates the wm.xml file for the inf files and renames the existing pkg.xml to _pkg.xml
echo    [/?].................... Displays this usage string.
echo    Example:
echo        convert 
endlocal
exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION
if [%BSP_ARCH%] neq [x86] (
    echo.%CLRRED%Error: Supported only in x86.%CLREND%
    exit /b 1
)

set DST_DIR=%BSPSRC_DIR%\BSWx86
pushd
cd /D %DST_DIR%
del /s /q *.wm.xml >nul 2>nul
dir *.inf /b /s > %DST_DIR%\inflist.txt

for /f "delims=" %%i in (%DST_DIR%\inflist.txt) do (
    cd %%~pi
    for %%A in (.) do ( set FILENAME=%%~nxA)
    move !FILENAME!.pkg.xml !FILENAME!._pkg.xml >nul 2>nul
    echo Processing %%~nxi 
    call inf2pkg.cmd %%i !FILENAME! Intel
)

popd
del %DST_DIR%\inflist.txt

call convertpkg %DST_DIR%

del /s /q %DST_DIR%\*._pkg.xml >nul 2>nul

echo Fixing the BSPFM.xml file 
powershell -Command "(gc %DST_DIR%\Packages\BSWx86FM.XML) -replace 'Intel.BSW.OEM', '%%OEM_NAME%%.BSW.OEM' -replace 'Intel.BSW.Device', '%%OEM_NAME%%.BSW.Device' -replace 'FeatureIdentifierPackage=\"true\"', '' | Out-File %DST_DIR%\Packages\BSWx86FM.xml -Encoding utf8"
echo Fixing the TestOEMInput.xml file
powershell -Command "(gc %DST_DIR%\OEMInputSamples\TestOEMInput.xml) -replace '%%BSPSRC_DIR%%', '%%BLD_DIR%%' -replace 'BSWx86\\Packages','MergedFMs' | Out-File %DST_DIR%\OEMInputSamples\TestOEMInput.xml -Encoding utf8"
echo Fixing the RetailOEMInput.xml file
powershell -Command "(gc %DST_DIR%\OEMInputSamples\RetailOEMInput.xml) -replace '%%BSPSRC_DIR%%', '%%BLD_DIR%%' -replace 'BSWx86\\Packages','MergedFMs' | Out-File %DST_DIR%\OEMInputSamples\RetailOEMInput.xml -Encoding utf8"

endlocal

echo Conversions done
exit /b 0
