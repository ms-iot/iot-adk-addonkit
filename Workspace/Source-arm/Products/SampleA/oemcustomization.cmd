@echo off
REM OEM Customization Script file
REM This script if included in the image, is called everytime the system boots.

reg query HKLM\Software\IoT /v FirstBootDone >nul 2>&1

if %errorlevel% == 1 (
    REM Enable Administrator User
    net user Administrator p@ssw0rd /active:yes
    if exist C:\Data\oobe (
        call folderpermissions.exe 'C:\Data\oobe -e'
    )
REM - Enable the below if you need secure boot/bitlocker
REM Enable Secureboot
REM if exist c:\IoTSec\setup.secureboot.cmd  (
REM    call c:\IoTSec\setup.secureboot.cmd
REM )

REM Enable Bitlocker
REM if exist c:\IoTSec\setup.bitlocker.cmd  (
REM    call c:\IoTSec\setup.bitlocker.cmd
REM )
    reg add HKLM\Software\IoT /v FirstBootDone /t REG_DWORD /d 1 /f >nul 2>&1
)

REM The below should be called on every boot
if exist C:\RecoveryConfig\Recovery.BcdEdit.cmd (
    call C:\RecoveryConfig\Recovery.BcdEdit.cmd
)

REM Set the crashdump file locations to data partition, set on every boot.
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v DedicatedDumpFile /t REG_SZ /d C:\Data\DedicatedDumpFile.sys /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl" /v DumpFile /t REG_SZ /d C:\Data\MEMORY.DMP /f
