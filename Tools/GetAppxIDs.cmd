:: Run setenv before running this script
:: This script parses the appx files and generates the PFN and version info per appx
@echo off

goto START

:Usage
echo Usage: GetAppxIDs dir
echo    [/?].................... Displays this usage string.
echo    Example:
echo        GetAppxIDs %BLD_DIR%
endlocal
exit /b 1

:START

setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
set OUTPUTDIR=%1
if not exist "%OUTPUTDIR%" ( mkdir "%OUTPUTDIR%" )

dir %PKGSRC_DIR%\*.appx* /S /b > %OUTPUTDIR%\packagelist.txt
echo.@echo off > "%OUTPUTDIR%\setAppxIDs.cmd"
echo.REM Sets the PFN and version for all appx >> "%OUTPUTDIR%\setAppxIDs.cmd"
echo. >> "%OUTPUTDIR%\setAppxIDs.cmd"
for /f "delims=" %%i in (%OUTPUTDIR%\packagelist.txt) do (
    set APPX=%%~nxi
    set APPX_DIR=%%~dpi
    cd !APPX_DIR!
    for %%* in (.) do set COMPNAME=%%~nx*
    for /f "tokens=2 delims=." %%n in ("!COMPNAME!") do ( set APPNAME=%%n)
    REM echo. [!APPX_DIR!] [!APPX!]
    call %TOOLS_DIR%\GetAppxInfo.exe "%%i" > "%OUTPUTDIR%\appx_info.txt" 2>nul
    for /f "tokens=1,2,3 delims=:, " %%a in (%OUTPUTDIR%\appx_info.txt) do (
        if [%%a] == [Version] (
            set VER=%%b
        )
        if [%%a] == [PackageFullName] (
            set PFN=%%b
        )
        if [%%a] == [AppUserModelId] (
            echo.!APPNAME!
            echo.   VER=!VER!
            echo.   PFN=!PFN!
            echo.REM !APPNAME! Ids >> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo.set PFN_!APPNAME!=!PFN!>> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo.set VER_!APPNAME!=!VER!>> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo.echo.!APPNAME!>> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo.echo.  VER_!APPNAME!=%%VER_!APPNAME!%%>> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo.echo.  PFN_!APPNAME!=%%PFN_!APPNAME!%%>> "%OUTPUTDIR%\setAppxIDs.cmd"
            echo. >> "%OUTPUTDIR%\setAppxIDs.cmd"
        )
    )
    del %OUTPUTDIR%\appx_info.txt
)
del %OUTPUTDIR%\packagelist.txt
cd %TOOLS_DIR%
endlocal