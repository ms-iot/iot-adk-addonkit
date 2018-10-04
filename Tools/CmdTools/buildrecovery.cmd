@echo off

goto START

:Usage
echo Usage: buildrecovery [Product] [BuildType] [WimMode] [WimDir]
echo    Product........... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    WimMode........... Optional, Import/Export - import wim files or export wim files
echo    WimDir............ Required if WimMode specified, Directory containing MainOS/Data/EFIESP wims
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildrecovery SampleA Test
echo        buildrecovery SampleA Retail export C:\Wimfiles
echo        buildrecovery SampleB Retail import C:\Wimfiles

exit /b 1

:START
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not defined IOTWKSPACE (
    echo Error: No Workspace found. Open Workspace using open-ws 
    exit /b 1
)
call RunPSCommand.cmd "New-IoTRecoveryImage" %*

exit /b 0
