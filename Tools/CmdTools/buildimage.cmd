@echo off

goto START

:Usage
echo Usage: buildimage [Product] [BuildType]
echo    [Product]........... Required, Name of the product to be created.
echo    [BuildType]......... Required, Retail/Test
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildimage SampleA Test
echo        buildimage SampleA Retail

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
call RunPSCommand.cmd "New-IoTFFUImage" %*
exit /b 0
