REM startnet.cmd

echo IoT recovery initializing...

if exist "recoverygui.exe" (
REM If GUI app exists, launch and allow it to control the recovery workflow
REM NOTE: This GUI app will need to call either recover_init.cmd or recovery_cancel.cmd, based on user input
    start recoverygui.exe
REM NOTE: If the GUI is only used to show a splash screen, uncomment line below to call recovery_init.cmd
REM call recovery_init.cmd
) else (
REM If GUI app not available, automatically trigger recovery script
REM call recovery_cancel.cmd
    call recovery_init.cmd
)
