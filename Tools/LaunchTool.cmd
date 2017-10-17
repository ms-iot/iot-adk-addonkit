@echo off

set CLRRED=[91m
set CLRYEL=[93m
set CLREND=[0m
set CLRZ=[0m

REM Set IOTADK_ROOT
set IOTADK_ROOT=%~dp0
REM Getting rid of the \Tools\ at the end
set IOTADK_ROOT=%IOTADK_ROOT:~0,-7%

REM
REM Query the 32-bit and 64-bit Registry hive for KitsRoot
REM

set regKeyPathFound=1
set wowRegKeyPathFound=1
set KitsRootRegValueName=KitsRoot10

REG QUERY "HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots" /v %KitsRootRegValueName% 1>NUL 2>NUL || set wowRegKeyPathFound=0
REG QUERY "HKLM\Software\Microsoft\Windows Kits\Installed Roots" /v %KitsRootRegValueName% 1>NUL 2>NUL || set regKeyPathFound=0

if %wowRegKeyPathFound% EQU 0 (
  if %regKeyPathFound% EQU 0 (
    echo.%CLRRED%Error:No Windows Kits found. Install ADK.%CLREND%
    pause
    exit /b
  ) else (
    set regKeyPath=HKLM\Software\Microsoft\Windows Kits\Installed Roots
  )
) else (
    set regKeyPath=HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots
)

for /F "skip=2 tokens=2*" %%i in ('REG QUERY "%regKeyPath%" /v %KitsRootRegValueName%') do (SET KITPATH=%%jAssessment and Deployment Kit\Deployment Tools)
REM Cleanup local variables
set regKeyPathFound=
set wowRegKeyPathFound=
set KitsRootRegValueName=

REM Check for ADK Presence and Launch
if exist "%KITPATH%\DandISetEnv.bat" (
    call "%KITPATH%\DandISetEnv.bat"
    REM Get version number of the deployment tools installed
    reg query "HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.WindowsDeploymentTools.x86.10" /v Version > %IOTADK_ROOT%\adkversion.txt 2>nul
    for /F "skip=2 tokens=3" %%r in (%IOTADK_ROOT%\adkversion.txt) do ( set KIT_VERSION=%%r )
) else (
    echo.
    echo.%CLRRED%Error : ADK not found. Please install ADK.%CLREND%
    echo.
    pause
    exit /b
)
for /f "tokens=3 delims=." %%A in ("%KIT_VERSION%") do ( set ADK_VERSION=%%A )
del %IOTADK_ROOT%\adkversion.txt

REM Remove temporary variables
set KITPATH=
set KIT_VERSION=

REM Check for WDK Presence
if exist "%KITSROOT%\CoreSystem" (
    dir /B /AD "%KITSROOT%CoreSystem" > %IOTADK_ROOT%\wdkversion.txt
    set /P WDK_VERSION=<%IOTADK_ROOT%\wdkversion.txt
    del %IOTADK_ROOT%\wdkversion.txt
)

if defined WDK_VERSION (
    for /f "tokens=3 delims=." %%A in ("%WDK_VERSION%") do ( set WDK_VERSION=%%A )
) else (
    set WDK_VERSION=NotFound
)

REM Check for Corekit packages
if exist "%KITSROOT%\MSPackages" (
    REM Get version number of the Corekit packages installed
    reg query "HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_ARM_Packages.x86.10" /v Version > %IOTADK_ROOT%\corekitversion.txt 2>nul
    if errorlevel 1 (
        reg query "HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_X64_Packages.x86.10" /v Version > %IOTADK_ROOT%\corekitversion.txt 2>nul
        if errorlevel 1 (
            reg query "HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_X86_Packages.x86.10" /v Version > %IOTADK_ROOT%\corekitversion.txt 2>nul
            if errorlevel 1 (
                REM MSPackages present without this registry key - Assuming older version of packages.
                set COREKIT_VER=10586.0
            )
        )
    )
    if not defined COREKIT_VER (
        for /F "skip=2 tokens=3" %%r in (%IOTADK_ROOT%\corekitversion.txt) do ( set KIT_VERSION=%%r )
    )
    del %IOTADK_ROOT%\corekitversion.txt
) else (
    set COREKIT_VER=NotFound
    echo.%CLRYEL%Warning : Core kit packages not found. Image creation will fail.%CLREND%
)
if defined KIT_VERSION (
    for /f "tokens=2,* delims=." %%A in ("%KIT_VERSION%") do ( set COREKIT_VER=%%B )
)
REM Remove temporary variables
set KIT_VERSION=

set PATH=%PATH%;%IOTADK_ROOT%\Tools;
TITLE IoTCoreShell
REM Change to Working directory
cd /D %IOTADK_ROOT%\Tools
call setOEM.cmd
doskey /macrofile=alias.txt
set IOT_ADDON_VERSION=4.0

echo IOTADK_ROOT : %IOTADK_ROOT%
echo ADK_VERSION : %ADK_VERSION%
echo WDK_VERSION : %WDK_VERSION%
echo COREKIT_VER : %COREKIT_VER%
echo OEM_NAME    : %OEM_NAME%
echo.

if [%1] == [] (
    echo Set Environment for Architecture
    choice /C 123 /N /M "Choose 1 for ARM, 2 for x86 and 3 for x64 :"
    echo.
    if errorlevel 3 (
        call setenv x64
    ) else if errorlevel 2 (
        call setenv x86
    ) else if errorlevel 1 (
        call setenv arm
    )
) else (
    echo Setting Environment for Architecture %1
    call setenv %1
)


