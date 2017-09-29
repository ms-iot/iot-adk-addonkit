:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: newcommonpkg CompName.SubCompName
echo    CompName.SubCompName....... Required, Component Name.SubComponent Name for the package
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newcommonpkg Registry.ConfigSettings
echo Existing packages are
dir /b /AD %COMMON_DIR%\Packages

exit /b 1

:START
setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

for /f "tokens=1,2 delims=." %%i in ("%1") do (
    set COMP_NAME=%%i
    set SUB_NAME=%%j
)

if NOT DEFINED COMMON_DIR (
    echo Environment not defined. Call setenv
    goto End
)
if defined USEUPDATE (
    set NEWPKG_DIR=%SRC_DIR%\Updates\%USEUPDATE%\%1
) else (
    set NEWPKG_DIR=%COMMON_DIR%\Packages\%1
)

:: Error Checks
if /i EXIST %NEWPKG_DIR% (
    echo Error : %1 already exists
    echo.
    echo Existing packages are
    dir /b /AD %COMMON_DIR%\Packages
    goto End
)

:: Start processing command
echo Creating %1 package

mkdir "%NEWPKG_DIR%"

:: Create File/Registry package using template files
powershell -Command "(gc %IOTADK_ROOT%\Templates\FileTemplate.wm.xml) -replace 'COMPNAME', '%COMP_NAME%' -replace 'SUBNAME', '%SUB_NAME%' -replace 'PLFNAME', 'Common' | Out-File %NEWPKG_DIR%\%1.wm.xml -Encoding utf8"


echo %NEWPKG_DIR% ready
goto End

:Error
endlocal
echo "newcommonpkg %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
