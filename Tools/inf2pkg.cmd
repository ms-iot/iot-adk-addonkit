:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: inf2pkg input.inf [CompName.SubCompName] OwnerName
echo    input.inf............... Required, input .inf file
echo    CompName.SubCompName.... Optional, default is Drivers.input
echo    OwnerName............... Optional, default is $(OEMNAME)
echo    [/?].................... Displays this usage string.
echo    Example:
echo        inf2pkg C:\test\testdriver.inf
exit /b 1

:START
setlocal ENABLEDELAYEDEXPANSION

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if /I not [%~x1] == [.inf] goto Usage
if not defined BSP_ARCH (
    echo. BSP_ARCH not set. Setting to x86
    set BSP_ARCH=x86
)

set FILE_NAME=%~n1
set FILE_PATH=%~dp1
if not defined OUTPUT_PATH ( set "OUTPUT_PATH=%FILE_PATH%" )

if [%2] == [] (
    set COMP_NAME=Drivers
    set SUB_NAME=%FILE_NAME%
) else (
    for /f "tokens=1,* delims=." %%i in ("%2") do (
        set COMP_NAME=%%i
        set SUB_NAME=%%j
    )
)

if [%3] == [] (
    set "OWNERNAME=$(OEMNAME)"
) else (
    set OWNERNAME=%3
)

echo. Authoring %COMP_NAME%.%SUB_NAME%.wm.xml
if exist "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.wm.xml" (del "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.wm.xml" )
call :CREATE_PKGFILE

endlocal
exit /b 0

:CREATE_PKGFILE

REM Printing the headers
call :PRINT_TEXT "<?xml version="1.0" encoding="utf-8"?>"
call :PRINT_TEXT "<identity xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance""
echo.    name="%SUB_NAME%" namespace="%COMP_NAME%" owner="%OWNERNAME%" legacyName="%OWNERNAME%.%COMP_NAME%.%SUB_NAME%">>"%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.wm.xml"
call :PRINT_TEXT "    xmlns="urn:Microsoft.CompPlat/ManifestSchema.v1.00">"
call :PRINT_TEXT "    <onecorePackageInfo targetPartition="MainOS" releaseType="Production" ownerType="OEM" />"

call :PRINT_TEXT "    <drivers>"
call :PRINT_TEXT "        <driver>"
call :PRINT_TEXT "            <inf source="%FILE_NAME%.inf" />"
call :PRINT_TEXT "        </driver>"
call :PRINT_TEXT "    </drivers>"
call :PRINT_TEXT "</identity>"
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT!>> "%OUTPUT_PATH%\%COMP_NAME%.%SUB_NAME%.wm.xml"
exit /b

