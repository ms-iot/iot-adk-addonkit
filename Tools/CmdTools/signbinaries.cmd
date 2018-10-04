@echo off

goto :START

:Usage
echo Usage: signbinaries [dir] [type]
echo    dir  .................. Directory where the files are present
echo    type .................. optional, csv values of file types to sign
echo    [/?] .................. Displays this usage string.
echo    Example:
echo        signbinaries %BSPSRC_DIR% *.sys,*.dll
echo        signbinaries %BSPSRC_DIR% 
echo        If no type is specified, it signs all '*.exe', '*.sys', '*.dll', '*.cat' files
exit /b 1

:START
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "Add-IoTSignature" %*

exit /b 0
