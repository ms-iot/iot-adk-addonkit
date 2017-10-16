@echo off

goto START

:Usage
echo Usage: partitioninfo [BSP] [SOCID]
echo    BSP........ Required, BSP Name
echo    SOCID       Optional, SOC ID for the GPT device layout in the BSPFM.xml file
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

REM Some Constants https://msdn.microsoft.com/en-us/library/windows/desktop/aa365449(v=vs.85).aspx
set GUID_GPT_BASIC_DATA=ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
set GUID_GPT_SYSTEM=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
set GUID_GPT_LDM_METADATA=5808c8aa-7e8f-42e0-85d2-e1e90434cfb3
set GUID_GPT_MSFT_RECOVERY=de94bba4-06d1-4d40-a16a-bfd50179d6ac

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
set WINPEDIR=%BLD_DIR%\%BSP%
set WINPEFILES=%WINPEDIR%\recovery
if not exist %WINPEFILES% ( mkdir %WINPEFILES% )

echo. Parsing device layout file :%DLCOMP_DIR%
powershell -executionpolicy unrestricted  -Command ("%TOOLS_DIR%\GetPartitionInfo.ps1 %DLCOMP_DIR%") > %WINPEFILES%\devicelayout.csv
set MOUNT_LIST=%WINPEDIR%\mountlist.txt
set PC_MOUNTLIST=%WINPEDIR%\pc_mountlist.txt
set SETDRIVECMD=%WINPEFILES%\setdrives.cmd
set PCSETDRIVECMD=%WINPEDIR%\pc_setdrives.cmd
if exist %SETDRIVECMD% ( del %SETDRIVECMD% >nul )
if exist %PCSETDRIVECMD% ( del %PCSETDRIVECMD% >nul )

if exist %MOUNT_LIST% ( del %MOUNT_LIST% >nul )
if exist %PC_MOUNTLIST% ( del %PC_MOUNTLIST% >nul )

for /f "skip=1 tokens=1,2,3,4,5,6 delims=,{} " %%i in (%WINPEFILES%\devicelayout.csv) do (
    REM echo PARID_%%i=%%j [%%k] [%%l] [%%m] [%%n]
    set PARID_%%i=%%j
    set TYPE_%%i=%%k
    set SIZE_%%i=%%l
    set FS_%%i=%%m
    if [%%n] NEQ [-] if /I [%%i] neq [MainOS] (
        echo.%%i,%%n >> %MOUNT_LIST% 
        echo.echo Setting %%i Drive: DL_%%i=%%n >> %SETDRIVECMD%
        echo.set DL_%%i=%%n>> %SETDRIVECMD%
    )
    if [%%n] NEQ [-] (
        echo. Setting %%i Drive: DL_%%i=%%n 
        echo.%%i,%%n >> %PC_MOUNTLIST%
        echo.echo Setting %%i Drive: DL_%%i=%%n >> %PCSETDRIVECMD%
        echo.set DL_%%i=%%n>> %PCSETDRIVECMD%
    )
)

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
if [%TYPE_EFIESP%] NEQ [%GUID_GPT_SYSTEM%] (
    echo. %CLRYEL%Warning: EFIESP partition should be set to GPT_SYSTEM_GUID %GUID_GPT_SYSTEM% for Bitlocker to work%CLREND%
)

echo. EFIESP:%PARID_EFIESP% MainOS:%PARID_MainOS% MMOS:%PARID_MMOS% Data:%PARID_Data%


REM Output diskpart_assign.txt
echo. Generationg diskpart_assign.txt
set OUTFILE=%WINPEFILES%\diskpart_assign.txt
if exist %OUTFILE% (del %OUTFILE%)
call :GENDISKPART 0 %MOUNT_LIST% assign
set OUTFILE=%WINPEDIR%\pc_diskpart_assign.txt
if exist %OUTFILE% (del %OUTFILE%)
call :GENDISKPART DISKNR %PC_MOUNTLIST% assign

REM Output diskpart_remove.txt
echo. Generationg diskpart_remove.txt
set OUTFILE=%WINPEFILES%\diskpart_remove.txt
if exist %OUTFILE% (del %OUTFILE%)
call :GENDISKPART 0 %MOUNT_LIST% remove
set OUTFILE=%WINPEDIR%\pc_diskpart_remove.txt
if exist %OUTFILE% (del %OUTFILE%)
call :GENDISKPART DISKNR %PC_MOUNTLIST% remove

REM Output restore_junction.cmd only if mount_list is available
set OUTFILE=%WINPEFILES%\restore_junction.cmd
if exist %OUTFILE% (del %OUTFILE%)


echo. Generationg restore_junction.cmd
call :PRINT_TEXT "REM Script to restore junctions"
for /f "tokens=1,2 delims=, " %%i in (%MOUNT_LIST%) do (
    if [!TYPE_%%i!] == [%GUID_GPT_BASIC_DATA%] (
        REM echo. Processing %%i
        call :PRINT_TEXT "REM restoring %%i junction"
        call :PRINT_TEXT "mountvol %%j:\ /L > volumeguid_%%i.txt"
        call :PRINT_TEXT "set /p VOLUMEGUID_%%i=<volumeguid_%%i.txt"
        call :PRINT_TEXT "rmdir C:\%%i"
        echo.mklink /J C:\%%i %%VOLUMEGUID_%%i%% >> "%OUTFILE%"
        echo.>> "%OUTFILE%"
    ) else (
        echo.    skipping %%i - Non Data GUID
    )
)
call :PRINT_TEXT "exit /b 0"

del %MOUNT_LIST% >nul
del %PC_MOUNTLIST% >nul

endlocal
exit /b 0

:GENDISKPART
REM %1 - DiskNr
REM %2 - Mountlist
REM %3 - assign/remove
call :PRINT_TEXT "sel dis %1"
call :PRINT_TEXT "lis vol"
echo.>> "%OUTFILE%"
for /f "tokens=1,2 delims=, " %%i in (%2) do (
    if [!PARID_%%i!] == [] (
        echo.%CLRRED%Error: %%i is not a valid partition.%CLREND%
        exit /b 1
    )
    call :PRINT_TEXT "sel par !PARID_%%i!"
    if /I [%3] == [assign] ( 
        if [!TYPE_%%i!] NEQ [%GUID_GPT_SYSTEM%] if [!TYPE_%%i!] NEQ [%GUID_GPT_BASIC_DATA%] (
            call :PRINT_TEXT "set id=%GUID_GPT_BASIC_DATA%"
        )
    )
    call :PRINT_TEXT "%3 letter=%%j noerr"
    if /I [%3] == [remove] (
        if [!TYPE_%%i!] NEQ [%GUID_GPT_SYSTEM%] if [!TYPE_%%i!] NEQ [%GUID_GPT_BASIC_DATA%] (
            call :PRINT_TEXT "set id=!TYPE_%%i!"
        )
    )
    echo.>> "%OUTFILE%"
)
call :PRINT_TEXT "lis vol"
call :PRINT_TEXT "exit"
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT!>> "%OUTFILE%"
REM echo.>> "%OUTFILE%"
REM echo !TEXT!
exit /b
