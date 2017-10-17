REM startnet.cmd

REM Launch UI to cover screen
if exist recoverygui.exe ( start recoverygui.exe )

echo IoT recovery initializing...

call setdrives.cmd

REM Assign drive letters
call diskpart /s diskpart_assign.txt
set RECOVERYDRIVE=%DL_MMOS%
set EFIDRIVE=%DL_EFIESP%

REM Initilize logging
set RECOVERY_LOG_FOLDER=%RECOVERYDRIVE%:\recoverylogs
md %RECOVERY_LOG_FOLDER%
echo --- Device recovery initiated --- >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
call time /t >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
copy %WINDIR%\system32\winpeshl.log %RECOVERY_LOG_FOLDER%

if exist pre_recovery_hook.cmd (
    call pre_recovery_hook.cmd  >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
    if errorlevel 1 goto :exit
)

REM Ensure recovery WIM files are available
if not exist %RECOVERYDRIVE%:\data.wim echo Missing data.wim file! >>%RECOVERY_LOG_FOLDER%\recovery_log.txt && goto exit
if not exist %RECOVERYDRIVE%:\mainos.wim echo Missing mainos.wim file! >>%RECOVERY_LOG_FOLDER%\recovery_log.txt && goto exit
if not exist %RECOVERYDRIVE%:\efiesp.wim echo Missing efiesp.wim file! >>%RECOVERY_LOG_FOLDER%\recovery_log.txt && goto exit

REM Perform recovery operations, logging to MMOS log file
call startnet_recovery.cmd >>%RECOVERY_LOG_FOLDER%\recovery_log.txt

if exist post_recovery_hook.cmd (
    call post_recovery_hook.cmd  >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
)

:exit
call time /t >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
echo --- Device recovery completed --- >>%RECOVERY_LOG_FOLDER%\recovery_log.txt

REM Go back to MainOS on next boot
bcdedit /store %EFIDRIVE%:\EFI\microsoft\boot\bcd /set {bootmgr} bootsequence {01de5a27-8705-40db-bad6-96fa5187d4a6}

REM Remove extra drive letters
call diskpart /s diskpart_remove.txt

REM Restart system
wpeutil reboot
