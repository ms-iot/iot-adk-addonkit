@echo off

goto START

:Usage
echo Usage: buildpkg [CompName.SubCompName]/[packagefile.wm.xml]/[All]/[Clean] [version]
echo    packagefile.wm.xml....... Package definition XML file
echo    CompName.SubCompName...... Package ComponentName.SubComponent Name
echo    All....................... All packages under \Packages directory are built
echo    Clean..................... Cleans the output directory
echo        One of the above should be specified
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildpkg sample.wm.xml
echo        buildpkg sample.wm.xml 10.0.1.0
echo        buildpkg Appx.Main
echo        buildpkg Appx.Main 10.0.1.0
echo        buildpkg All
echo        buildpkg All 10.0.2.0

exit /b 1

:START
pushd
setlocal ENABLEDELAYEDEXPANSION

if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)
if not exist %PPKGBLD_DIR% ( mkdir %PPKGBLD_DIR% )
if not exist %PPKGBLD_DIR%\logs ( mkdir %PPKGBLD_DIR%\logs )
if not exist %PKGLOG_DIR% ( mkdir %PKGLOG_DIR% )

REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I [%1] == [All] (
    echo Building all provisioning packages
    call buildprovpkg.cmd all

    REM echo Signing binaries in %COMMON_DIR%
    REM call signbinaries.cmd ppkg %COMMON_DIR%
    REM echo Signing binaries in %PKGSRC_DIR%
    REM call signbinaries.cmd bsp %PKGSRC_DIR%

    call convertpkg.cmd all 

    echo Building all packages under %COMMON_DIR%\Packages
    dir %COMMON_DIR%\Packages\*.wm.xml /S /b > %PKGLOG_DIR%\packagelist.txt

    call :SUB_PROCESSLIST %PKGLOG_DIR%\packagelist.txt %2
    
    echo Building all packages under %PKGSRC_DIR%
    dir %PKGSRC_DIR%\*.wm.xml /S /b > %PKGLOG_DIR%\packagelist.txt

    call :SUB_PROCESSLIST %PKGLOG_DIR%\packagelist.txt %2

    echo Building all bsp packages
    dir %BSPSRC_DIR%\*.wm.xml /S /b > %PKGLOG_DIR%\packagelist.txt
    call :SUB_PROCESSLIST %PKGLOG_DIR%\packagelist.txt %2
    REM call buildfm.cmd all %2
    echo.-----build done-----

) else if /I [%1] == [Clean] (
    call buildprovpkg.cmd clean
    if exist %PKGBLD_DIR% (
        rmdir "%PKGBLD_DIR%" /S /Q >nul
        echo Build directories cleaned
    ) else echo Nothing to clean.
) else (
    if [%~x1] == [.xml] (
        echo %1 > %PKGLOG_DIR%\packagelist.txt
    ) else (
        if exist "%PKGSRC_DIR%\%1" (
            REM Enabling support for multiple .wm.xml files in one directory.
            dir "%PKGSRC_DIR%\%1\*.wm.xml" /S /b > %PKGLOG_DIR%\packagelist.txt
        ) else if exist "%COMMON_DIR%\Packages\%1" (
            REM Enabling support for multiple .wm.xml files in one directory.
            dir "%COMMON_DIR%\Packages\%1\*.wm.xml" /S /b > %PKGLOG_DIR%\packagelist.txt
        ) else if exist "%1" (
            REM Enabling support for multiple .wm.xml files in one directory.
            dir "%1\*.wm.xml" /S /b > %PKGLOG_DIR%\packagelist.txt 2>nul
        ) else if exist "%COMMON_DIR%\ProdPackages\%1" (
            REM Enabling support for multiple .wm.xml files in one directory.
            echo %COMMON_DIR%\ProdPackages\%1\*.wm.xml > %PKGLOG_DIR%\packagelist.txt 2>nul
        ) else (
            REM Check if its in BSP path
            cd /D "%BSPSRC_DIR%"
            if exist "%1" (
                dir "%1\*.wm.xml" /S /b > %PKGLOG_DIR%\packagelist.txt 2>nul
            ) else (
                dir "%1" /S /B > %PKGLOG_DIR%\packagedir.txt 2>nul
                set /P RESULT=<%PKGLOG_DIR%\packagedir.txt
                if not defined RESULT (
                    echo.%CLRRED%Error : %1 not found.%CLREND%
                    goto Usage
                ) else (
                    if !RESULT! NEQ "" (
                       echo Signing all binaries in !RESULT!
                       call signbinaries.cmd bsp !RESULT!
                       dir "!RESULT!\*.wm.xml" /S /B > %PKGLOG_DIR%\packagelist.txt
                    )
                )
            )
        )
    )
    if exist %PKGLOG_DIR%\packagelist.txt (
        call :SUB_PROCESSLIST %PKGLOG_DIR%\packagelist.txt %2
    )
)
if exist %PKGLOG_DIR%\packagelist.txt ( del %PKGLOG_DIR%\packagelist.txt )
if exist %PKGLOG_DIR%\packagedir.txt ( del %PKGLOG_DIR%\packagedir.txt )

del %TMP%\* /S /Q >nul
for /d %%x in (%TMP%\*) do @rd /s /q "%%x" >nul 2>nul

endlocal
popd
exit /b

REM -------------------------------------------------------------------------------
REM
REM SUB_PROCESSLIST <filename>
REM
REM Processes the file list, calls createpkg for each item in the list
REM
REM -------------------------------------------------------------------------------
:SUB_PROCESSLIST
if %~z1 gtr 0 (
    for /f "delims=" %%i in (%1) do (
       echo. Processing %%~nxi
       call createpkg.cmd %%i %2 > %PKGLOG_DIR%\%%~ni.log
       if not errorlevel 0 ( echo.%CLRRED%Error : Failed to create package. See %PKGLOG_DIR%\%%~ni.log%CLREND%)
    )
) else (
    echo.%CLRRED%Error: No package definition files found.%CLREND%
)
exit /b