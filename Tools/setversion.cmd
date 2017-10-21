@echo off
:: Environment configurations

if [%1] == [] (
    if exist %PKGSRC_DIR%\versioninfo.txt (
        SET /P BSP_VERSION=< %PKGSRC_DIR%\versioninfo.txt
    ) else (
        SET BSP_VERSION=10.0.0.0
        echo. %PKGSRC_DIR%\versioninfo.txt not found. Defaulting to 10.0.0.0
    )
) else (
    REM TODO Insert version format validation
    SET BSP_VERSION=%1
)

echo %BSP_VERSION%> %PKGSRC_DIR%\versioninfo.txt
if defined SIGNTOOL_OEM_SIGN (
    set PROMPT=IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION% Retail$_$P$G
    TITLE IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION% Retail
) else (
    set PROMPT=IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION%$_$P$G
    TITLE IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION%
)
