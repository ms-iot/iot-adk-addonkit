@echo off

goto START

:Usage
echo Usage: migrate 
echo    Migrates the iot-adk-addonkit to the latest version, 
echo    updating the dir structure and formating
echo    [/?]...................... Displays this usage string.

exit /b 1

:START

pushd
setlocal ENABLEDELAYEDEXPANSION

if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)
REM Input validation

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage

REM if pkg.xml exists, convert them 
call convertpkg.cmd all

REM fix the path for the ppkg files in existing appx packages
cd %PKGSRC_DIR%
dir /b /AD  >> %PPKGBLD_DIR%\pkglist.txt
for /f "delims=" %%i in (%PPKGBLD_DIR%\pkglist.txt) do (
    if exist "%PKGSRC_DIR%\%%i\customizations.xml" (
        echo. Fixing %%i
        cd %PKGSRC_DIR%\%%i
        powershell -Command "(gc %%i.wm.xml) -replace 'source=\"%%i.ppkg', 'source=\"$(BLDDIR)\ppkgs\%%i.ppkg' | Out-File %%i.wm.xml -Encoding utf8"
    )
)
del %PPKGBLD_DIR%\pkglist.txt

REM Moving CUSConfig dir to Product\Packages directory
cd %SRC_DIR%\Products
dir /b /AD >> %BLDDIR%\prodlist.txt
for /f "delims=" %%i in (%BLDDIR%\prodlist.txt) do (
    if exist %%i\CUSConfig (
        echo.Moving CUSConfig dir to Packages dir for %%i
        if not exist %%i\Packages ( mkdir %%i\Packages )
        move %%i\CUSConfig %%i\Packages\ >nul 2>nul
    )
)

endlocal
popd
exit /b
