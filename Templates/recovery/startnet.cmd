@echo off
echo IoT recovery initializing...
wpeinit

REM Format partitions and assign drive letters
call diskpart /s diskpart_assign.txt

REM Define drive letters (assigned by diskpart script)
set MAINOSDRIVE=C
set EFIDRIVE=E
set RECOVERYDRIVE=R
set DATADRIVE=D
set DPPDRIVE=P

REM Apply EFIESP partition WIM files
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\efiesp.wim /index:1 /ApplyDir:%EFIDRIVE%:\
REM Apply the MainOS and Data partition WIM files. The order below is important - do not change
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\data.wim /index:1 /ApplyDir:%DATADRIVE%:\ /Compact
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\mainos.wim /index:1 /ApplyDir:%MAINOSDRIVE%:\ /Compact

REM Restore Junctions for Data/DPP/MMOS partitions
REM Only necessary when recovery WIMs not generated from same FFU
mountvol %DATADRIVE%:\ /L > volumeguid_data
set /p VOLUMEGUIDDATA=<volumeguid_data
rmdir %MAINOSDRIVE%:\Data
mklink /J %MAINOSDRIVE%:\Data %VOLUMEGUIDDATA%

mountvol %DPPDRIVE%:\ /L > volumeguid_dpp
set /p VOLUMEGUIDDPP=<volumeguid_dpp
rmdir %MAINOSDRIVE%:\DPP
mklink /J %MAINOSDRIVE%:\DPP %VOLUMEGUIDDPP%

mountvol %RECOVERYDRIVE%:\ /L > volumeguid_recovery
set /p VOLUMEGUIDRECOVERY=<volumeguid_recovery
rmdir %MAINOSDRIVE%:\MMOS
mklink /J %MAINOSDRIVE%:\MMOS %VOLUMEGUIDRECOVERY%

REM Fix up MountedDevices registry to point to correct Data partition GUID
set VOL=%VOLUMEGUIDDATA%
set VOL=%VOL: =%
set UDRIVEBINARYBLOB=444D494F3A49443A%vol:~17,2%%vol:~15,2%%vol:~13,2%%vol:~11,2%%vol:~22,2%%vol:~20,2%%vol:~27,2%%vol:~25,2%%vol:~30,4%%vol:~35,12%
reg load "HKLM\RecoveryIoTSystem" %MAINOSDRIVE%:\windows\system32\config\system
reg add "HKLM\RecoveryIoTSystem\MountedDevices" /v "\DosDevices\U:" /t REG_BINARY /f /d %UDRIVEBINARYBLOB%
reg unload "HKLM\RecoveryIoTSystem"

REM Go back to MainOS on next boot
bcdedit /store %EFIDRIVE%:\EFI\microsoft\boot\bcd /set {bootmgr} bootsequence {01de5a27-8705-40db-bad6-96fa5187d4a6}

REM Remove extra drive letters
call diskpart /s diskpart_remove.txt

REM Restart system
wpeutil reboot
