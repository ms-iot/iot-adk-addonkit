@echo off

goto START

:Usage
echo Usage: exportpkgs [DestDir] [Product] [BuildType] [OwnerType]
echo    DestDir........... Required, Destination directory to export
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    OwnerType......... Optional, MS/OEM/ALL , default OEM

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
set WORK_DIR=%1\%BSP_VERSION%

if not exist "%BLD_DIR%\%2\%3" ( goto Usage )
if not defined FFUNAME ( set FFUNAME=Flash)
set OCPCAB=%2_OCP
set OUTPUT=%WORK_DIR%\%OCPCAB%
if not exist "%BLD_DIR%\%2\%3\%FFUNAME%.FFU" (
    echo. %CLRRED% %BLD_DIR%\%2\%3\%FFUNAME%.FFU not found. Build the image before exporting.%CLREND%
    exit /b 1
)

if not exist "%BLD_DIR%\%2\%3\%FFUNAME%.UpdateInput.xml" (
    echo. %FFUNAME%.UpdateInput.xml not found. Build the image before exporting.
    exit /b 1
)
if not exist "%OUTPUT%" ( mkdir "%OUTPUT%" )
setlocal

if /I [%4] == [MS] (
    set MSPKG=1
) else if /I [%4] == [ALL] (
    set MSPKG=1
    set OEMPKG=1
) else (
    set OEMPKG=1
)
REM if exist ("%WORK_DIR%\%OCPCAB%_pkglist.txt") del "%WORK_DIR%\%OCPCAB%_pkglist.txt"

for /f "tokens=1,2,3 delims=<,> skip=5" %%A in (%BLD_DIR%\%2\%3\%FFUNAME%.UpdateInput.xml) do (
    if [%%C] == [] (
        REM echo. Nothing to do.
    ) else (
        REM echo. Found : %%C
        echo.%%C | findstr /C:"MSPackages" >nul && (
            if defined MSPKG (
                echo. [MS package] : %%C
                copy "%%C" "%OUTPUT%" >nul
REM             echo.%%C >> "%WORK_DIR%\%OCPCAB%_pkglist.txt"
            )
        ) || (
            if defined OEMPKG (
                echo. [OEM package] : %%C
                copy "%%C" "%OUTPUT%" >nul
REM             echo.%%C >> "%WORK_DIR%\%OCPCAB%_pkglist.txt"
            )
        )
    )
)

echo. Exporting BSP DB
copy "%BLD_DIR%\%2\%3\%FFUNAME%.BSPDB.xml" %OUTPUT% >nul

findstr /C:"OwnerType" %OUTPUT%\%FFUNAME%.BSPDB.xml > %WORK_DIR%\pkgbspdb.txt
if exist %WORK_DIR%\%OCPCAB%_pkgver.txt (del %WORK_DIR%\%OCPCAB%_pkgver.txt)
for /f "tokens=3,8,9,10,11,13 delims=>= " %%A in (%WORK_DIR%\pkgbspdb.txt) do (
    if /I [%%B] == [Version] (
        echo %%~A.cab,%%~C >> %WORK_DIR%\%OCPCAB%_pkgver.txt
    ) else if /I [%%D] == [Version] (
        echo %%~A.cab,%%~E >> %WORK_DIR%\%OCPCAB%_pkgver.txt
    ) else (
          echo %%~A.cab,%%~F >> %WORK_DIR%\%OCPCAB%_pkgver.txt
    )
)
del %WORK_DIR%\pkgbspdb.txt

echo. Making BSP DB cab
call makecab %OUTPUT%\%FFUNAME%.BSPDB.xml %OUTPUT%\%FFUNAME%.BSPDB.xml.cab >nul
echo. Signing BSP DB cab
call sign.cmd %OUTPUT%\%FFUNAME%.BSPDB.xml.cab >nul
del %OUTPUT%\%FFUNAME%.BSPDB.xml
cd /D %WORK_DIR%
echo. Making %OCPCAB%.cab
dir /s /b /a-d %OCPCAB% > files.txt
makecab /d "CabinetName1=%OCPCAB%.cab" /d DiskDirectoryTemplate=. /d InfFileName=NUL /d RptFileName=NUL /d MaxDiskSize=0 /f files.txt
del /q /f files.txt
echo. Signing %OCPCAB%.cab
call sign.cmd %OCPCAB%.cab >nul
endlocal
exit /b

