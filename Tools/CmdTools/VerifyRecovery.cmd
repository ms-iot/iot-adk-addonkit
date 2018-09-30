@echo off

goto START

:Usage
echo Usage: VerifyRecovery [Product] [BuildType] 
echo    ProductName....... Required, Name of the product to be created.
echo    BuildType......... Required, Retail/Test
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        VerifyRecovery SampleA Test

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
call RunPSCommand.cmd "Test-IoTRecoveryImage" %*

exit /b 0