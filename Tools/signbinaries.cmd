@echo off

goto :START

:Usage
echo Usage: signbinaries [bsp/all/ext] [dir]
echo    bsp  .................. Signs all sys/dll files
echo    all  .................. Signs all dll/sys/ppkg files
echo    ext  .................. Signs all .ext files (say cab / dll / sys / ppkg )
echo    dir  .................. Directory where the files are present
echo    [/?] .................. Displays this usage string.
echo    Example:
echo        signbinaries bsp %BSPSRC_DIR%
echo        signbinaries all %BSPSRC_DIR%

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
if not exist "%2" goto Usage

if /I [%SIGNFILES%] == [NONE] (
    echo. %CLRYEL%SIGNFILES set to NONE. Signing skipped.%CLREND%
    exit /b 0
)

if /i [%1] == [all] (
    set SIGNFILES=dll sys ppkg
) else if /i [%1] == [bsp] (
    set SIGNFILES=sys dll
) else (
    set SIGNFILES=%1
)
if exist "%PKGLOG_DIR%\signbinaries.log" (del "%PKGLOG_DIR%\signbinaries.log")

echo.Processing %2
for %%A in (%SIGNFILES%) do (
    echo. [%%A files]
    dir /s /b %2\*.%%A > %PKGLOG_DIR%\filelist.txt 2>nul

    for %%Q in (%PKGLOG_DIR%\filelist.txt) do if %%~zQ gtr 0 (
        for /f "delims=" %%i in (%PKGLOG_DIR%\filelist.txt) do (
            echo.   Signing %%i
            call sign.cmd %%i >> %PKGLOG_DIR%\signbinaries.log
        )
    ) else (
        echo.   %CLRYEL%No %%A files.%CLREND%
    )
)
endlocal
exit /b 0
