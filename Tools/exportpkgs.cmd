@echo off

goto START

:Usage
echo Usage: exportpkgs [DestDir] [Product] [BuildType] [OwnerType]
echo    DestDir........... Required, Destination directory to export
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    OwnerType......... Optional, MS/OEM/ALL , default ALL

echo    [/?]...................... Displays this usage string.
echo    Example:
echo        exportpkgs C:\Temp SampleA Test OEM
echo        exportpkgs C:\Temp SampleA Retail ALL
echo Run this command only after a successful ffu creation. (See buildimage.cmd)

exit /b 1

:START
if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not exist "%BLD_DIR%\%2\%3" ( goto Usage )
if not defined FFUNAME ( set FFUNAME=Flash)
if not exist "%BLD_DIR%\%2\%3\%FFUNAME%.FFU" (
    echo. %CLRRED% %BLD_DIR%\%2\%3\%FFUNAME%.FFU not found. Build the image before exporting.%CLREND%
    exit /b 1
)

if not exist "%BLD_DIR%\%2\%3\%FFUNAME%.UpdateInput.xml" (
    echo. %FFUNAME%.UpdateInput.xml not found. Build the image before exporting.
    exit /b 1
)
if not exist "%1" ( mkdir "%1" )
setlocal

if /I [%4] == [MS] (
    set MSPKG=1
) else if /I [%4] == [OEM] (
    set OEMPKG=1
) else (
    set MSPKG=1
    set OEMPKG=1
)
if exist ("%1\packagelist.txt") del "%1\packagelist.txt"

for /f "tokens=1,2,3 delims=<,> skip=5" %%A in (%BLD_DIR%\%2\%3\%FFUNAME%.UpdateInput.xml) do (
    if [%%C] == [] (
        REM echo. Nothing to do.
    ) else (
        REM echo. Found : %%C
        echo.%%C | findstr /C:"MSPackages" >nul && (
            if defined MSPKG (
                echo. [MS package] : %%C
                copy "%%C" "%1%" >nul
                echo.%%C >> "%1\packagelist.txt"
            )
        ) || (
            if defined OEMPKG (
                echo. [OEM package] : %%C
                copy "%%C" "%1%" >nul
                echo.%%C >> "%1\packagelist.txt"
            )
        )
    )
)
copy "%IOTADK_ROOT%\Templates\installupdates.cmd" %1\installupdates.cmd >nul
echo. Exporting BSP DB
copy "%BLD_DIR%\%2\%3\%FFUNAME%.BSPDB.xml" %1 >nul
endlocal
exit /b

