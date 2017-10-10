@echo off

goto START

:Usage
echo Usage: partitioninfo [BSP] [SOCID] 
echo    BSP........ Required, BSP Name
echo    SOCID       Optional, SOC ID for the device layout in the BSPFM.xml file
echo    [/?]....... Displays this usage string.
echo    Example:
echo        partitioninfo QCDB410C QCDB410C_R
echo        partitioninfo QCDB410C

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not exist "%BSPSRC_DIR%\%1" (
    echo %1 is not a valid BSP.
    goto Usage
)

set BSP=%1
set SOCNAME=%2

if [%SOCNAME%] == [] (
    for /f "tokens=3,8,9 delims==. " %%i in ('findstr /L /I "SOC=" %BSPSRC_DIR%\%BSP%\Packages\%BSP%FM.xml') do if not defined DLCOMP (
        choice /T 10 /D Y /M "Use %%j.%%k (SOC = %%~i) "
        if errorlevel 2 (
            REM Do Nothing
        ) else (
            set SOCNAME=%%~i
            set DLCOMP=%%j.%%k
        )
    )
) else (
    for /f "tokens=2,3 delims=." %%i in ('findstr /L /I "SOC=\"%SOCNAME%\"" %BSPSRC_DIR%\%BSP%\Packages\%BSP%FM.xml') do (
        REM echo. DeviceLayout : %%i.%%j
        set DLCOMP=%%i.%%j
    )
    if not defined DLCOMP (
        echo. %CLRRED%Error : %SOCNAME% not defined in %BSP%FM.xml.%CLREND% 
        exit /b 1
    )
)

if not defined DLCOMP (
    echo. %CLRRED%Error : No device layout selected.%CLREND% 
    exit /b 1
)

for /f "tokens=*" %%i in ('dir /s /b %IOTADK_ROOT%\%DLCOMP%') do (
    REM echo. DeviceLayout Path : %%i
    set DLCOMP_DIR=%%i\DeviceLayout.xml
)

if not defined DLCOMP_DIR ( 
    echo. %CLRRED%Error : %DLCOMP% directory not found.%CLREND% 
    exit /b 1
)

if not exist %BLD_DIR%\%BSP%\%SOCNAME% ( mkdir %BLD_DIR%\%BSP%\%SOCNAME% )

echo. DeviceLayout File :%DLCOMP_DIR%
powershell -Command ("%TOOLS_DIR%\GetPartitionInfo.ps1 %DLCOMP_DIR%") > %BLD_DIR%\%BSP%\%SOCNAME%\partitioninfo.csv

for /f "tokens=1,2,3,4,5 delims=, " %%i in (%BLD_DIR%\%BSP%\%SOCNAME%\partitioninfo.csv) do (
    REM echo PARID_%%i=%%j
    set PARID_%%i=%%j
    set TYPE_%%i=%%k
    set SIZE_%%i=%%l
    set FS_%%i=%%m
)
REM del %BLD_DIR%\%BSP%\%SOCNAME%\partitioninfo.csv >nul 2>nul

REM validate device layout
echo. Validating device layout... 
REM check if MMOS is defined
if not defined PARID_MMOS ( 
    echo. %CLRRED%Error: Recovery partition MMOS is not defined%CLREND% 
    exit /b 1
)
REM check MMOS file system is not NTFS
if [%FS_MMOS%] == [NTFS] (
    echo. %CLRYEL%Warning: Recovery partition is NTFS. Change to FAT32 if you are using Bitlocker%CLREND%
)
REM Check if EFIESP partition type is proper
if not defined PARID_EFIESP (
    echo. %CLRRED%Error: EFIESP partition is not defined%CLREND% 
    exit /b 1
)
if [%TYPE_EFIESP%] NEQ [{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}] (
    echo. %CLRYEL%Warning: EFIESP partition should be set to {c12a7328-f81f-11d2-ba4b-00a0c93ec93b} for Bitlocker to work%CLREND%
) 

echo. EFIESP:%PARID_EFIESP% MainOS:%PARID_MainOS% MMOS:%PARID_MMOS% Data:%PARID_Data% PLAT:%PARID_PLAT% DPP:%PARID_DPP%

REM Output diskpart_assign.txt
set OUTFILE=%BLD_DIR%\%BSP%\%SOCNAME%\diskpart_assign.txt
if exist %OUTFILE% (del %OUTFILE%)

call :PRINT_TEXT "sel dis 0"
call :PRINT_TEXT "lis vol"
call :PRINT_TEXT "sel par %PARID_DPP%"
call :PRINT_TEXT "assign letter=P noerr"
call :PRINT_TEXT "sel par %PARID_MMOS%"
call :PRINT_TEXT "assign letter=R noerr"
call :PRINT_TEXT "sel par %PARID_Data%"
call :PRINT_TEXT "assign letter=D noerr"
call :PRINT_TEXT "sel par %PARID_EFIESP%"
call :PRINT_TEXT "assign letter=E noerr"
call :PRINT_TEXT "lis vol"
call :PRINT_TEXT "exit"

set OUTFILE=%BLD_DIR%\%BSP%\%SOCNAME%\diskpart_remove.txt
if exist %OUTFILE% (del %OUTFILE%)

call :PRINT_TEXT "sel dis 0"
call :PRINT_TEXT "lis vol"
call :PRINT_TEXT "sel par %PARID_DPP%"
call :PRINT_TEXT "remove letter=P noerr"
call :PRINT_TEXT "sel par %PARID_MMOS%"
call :PRINT_TEXT "remove letter=R noerr"
call :PRINT_TEXT "sel par %PARID_Data%"
call :PRINT_TEXT "remove letter=D noerr"
call :PRINT_TEXT "sel par %PARID_EFIESP%"
call :PRINT_TEXT "remove letter=E noerr"
call :PRINT_TEXT "lis vol"
call :PRINT_TEXT "exit"
endlocal
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT!>> "%OUTFILE%"
REM echo.>> "%OUTFILE%"
REM echo !TEXT!
exit /b
