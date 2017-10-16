@echo off
REM Run setenv before running this script
REM This script creates the folder structure and copies the template files for a new product

goto START

:Usage
echo Usage: newbsp BSPName
echo    BSPName........... Required, Name of the BSP to be used
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newbsp CustomRPi2
echo Existing BSPs are
dir /b /AD %BSPSRC_DIR%

exit /b 1

:START
setlocal

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)
REM Error Checks
set NEWBSP=%1
set NEWBSP_DIR=%BSPSRC_DIR%\%NEWBSP%
set TEMPLATE_DIR=%IOTADK_ROOT%\Templates\BSP
if /i exist %NEWBSP_DIR% (
    echo Error : %1 already exists
    goto Usage
)

REM FMFileList requires the arch to be specified in CAPS
set ARCH_CAP=%BSP_ARCH:arm=ARM%
set ARCH_CAP=%ARCH_CAP:x=X%
set ARCH_CAP=%ARCH_CAP:amd=AMD%

REM Start processing command
echo Creating %1 BSP

mkdir "%NEWBSP_DIR%"
mkdir "%NEWBSP_DIR%\Packages"
mkdir "%NEWBSP_DIR%\OEMInputSamples"
mkdir "%NEWBSP_DIR%\WinPEExt"

powershell -Command "(gc %TEMPLATE_DIR%\RetailOEMInputTemplate.xml) -replace '{BSP}', '%NEWBSP%' -replace '{arch}', '%BSP_ARCH%' | Out-File %NEWBSP_DIR%\OEMInputSamples\RetailOEMInput.xml -Encoding utf8"
powershell -Command "(gc %TEMPLATE_DIR%\TestOEMInputTemplate.xml) -replace '{BSP}', '%NEWBSP%' -replace '{arch}', '%BSP_ARCH%' | Out-File %NEWBSP_DIR%\OEMInputSamples\TestOEMInput.xml -Encoding utf8"
powershell -Command "(gc %TEMPLATE_DIR%\BSPFMTemplate.xml) -replace '{BSP}', '%NEWBSP%' -replace '{arch}', '%BSP_ARCH%' | Out-File %NEWBSP_DIR%\Packages\%NEWBSP%FM.xml -Encoding utf8"
powershell -Command "(gc %TEMPLATE_DIR%\BSPFMFileListTemplate.xml) -replace '{BSP}', '%NEWBSP%' -replace '{arch}', '%ARCH_CAP%' | Out-File %NEWBSP_DIR%\Packages\%NEWBSP%FMFileList.xml -Encoding utf8"

copy "%TEMPLATE_DIR%\WinPEExtReadme.txt" "%NEWBSP_DIR%\WinPEExt\"


echo %1 BSP directories ready
goto End


:Error
endlocal
echo "newbsp %1 " failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
