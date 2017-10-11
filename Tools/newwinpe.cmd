@echo off

goto START

:Usage
echo Usage: newwinpe BSP BSPSrcDir
echo    BSP............... BSP Name
echo    BSPSrcDir......... BSP Source Directory
echo    [/?].............. Displays this usage string.
echo    Example:
echo        newwinpe RPi2 C:\rpibsp

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
set BSPDIR=%2

echo. Processing device layout in %BSP% bsp...
call partitioninfo.cmd %BSP% 
if errorlevel 1 ( goto :Error )

set WINPEDIR=%BSPSRC_DIR%\%BSP%\Packages\Recovery.WinPE
set MOUNTDIR=%BLD_DIR%\%BSP%\mount
if exist "%WINPEDIR%" (
    rmdir "%WINPEDIR%" /S /Q >nul 2>nul
)
md "%WINPEDIR%"
if exist "%MOUNTDIR%" (
    rmdir "%MOUNTDIR%" /S /Q >nul 2>nul
)
md "%MOUNTDIR%"

echo Copying WinPE from Install directory
copy "%WINPE_ROOT%\%BSP_ARCH%\en-us\winpe.wim" "%WINPEDIR%" >nul
copy "%IOTADK_ROOT%\Templates\startrecovery.cmd" %WINPEDIR%\startrecovery.cmd >nul
copy "%IOTADK_ROOT%\Templates\Recovery.WinPE.wm.xml" %WINPEDIR%\Recovery.WinPE.wm.xml >nul
echo Mounting WinPE at %MOUNTDIR%
dism /mount-wim /wimfile:%WINPEDIR%\winpe.wim /index:1 /mountdir:%MOUNTDIR%

REM Adding drivers only for ARM architecture
if [%BSP_ARCH%] == [arm] (
    if exist "%BSPDIR%" (
        dir "%BSPDIR%\*.inf" /S /B > %BSPDIR%\driverlist.txt
        for /f "delims=" %%i in (%BSPDIR%\driverlist.txt) do (
           echo. Adding %%~nxi
           dism /image:%MOUNTDIR% /add-driver /driver:%%i >nul
        )
        del %BSPDIR%\driverlist.txt
    ) else (
       echo No drivers added. Provide valid BSP source directory to add drivers.
    )
)
echo Copying files into WinPE
copy "%IOTADK_ROOT%\Templates\recovery\*.*" %MOUNTDIR%\windows\system32\ >nul
REM copy "%IOTADK_ROOT%\Templates\recovery\startnet_recovery.cmd" %MOUNTDIR%\windows\system32\ >nul
copy "%BLD_DIR%\%BSP%\%SOCNAME%\diskpart_assign.txt" %MOUNTDIR%\windows\system32\ >nul
copy "%BLD_DIR%\%BSP%\%SOCNAME%\diskpart_remove.txt" %MOUNTDIR%\windows\system32\ >nul

echo Saving and unmounting WinPE
dism /Unmount-image /mountdir:%MOUNTDIR% /commit
rmdir "%BLD_DIR%\%BSP%" /S /Q >nul

echo. WinPE is available at %WINPEDIR%
goto End

:Error
endlocal
echo "newwinpe %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0