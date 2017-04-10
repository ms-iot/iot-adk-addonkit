@echo off

goto START

:Usage
echo Usage: buildimage [Product]/[All]/[Clean] [BuildType]
echo    ProductName....... Required, Name of the product to be created.
echo    All............... All Products under \Products directory are built
echo    Clean............. Cleans the output directory
echo        One of the above should be specified
echo    BuildType......... Optional, Retail/Test, if not specified both types are built
echo    [version]................. Optional, Package version. If not specified, it uses BSP_VERSION
echo    [/?]...................... Displays this usage string.
echo    Example:
echo        buildimage SampleA Test
echo        buildimage SampleA Retail
echo        buildimage SampleA
echo        buildimage All Test
echo        buildimage All
echo        buildimage Clean

exit /b 1

:START
if not defined PKGBLD_DIR (
    echo Environment not defined. Call setenv
    exit /b 1
)

if not exist "%BLD_DIR%" ( mkdir "%BLD_DIR%" )

REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage

if /I [%1] == [All] (
    echo Creating Images for all products under Products
    dir /b /AD %SRC_DIR%\Products\*.* > %BLD_DIR%\%BSP_ARCH%products.txt

    for /f "delims=" %%i in (%BLD_DIR%\%BSP_ARCH%products.txt) do (
        if [%2] ==[] (
            call :CALL_CREATEIMAGE %%i Test
            call :CALL_CREATEIMAGE %%i Retail
        ) else (
            call :CALL_CREATEIMAGE %%i %2
        )
    )

    del %BLD_DIR%\%BSP_ARCH%products.txt

) else if /I [%1] == [Clean] (
    if exist %BLD_DIR% (
        rmdir "%BLD_DIR%" /S /Q >nul
        echo Build directories cleaned
    ) else echo Nothing to clean.
) else (
    if [%2] ==[] (
        call :CALL_CREATEIMAGE %1 Test
        call :CALL_CREATEIMAGE %1 Retail
    ) else (
        call :CALL_CREATEIMAGE %1 %2
    )
)

exit /b

:CALL_CREATEIMAGE
echo Creating %1 %2 Image, see %BLD_DIR%\%1_%2.log for progress
call createimage.cmd %1 %2 > %BLD_DIR%\%1_%2.log
if errorlevel 1 ( echo.%CLRRED%Error : Build failed. See Log for details%CLREND% )
exit /b 0
