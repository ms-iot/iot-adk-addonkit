REM startnet_recovery.cmd

REM Format MainOS and Data partitions

REM Define drive letters (assigned by diskpart script)
set MAINOSDRIVE=C
set EFIDRIVE=E
set RECOVERYDRIVE=R
set DATADRIVE=D
set DPPDRIVE=P

REM Apply EFIESP partition WIM file
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\efiesp.wim /index:1 /ApplyDir:%EFIDRIVE%:\
REM This will reset BCD to defaults, so immediately reset recovery parameter in case of power loss
bcdedit /store %EFIDRIVE%:\EFI\microsoft\boot\bcd /set {bootmgr} bootsequence {a5935ff2-32ba-4617-bf36-5ac314b3f9bf}

REM Apply the MainOS and Data partition WIM files. The order below is important - do not change
format /q /y /v:Data /fs:ntfs %DATADRIVE%:
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\data.wim /index:1 /ApplyDir:%DATADRIVE%:\ /Compact
format /q /y /v:MainOS /fs:ntfs %MAINOSDRIVE%:
dism /apply-image /ImageFile:%RECOVERYDRIVE%:\mainos.wim /index:1 /ApplyDir:%MAINOSDRIVE%:\ /Compact

REM Restore Junctions for Data/DPP/MMOS partitions
REM Only necessary when recovery WIMs not generated from same FFU
if exist restore_junction.cmd (
    call restore_junction.cmd
) else (
    mountvol %DATADRIVE%:\ /L > volumeguid_data
    set /p VOLUMEGUID_Data=<volumeguid_data
    rmdir %MAINOSDRIVE%:\Data
    mklink /J %MAINOSDRIVE%:\Data %VOLUMEGUID_Data%

    mountvol %DPPDRIVE%:\ /L > volumeguid_dpp
    set /p VOLUMEGUIDDPP=<volumeguid_dpp
    rmdir %MAINOSDRIVE%:\DPP
    mklink /J %MAINOSDRIVE%:\DPP %VOLUMEGUIDDPP%

    mountvol %RECOVERYDRIVE%:\ /L > volumeguid_recovery
    set /p VOLUMEGUIDRECOVERY=<volumeguid_recovery
    rmdir %MAINOSDRIVE%:\MMOS
    mklink /J %MAINOSDRIVE%:\MMOS %VOLUMEGUIDRECOVERY%
)
REM Fix up MountedDevices registry to point to correct Data partition GUID
set VOL=%VOLUMEGUID_Data%
set VOL=%VOL: =%
set UDRIVEBINARYBLOB=444D494F3A49443A%vol:~17,2%%vol:~15,2%%vol:~13,2%%vol:~11,2%%vol:~22,2%%vol:~20,2%%vol:~27,2%%vol:~25,2%%vol:~30,4%%vol:~35,12%
reg load "HKLM\RecoveryIoTSystem" %MAINOSDRIVE%:\windows\system32\config\system
reg add "HKLM\RecoveryIoTSystem\MountedDevices" /v "\DosDevices\U:" /t REG_BINARY /f /d %UDRIVEBINARYBLOB%
reg unload "HKLM\RecoveryIoTSystem"
