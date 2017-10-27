@echo off
REM This script creates the folder structure and copies the template files for a new product

goto :START

:Usage
echo Usage: newupdate UpdateName Version
echo    UpdateName....... Required, Name of the Update to be created.
echo    Version.......... Version number (eg. x.y.z.a)
echo    [/?]............. Displays this usage string.
echo    Example:
echo        newupdate Update2 10.0.2.0

echo Existing Updates and versions are
type %SRC_DIR%\Updates\UpdateVersions.txt

exit /b 1

:START
setlocal
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if NOT DEFINED SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)
REM Error Checks

if /i EXIST %PKGUPD_DIR%\%1 (
    echo Error: %1 already exists
    goto End
)
REM Start processing command
echo Creating %1
SET UPDATE=%1
SET VERSION=%2

mkdir "%PKGUPD_DIR%\%UPDATE%"
if not exist %PKGUPD_DIR%\UpdateVersions.txt (
    echo UpdateName,Version,Notes > %PKGUPD_DIR%\UpdateVersions.txt
)
echo %UPDATE%,%VERSION%, >> %PKGUPD_DIR%\UpdateVersions.txt
echo %VERSION%> %PKGUPD_DIR%\%UPDATE%\versioninfo.txt

echo %1 directories ready
goto End

:Error
endlocal
echo "newupdate %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
