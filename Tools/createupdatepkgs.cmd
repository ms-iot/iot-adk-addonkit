@echo off

goto :START

:Usage
echo Usage: createupdatepkgs updatename
echo    updatename....... Name of the update directory under Updates
echo    [/?]........Displays this usage string.
echo    Example:
echo        createupdatepkgs Update1

exit /b 1

:START

setlocal
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
set UPDATE=%1
if NOT exist "%PKGUPD_DIR%\%UPDATE%" (
    echo %1 does not exist. Available updates are
    dir /B /AD %PKGUPD_DIR%
    echo.
    goto END
)

if exist "%PKGUPD_DIR%\%UPDATE%\versioninfo.txt" (
    SET /P PKG_VER=< %PKGUPD_DIR%\%UPDATE%\versioninfo.txt
) else (
    echo Error :%PKGUPD_DIR%\%UPDATE%\versioninfo.txt not found.
    echo        Please specify version in versioninfo.txt
    goto End
)
SET PKGBLD_DIR=%BLD_DIR%\%UPDATE%-%PKG_VER%
echo Creating Update packages for %UPDATE% using version : %PKG_VER%

call buildpkg.cmd %PKGUPD_DIR%\%UPDATE% %PKG_VER%

:END
endlocal
exit /b 0
