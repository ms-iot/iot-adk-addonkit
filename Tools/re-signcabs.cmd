@echo off
goto START

:Usage
echo Usage: re-signcabs [SrcCabDir] [DstCabDir]
echo    SrcCabDir....... Required, Source directory for the cabs to be re-signed
echo    DstCabDir....... Required, Destination directory for the re-signed cabs
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        re-signcabs C:\Dir1 C:\Dir2

exit /b 1

:START
REM Input validation
setlocal ENABLEDELAYEDEXPANSION
if not defined HAL_ID ( set HAL_ID=.HalExt )

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
set OUTDIR=%2

if exist "%1" (
    dir /s /b "%1\*.cab" > "%1\cablist.txt" 2>nul
    call :PROCESSCAB %1\cablist.txt
) else (
    echo.%CLRRED%Error: %1 doesn't exist.%CLREND%
)

del %1\cablist.txt >nul 2>nul
endlocal

exit /b 0

:PROCESSCAB
if %~z1 gtr 0 (
    if not exist %OUTDIR% (
        mkdir %OUTDIR%
    )
	echo. Using %CLRYEL%%HAL_ID%%CLREND% to identify HAL packages
    for /f "delims=" %%i in (%1) do (
       echo. Re-signing %%~nxi
       mkdir %OUTDIR%\%%~ni
       echo.--------- pkgsigntool unpack----------- > %OUTDIR%\%%~ni_resign.log
       call pkgsigntool unpack %%i /out:%OUTDIR%\%%~ni >> %OUTDIR%\%%~ni_resign.log
       call :FIND_TEXT %%i %HAL_ID%
       if errorlevel 1 (
            echo.   %CLRYEL%Skipping HAL driver signing%CLREND%
            echo.--------- signbinaries skipped ----------- >> %OUTDIR%\%%~ni_resign.log
       ) else (
           echo.--------- signbinaries----------- >> %OUTDIR%\%%~ni_resign.log
           call signbinaries.cmd bsp %OUTDIR%\%%~ni >> %OUTDIR%\%%~ni_resign.log
       )
       echo.--------- makecat----------- >> %OUTDIR%\%%~ni_resign.log
       call makecat -v %OUTDIR%\%%~ni\content.cdf >> %OUTDIR%\%%~ni_resign.log
       echo.--------- signcat----------- >> %OUTDIR%\%%~ni_resign.log
       call sign.cmd %OUTDIR%\%%~ni\update.cat >> %OUTDIR%\%%~ni_resign.log
       echo.--------- pkgsigntool repack----------- >> %OUTDIR%\%%~ni_resign.log
       call pkgsigntool repack %OUTDIR%\%%~ni /out:%OUTDIR%\%%~nxi >> %OUTDIR%\%%~ni_resign.log
       echo.--------- signcab----------- >> %OUTDIR%\%%~ni_resign.log
       call sign.cmd %OUTDIR%\%%~nxi >> %OUTDIR%\%%~ni_resign.log
       rmdir %OUTDIR%\%%~ni /S /Q >nul
    )
) else (
    echo.%CLRRED%Error: No cab files found.%CLREND%
)
exit /b 0

:FIND_TEXT
set TESTLINE=%1
set TESTLINE=!TESTLINE:%2=!
if %1 NEQ !TESTLINE! ( exit /b 1)
exit /b 0
