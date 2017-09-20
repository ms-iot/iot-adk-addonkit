REM startnet.cmd

REM Launch UI to cover screen
REM start recoverygui.exe

echo IoT recovery initializing...
wpeinit

REM Assign drive letters
call diskpart /s diskpart_assign.txt
set MAINOSDRIVE=C
set RECOVERYDRIVE=R
set EFIDRIVE=E

REM Ensure recovery WIM files are available
if not exist %RECOVERYDRIVE%:\data.wim goto :exit
if not exist %RECOVERYDRIVE%:\mainos.wim goto :exit
if not exist %RECOVERYDRIVE%:\efiesp.wim goto :exit

REM Perform recovery operations, logging to MainOS log file
set RECOVERY_LOG_FOLDER=%MAINOSDRIVE%:\recoverylogs
md %RECOVERY_LOG_FOLDER%
call startnet_recovery.cmd >%RECOVERY_LOG_FOLDER%\recovery_log.txt
copy %WINDIR%\system32\winpeshl.log %RECOVERY_LOG_FOLDER%

:exit

REM Go back to MainOS on next boot
bcdedit /store %EFIDRIVE%:\EFI\microsoft\boot\bcd /set {bootmgr} bootsequence {01de5a27-8705-40db-bad6-96fa5187d4a6}

REM Remove extra drive letters
call diskpart /s diskpart_remove.txt

REM Restart system
wpeutil reboot
