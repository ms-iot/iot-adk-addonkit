@echo off

REM Run this on every boot
bcdedit /set bootstatuspolicy IgnoreShutdownFailures
bcdedit /set recoveryenabled yes
bcdedit /set recoverysequence {a5935ff2-32ba-4617-bf36-5ac314b3f9bf}

if not exist C:\Data\Wimfiles\winpe_update.wim (
    REM Nothing to do. Exit this cmd file.
    exit /b 0
)
REM WinPE update file found. Mount MMOS partition and process copying.
setlocal ENABLEDELAYEDEXPANSION
REM Check if MMOS exists already ( will be mounted if its a NTFS partition)
if exist C:\MMOS ( goto :MMOSFound )

mountvol > C:\Data\Wimfiles\mountpoints.txt
set FOUND=0
for /f "tokens=1,* delims=? " %%i in (C:\Data\Wimfiles\mountpoints.txt) do (
    if [%%i] == [\\] (
        set VOL_GUID=%%i?%%j
        set FOUND=1
    ) else (
        if [!FOUND!] == [1] (
            set !FOUND!=0
            if [%%i] == [***] (
                echo.Mounting: !VOL_GUID!
                mklink /J C:\MMOS !VOL_GUID!
                if exist C:\MMOS\winpe.wim (
                    echo. Mounted C:\MMOS
                    goto :MMOSFound
                ) else (
                    echo.Unmounting !VOL_GUID!
                    rmdir C:\MMOS
                )
            )
        )
    )
)
echo. Error: MMOS partition not found.
endlocal
exit /b 1

:MMOSFound
dir C:\MMOS

copy C:\Data\Wimfiles\winpe_update.wim C:\MMOS\winpe_update.wim
REM make sure the copy is successful
if exist C:\MMOS\winpe_update.wim (
    move C:\MMOS\winpe.wim C:\MMOS\winpe_bak.wim
    move C:\MMOS\winpe_update.wim C:\MMOS\winpe.wim
    del C:\Data\Wimfiles\winpe_update.wim
    if exist C:\MMOS\winpe.wim (
        del C:\MMOS\winpe_bak.wim
    )
)
if defined VOL_GUID (
    REM delete the MMOS link only if it was mounted by the script
    echo. Unmounting MMOS
    rmdir C:\MMOS
    del C:\Data\Wimfiles\mountpoints.txt
)
endlocal
exit /b 0
