REM recovery_init.cmd

echo IoT recovery initializing...

call setdrives.cmd

REM Make sure drive letters are available (using removal script), then assign drive letters
call diskpart /s diskpart_remove.txt >>%WINDIR%\system32\diskpart_remove_log.txt
call diskpart /s diskpart_assign.txt >>%WINDIR%\system32\diskpart_assign_log.txt
set RECOVERYDRIVE=%DL_MMOS%
set EFIDRIVE=%DL_EFIESP%
set DATADRIVE=%DL_Data%

REM Initialize logging
set RECOVERY_LOG_FOLDER=%RECOVERYDRIVE%:\recoverylogs
md %RECOVERY_LOG_FOLDER%
echo --- Device recovery initiated v1.2 --- >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
call date /t >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
call time /t >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
copy %WINDIR%\system32\winpeshl.log %RECOVERY_LOG_FOLDER%
copy %WINDIR%\system32\diskpart_assign_log.txt %RECOVERY_LOG_FOLDER%
copy %WINDIR%\system32\diskpart_remove_log.txt %RECOVERY_LOG_FOLDER%

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
REM Go back to MainOS on next boot
bcdedit /store %EFIDRIVE%:\EFI\microsoft\boot\bcd /set {bootmgr} bootsequence {01de5a27-8705-40db-bad6-96fa5187d4a6} >>%RECOVERY_LOG_FOLDER%\recovery_log.txt

call time /t >>%RECOVERY_LOG_FOLDER%\recovery_log.txt
copy %WINDIR%\Logs\DISM\dism.log %RECOVERY_LOG_FOLDER%
echo --- Device recovery completed --- >>%RECOVERY_LOG_FOLDER%\recovery_log.txt

REM Backup recovery logs in Data partition
md %DATADRIVE%:\PROGRAMS\recoverylogs
copy %RECOVERY_LOG_FOLDER%\* %DATADRIVE%:\PROGRAMS\recoverylogs

REM Remove extra drive letters
call diskpart /s diskpart_remove.txt

REM Restart system
wpeutil reboot