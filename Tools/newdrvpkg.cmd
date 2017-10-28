:: Run setenv before running this script
:: This script creates the driver package
@echo off

goto START

:Usage
echo Usage: newdrvpkg filename.inf [CompName.SubCompName] [BSPName]
echo    filename.inf............ Required, input inf file
echo    CompName.SubCompName.... Optional, default is Drivers.filename; Mandatory if BSPName is specified
echo    BSPName................. Optional, if specified, the driver package will be at BSPName\Packages directory
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newdrvpkg C:\test\testdrv.inf
echo        newdrvpkg C:\test\testdrv.inf Drivers.TestDriver
echo        newdrvpkg C:\test\testdrv.inf ModelA.TestDriver ModelA

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

set FILE_TYPE=%~x1
set FILE_NAME=%~n1
set FILE_PATH=%~dp1


if /I [%FILE_TYPE%] == [.inf] (
    set COMP_NAME=Drivers
    set SUB_NAME=%FILE_NAME%
) else (
    echo. Unsupported filetype.
    goto Usage
)
if not [%2] == [] (
    for /f "tokens=1,2 delims=." %%i in ("%2") do (
        set COMP_NAME=%%i
        set SUB_NAME=%%j
    )
)

if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)

if defined USEUPDATE (
    set NEWPKG_DIR=%SRC_DIR%\Updates\%USEUPDATE%\%COMP_NAME%.%SUB_NAME%
) else (
    set NEWPKG_DIR=%SRC_DIR%\Packages\%COMP_NAME%.%SUB_NAME%
    if not [%3] == [] (
        if exist %SRC_DIR%\BSP\%3 (
            set NEWPKG_DIR=%SRC_DIR%\BSP\%3\Packages\%COMP_NAME%.%SUB_NAME%
        ) else (
            echo %3 BSP not found. Driver package created at %NEWPKG_DIR%
        )
    )
)

:: Error Checks
if /i exist %NEWPKG_DIR% (
    echo Error : %COMP_NAME%.%SUB_NAME% already exists
    goto End
)

:: Start processing command
echo Creating %COMP_NAME%.%SUB_NAME% package

mkdir "%NEWPKG_DIR%"

if /I [%FILE_TYPE%] == [.inf] (
    REM Create Pkgxml from inf file
    echo. Creating package xml file
    call inf2pkg.cmd %1 %COMP_NAME%.%SUB_NAME%
    REM copy the files to the package directory
    echo. Copying files to package directory
    copy "%FILE_PATH%\*" "%NEWPKG_DIR%\"
)

echo %NEWPKG_DIR% ready

goto End

:Error
endlocal
echo "newdrvpkg %1 %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
