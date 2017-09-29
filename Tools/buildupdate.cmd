@echo off

goto :START

:Usage
echo Usage: buildupdate [updatename]/[All]/[Clean]
echo    updatename....... Name of the update directory under Updates
echo    All.............. All packages under \Updates directory are built
echo    Clean............ Cleans the Update output directory
echo        One of the above should be specified
echo    [/?]........Displays this usage string.
echo    Example:
echo        buildupdate Update-10.0.1.0
ech0 Available updates are
dir /B /AD %PKGUPD_DIR%
exit /b 1

:START

setlocal
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I [%1] == [All] (
    dir /B /AD %PKGUPD_DIR% > %BLD_DIR%\updates.txt
    for /f "delims=" %%i in (%BLD_DIR%\updates.txt) do (
        echo. Processing %%~nxi
        call createupdatepkgs.cmd %%i 
    )
) else if /I [%1] == [Clean] (
    del /S /Q %PKGUPD_DIR%\*.ppkg %PKGUPD_DIR%\*.cat >nul 2>nul
    rmdir "%BLD_DIR%\Update*" /S /Q >nul
    echo Build directories cleaned
) else (
    if exist %PKGUPD_DIR%\%1 (
        call createupdatepkgs.cmd %1
    ) else (
        echo %1 not found. 
        goto Usage
    )
)

:END
endlocal
exit /b 0
