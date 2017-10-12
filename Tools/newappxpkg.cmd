@echo off
REM Run setenv before running this script
REM This script creates the folder structure and copies the template files for a new package


goto START

:Usage
echo Usage: newappxpkg filename.appx [fga/bgt/none] [CompName.SubCompName] [skipcert]
echo    filename.appx........... Required, Input appx package/appxbundle. Expects dependencies in a sub folder
echo    fga/bgt/none............ Required, Startup ForegroundApp / Startup BackgroundTask / No startup
echo    CompName.SubCompName.... Optional, default is Appx.AppxName; Mandatory if you want to specify skipcert
echo    skipcert................ Optional, specify this to skip adding cert information to pkg xml file
echo    [/?]............ Displays this usage string.
echo    Example:
echo        newappxpkg C:\test\MainAppx_1.0.0.0_arm.appx fga Appx.Main
echo        newappxpkg C:\test\MainAppx_1.0.0.0_arm.appx none 
echo Existing packages are
dir /b /AD %SRC_DIR%\Packages

exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

set FILE_TYPE=%~x1
set FILE_NAME=%~n1
set "FILE_PATH=%~dp1"

if not [%FILE_TYPE%] == [.appx] (
    if not [%FILE_TYPE%] == [.appxbundle] (
        echo. Unsupported filetype.
        goto Usage
    )
)

set STARTUP_OPTIONS=fga bgt none
for %%A in (%STARTUP_OPTIONS%) do (
    if [%%A] == [%2] (
        set STARTUP=%2
    )
)
if not defined STARTUP (
    echo. Error : Invalid Startup option.
    goto Usage
)

if not [%3] == [] (
    for /f "tokens=1,2 delims=." %%i in ("%3") do (
        set COMP_NAME=%%i
        set SUB_NAME=%%j
    )
    if /I [%4] == [skipcert] ( set SKIPCERT=1)
) else (
    set COMP_NAME=Appx
    for /f "tokens=1 delims=_" %%i in ("%FILE_NAME%") do (
        set SUB_NAME=%%i
    )
)

if not defined SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)

if defined USEUPDATE (
    set "NEWPKG_DIR=%SRC_DIR%\Updates\%USEUPDATE%\%COMP_NAME%.%SUB_NAME%"
) else (
    set "NEWPKG_DIR=%SRC_DIR%\Packages\%COMP_NAME%.%SUB_NAME%"
)

REM Error Checks
if /i exist %NEWPKG_DIR% (
    echo Warning : %COMP_NAME%.%SUB_NAME% already exists
    choice /T 5 /D Y /M "Do you want to overwrite"
    if errorlevel 2 (
        goto End 
    )
)

REM Start processing command
echo Creating %COMP_NAME%.%SUB_NAME% package

mkdir "%NEWPKG_DIR%"

if /i exist %SRC_DIR%\Packages\%COMP_NAME%.%SUB_NAME%\customizations.xml (
    echo %COMP_NAME%.%SUB_NAME% source package found
    findstr /L "<ID>" %SRC_DIR%\Packages\%COMP_NAME%.%SUB_NAME%\customizations.xml > %NEWPKG_DIR%\guid.txt
    for /f "tokens=3 delims=<,>,{,}" %%i in (%NEWPKG_DIR%\guid.txt) do (
        set NEWGUID=%%i
    )
    echo PPKG ID : !NEWGUID!
    del %NEWPKG_DIR%\guid.txt >nul
)

REM Create Appx Package using template files
echo. Creating package xml files
call appx2pkg.cmd %1 %STARTUP% %COMP_NAME%.%SUB_NAME% %4
REM Move the files to the package directory
move "%FILE_PATH%\Package\*" "%NEWPKG_DIR%\" >nul 2>nul

rmdir %FILE_PATH%\Package >nul 2>nul

echo %NEWPKG_DIR% ready
goto End

:Error
endlocal
echo "newappxpkg %APPX% %STARTUP% %2" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0
