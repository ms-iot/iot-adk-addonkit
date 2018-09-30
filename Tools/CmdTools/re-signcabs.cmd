@echo off
goto START

:Usage
echo Usage: re-signcabs [SrcCabDir] [DstCabDir]
echo    SrcCabDir....... Required, Source directory for the cabs to be re-signed
echo    DstCabDir....... Required, Destination directory for the re-signed cabs
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        re-signcabs C:\Dir1 C:\Dir2

exit /b 1

:START
REM Input validation
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Redo-IoTCabSignature" %*
exit /b 0