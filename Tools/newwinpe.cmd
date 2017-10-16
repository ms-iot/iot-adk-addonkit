@echo off

goto START

:Usage
echo Usage: newwinpe BSP SOCNAME
echo    BSP............... BSP Name
echo    SOCNAME........... SOCNAME for the device layout to be used- defined in BSPFM.xml
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newwinpe QCDB410C QC8016_R

exit /b 1

:START
setlocal
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

REM Checking prerequisites
if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)
if not exist "%BSPSRC_DIR%\%1" (
    echo %1 is not a valid BSP.
    goto Usage
)

set BSP=%1
set SOCNAME=%2
set WINPEEXTDRV=%BSPSRC_DIR%\%BSP%\WinPEExt\Drivers
set WINPEEXTFILES=%BSPSRC_DIR%\%BSP%\WinPEExt\recovery
set WINPEDIR=%BLD_DIR%\%BSP%
set WINPEFILES=%WINPEDIR%\recovery
set MOUNTDIR=%BLD_DIR%\%BSP%\mount
if exist "%WINPEDIR%" (
    rmdir "%WINPEDIR%" /S /Q >nul 2>nul
)
md "%WINPEDIR%"
if exist "%MOUNTDIR%" (
    rmdir "%MOUNTDIR%" /S /Q >nul 2>nul
)
md "%MOUNTDIR%"

echo. Processing device layout in %BSP% bsp...
call partitioninfo.cmd %BSP% %SOCNAME%
if errorlevel 1 ( goto :Error )

echo Copying WinPE from Install directory
copy "%WINPE_ROOT%\%BSP_ARCH%\en-us\winpe.wim" "%WINPEDIR%" >nul

echo Mounting WinPE at %MOUNTDIR%
dism /mount-wim /wimfile:%WINPEDIR%\winpe.wim /index:1 /mountdir:%MOUNTDIR%

REM Adding drivers 
if exist "%WINPEEXTDRV%" (
    dir "%WINPEEXTDRV%\*.inf" /S /B > %WINPEEXTDRV%\driverlist.txt 2>nul
    for %%Z in ("%WINPEEXTDRV%\driverlist.txt") do if %%~zZ gtr 0 (
       echo. Adding %%~nxZ
       dism /image:%MOUNTDIR% /add-driver /driver:%%Z >nul
    ) else (
        echo. No drivers found in %WINPEEXTDRV%.
    )
    del %WINPEEXTDRV%\driverlist.txt >nul 2>nul
) else (
   echo %WINPEEXTDRV% not present. No drivers added.
)

echo Copying files into WinPE
copy "%IOTADK_ROOT%\Templates\recovery\*" %MOUNTDIR%\windows\system32\ 
copy "%WINPEFILES%\*" %MOUNTDIR%\windows\system32\ 
if exist %WINPEEXTFILES% (
    copy "%WINPEEXTFILES%\*" %MOUNTDIR%\windows\system32\
)

echo Saving and unmounting WinPE
dism /Unmount-image /mountdir:%MOUNTDIR% /commit
rmdir "%MOUNTDIR%" /S /Q >nul

echo. WinPE is available at %WINPEDIR%
goto End

:Error
endlocal
echo "newwinpe %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0