@echo off

goto START

:Usage
echo Usage: flashSD_FFU [FFU] [DriveNr]
echo    FFU............... Required, FFU file to flash
echo    DriveNr........... PhysicalDrive number to which the USB is mounted
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        flashSD_FFU D:\Temp\Flash.ffu 2

exit /b 1

:START

REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

set IMG_FILE=%1
if exist "%IMG_FILE%" (
    echo Running Dism : %1 on PhysicalDrive%2
    call dism /apply-image /imagefile:"%IMG_FILE%" /ApplyDrive:\\.\PhysicalDrive%2 /SkipPlatformCheck
) else (
    echo. Error: %IMG_FILE% not found.
)
exit /b
