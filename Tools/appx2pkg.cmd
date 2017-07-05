:: Run setenv before running this script
:: This script creates the folder structure and copies the template files for a new package
@echo off

goto START

:Usage
echo Usage: appx2pkg input.appx [fga/bgt/none] [CompName.SubCompName] [skipcert]
echo    input.appx.............. Required, input .appx file
echo    fga/bgt/none............ Required, Startup ForegroundApp / Startup BackgroundTask / No startup
echo    CompName.SubCompName.... Optional, default is Appx.AppxName; Mandatory if you want to specify skipcert
echo    skipcert................ Optional, specify this to skip adding cert information to pkg xml file
echo    [/?].................... Displays this usage string.
echo    Example:
echo        appx2pkg C:\test\sample_1.0.0.0_arm.appx none
endlocal
exit /b 1

:START

setlocal ENABLEDELAYEDEXPANSION
set STARTUP_OPTIONS=fga bgt none

if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage

if not [%~x1] == [.appx] goto Usage
set LONG_NAME=%~n1
set FILE_NAME=%~n1
set "FILE_PATH=%~dp1"

call %TOOLS_DIR%\GetAppxInfo.exe "%1" > "%FILE_PATH%\appx_info.txt" 2>nul
for /f "tokens=1,2,3 delims=:,!, " %%i in (%FILE_PATH%\appx_info.txt) do (
    set APPX_%%i=%%j
    if [%%i] == [AppUserModelId] (
        set PACKAGE_FNAME=%%j
        set ENTRY=%%k
    )
)

if not defined PROV_VERSION if /i "%ADK_VERSION%" LSS "16190" (
     set PROV_VERSION=1.0
) else (
    set PROV_VERSION=%APPX_Version%
)

if not defined PROV_RANK ( set PROV_RANK=0)

echo. Provisioning package version : %PROV_VERSION%
echo.                      rank    : %PROV_RANK%

for %%A in (%STARTUP_OPTIONS%) do (
    if [%%A] == [%2] (
        set STARTUP=%2
    )
)
if not defined STARTUP (
    echo. Error : Invalid Startup option.
    goto Usage
)

if [%3] == [] (
    set COMP_NAME=Appx
    for /f "tokens=1 delims=_" %%i in ("%FILE_NAME%") do (
        set SUB_NAME=%%i
    )
) else (
    for /f "tokens=1,2 delims=." %%i in ("%3") do (
        set COMP_NAME=%%i
        set SUB_NAME=%%j
    )
    if /I [%4] == [skipcert] ( set SKIPCERT=1)
)

REM Start processing command
REM Get Appx dependencies
if exist "%FILE_PATH%\Dependencies\%ARCH%" (
    set DEP_PATH=Dependencies\%ARCH%
    dir /b "%FILE_PATH%\Dependencies\%ARCH%\*.appx" > "%FILE_PATH%\appx_deplist.txt" 2>nul
) else if exist "%FILE_PATH%\Dependencies" (
    set DEP_PATH=Dependencies
    dir /b "%FILE_PATH%\Dependencies\*.appx" > "%FILE_PATH%\appx_deplist.txt" 2>nul
) else if exist "%FILE_PATH%\%ARCH%" (
    set DEP_PATH=%ARCH%
    dir /b "%FILE_PATH%\%ARCH%\*.appx" > "%FILE_PATH%\appx_deplist.txt" 2>nul
) else (
    set DEP_PATH=.
    dir /b "%FILE_PATH%\*%ARCH%*.appx" > "%FILE_PATH%\appx_deplist.txt" 2>nul
)

if not defined SKIPCERT (
    dir /b "%FILE_PATH%\*.cer" > "%FILE_PATH%\appx_cerlist.txt" 2>nul
)

dir /b "%FILE_PATH%\*License*.xml" > "%FILE_PATH%\appx_license.txt" 2>nul
set /P LICENSE_FILE=<"%FILE_PATH%\appx_license.txt"
if defined LICENSE_FILE (
    for /f "tokens=8,9 delims==, " %%i in (%FILE_PATH%\%LICENSE_FILE%) do (
        if [%%i] == [LicenseID] (
            set LICENSE_ID=%%j
        )
    )
    echo.  LicenseProductID : !LICENSE_ID!
)

echo. Authoring %COMP_NAME%.%SUB_NAME%.pkg.xml
if exist "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" (del "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" )
call :CREATE_PKGFILE

if exist "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" (
    call convertpkg.cmd "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml" >nul 2>nul
)

echo. Authoring %CUSTOMIZATIONS%.xml
if exist "%FILE_PATH%\%CUSTOMIZATIONS%.xml" (del "%FILE_PATH%\%CUSTOMIZATIONS%.xml" )
REM Get a new GUID for the Provisioning config file
powershell -Command "[System.Guid]::NewGuid().toString() | Out-File %PRODSRC_DIR%\uuid.txt -Encoding ascii"
set /p NEWGUID=<%PRODSRC_DIR%\uuid.txt
del %PRODSRC_DIR%\uuid.txt
call :CREATE_CUSTFILE

if not defined SKIPCERT (
    del "%FILE_PATH%\appx_cerlist.txt"
)
del "%FILE_PATH%\appx_license.txt"
del "%FILE_PATH%\appx_deplist.txt"
del "%FILE_PATH%\appx_info.txt"

endlocal
exit /b 0

:CREATE_PKGFILE
REM Printing the headers
call :PRINT_TEXT "<?xml version="1.0" encoding="utf-8" ?>"
call :PRINT_TEXT "<Package xmlns="urn:Microsoft.WindowsPhone/PackageSchema.v8.00""
echo          Owner="$(OEMNAME)" OwnerType="OEM" ReleaseType="Production" >> "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml"
call :PRINT_TEXT "         Platform="%BSP_ARCH%" Component="%COMP_NAME%" SubComponent="%SUB_NAME%">"
call :PRINT_TEXT "   <Components>"
call :PRINT_TEXT "      <OSComponent>"
call :PRINT_TEXT "         <Files>"
REM Printing script files inclusion
call :PRINT_TEXT "            <File Source="%COMP_NAME%.%SUB_NAME%.ppkg" "
echo                   DestinationDir="$(runtime.windows)\Provisioning\Packages" >> "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml"
call :PRINT_TEXT "                  Name="%COMP_NAME%.%SUB_NAME%.ppkg" />"
call :PRINT_TEXT "         </Files>"
call :PRINT_TEXT "      </OSComponent>"
call :PRINT_TEXT "   </Components>"
call :PRINT_TEXT "</Package>"
)
exit /b 0

:CREATE_CUSTFILE

REM Printing the headers
call :PRINT_TO_CUSTFILE "<?xml version="1.0" encoding="utf-8" ?>"
call :PRINT_TO_CUSTFILE "<WindowsCustomizations>"
call :PRINT_TO_CUSTFILE "  <PackageConfig xmlns="urn:schemas-Microsoft-com:Windows-ICD-Package-Config.v1.0">"
call :PRINT_TO_CUSTFILE "    <ID>{%NEWGUID%}</ID>"
call :PRINT_TO_CUSTFILE "    <Name>%SUB_NAME%Prov</Name>"
call :PRINT_TO_CUSTFILE "    <Version>%PROV_VERSION%</Version>"
call :PRINT_TO_CUSTFILE "    <OwnerType>OEM</OwnerType>"
call :PRINT_TO_CUSTFILE "    <Rank>%PROV_RANK%</Rank>"
call :PRINT_TO_CUSTFILE "  </PackageConfig>"
call :PRINT_TO_CUSTFILE "  <Settings xmlns="urn:schemas-microsoft-com:windows-provisioning">"
call :PRINT_TO_CUSTFILE "    <Customizations>"
call :PRINT_TO_CUSTFILE "      <Common>"
if /i "%ADK_VERSION%" LSS "16190" (
    call :PRINT_TO_CUSTFILE "        <ApplicationManagement>"
    call :PRINT_TO_CUSTFILE "          <AllowAllTrustedApps>Yes</AllowAllTrustedApps>"
    call :PRINT_TO_CUSTFILE "        </ApplicationManagement>"
) else (
    call :PRINT_TO_CUSTFILE "        <Policies>"
    call :PRINT_TO_CUSTFILE "          <ApplicationManagement>"
    call :PRINT_TO_CUSTFILE "            <AllowAllTrustedApps>Yes</AllowAllTrustedApps>"
    call :PRINT_TO_CUSTFILE "          </ApplicationManagement>"
    call :PRINT_TO_CUSTFILE "        </Policies>"
)
REM Printing Certificates
if not defined SKIPCERT (
    for %%B in ("%FILE_PATH%\appx_cerlist.txt") do if %%~zB gtr 0 (
        call :PRINT_TO_CUSTFILE "        <Certificates>"
        call :PRINT_TO_CUSTFILE "          <RootCertificates>"
        for /f "useback delims=" %%A in ("%FILE_PATH%\appx_cerlist.txt") do (
            call :PRINT_TO_CUSTFILE "            <RootCertificate CertificateName="%%~nA" Name="%%~nA">"
            call :PRINT_TO_CUSTFILE "              <CertificatePath>%%A</CertificatePath>"
            call :PRINT_TO_CUSTFILE "            </RootCertificate>"
        )
        call :PRINT_TO_CUSTFILE "          </RootCertificates>"
        call :PRINT_TO_CUSTFILE "        </Certificates>"
    ) else (
      echo. No Certificates. Skipping Certificate section.
    )
) else (
  echo. SkipCert defined. Skipping Certificate section.
)

REM Print startup configuration
if [%STARTUP%] == [fga] (
    call :PRINT_TO_CUSTFILE "        <StartupApp>"
    call :PRINT_TO_CUSTFILE "          <Default>"
    echo            %PACKAGE_FNAME%^^!%ENTRY% >> "%FILE_PATH%\%CUSTOMIZATIONS%.xml"
    call :PRINT_TO_CUSTFILE "          </Default>"
    call :PRINT_TO_CUSTFILE "        </StartupApp>"
) else if [%STARTUP%] == [bgt] (
    call :PRINT_TO_CUSTFILE "        <StartupBackgroundTasks>"
    call :PRINT_TO_CUSTFILE "          <ToAdd>"
    call :PRINT_TO_CUSTFILE "            <Add PackageName="
    echo             "%PACKAGE_FNAME%^!%ENTRY%" >> "%FILE_PATH%\%CUSTOMIZATIONS%.xml"
    call :PRINT_TO_CUSTFILE "            ></Add>"
    call :PRINT_TO_CUSTFILE "          </ToAdd>"
    call :PRINT_TO_CUSTFILE "        </StartupBackgroundTasks>"
) else (
    echo. No Startup configuration, skipping Startup section
)

REM Printing APP Install
call :PRINT_TO_CUSTFILE "        <UniversalAppInstall>"
call :PRINT_TO_CUSTFILE "          <UserContextApp>"
call :PRINT_TO_CUSTFILE "            <Application PackageFamilyName="%PACKAGE_FNAME%" Name="%PACKAGE_FNAME%">"
call :PRINT_TO_CUSTFILE "              <ApplicationFile>%LONG_NAME%.appx</ApplicationFile>"
REM Printing Dependencies
for %%B in ("%FILE_PATH%\appx_deplist.txt") do if %%~zB gtr 0 (
    call :PRINT_TO_CUSTFILE "              <DependencyAppxFiles>"
    for /f "useback delims=" %%A in ("%FILE_PATH%\appx_deplist.txt") do (
        if [%%A] NEQ [%LONG_NAME%.appx] (
            call :PRINT_TO_CUSTFILE "                <Dependency Name="%%A">%DEP_PATH%\%%A</Dependency>"
        )
    )
    call :PRINT_TO_CUSTFILE "              </DependencyAppxFiles>"
) else (
  echo. No Dependencies found. Skipping Dependencies section.
)
call :PRINT_TO_CUSTFILE "              <DeploymentOptions>Force target application shutdown</DeploymentOptions>"
call :PRINT_TO_CUSTFILE "            </Application>"
call :PRINT_TO_CUSTFILE "          </UserContextApp>"

REM Print license file if present
if defined LICENSE_FILE (
    call :PRINT_TO_CUSTFILE "          <UserContextAppLicense>"
    call :PRINT_TO_CUSTFILE "            <LicenseInstall LicenseProductId=%LICENSE_ID% Name=%LICENSE_ID%>.\%LICENSE_FILE%</LicenseInstall>"
    call :PRINT_TO_CUSTFILE "          </UserContextAppLicense>"
) else (
  echo. No License file. Skipping License section.
)

call :PRINT_TO_CUSTFILE "        </UniversalAppInstall>"

call :PRINT_TO_CUSTFILE "      </Common>"
call :PRINT_TO_CUSTFILE "    </Customizations>"
call :PRINT_TO_CUSTFILE "  </Settings>"
call :PRINT_TO_CUSTFILE "</WindowsCustomizations>"
)
exit /b 0

:PRINT_TEXT
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT! >> "%FILE_PATH%\%COMP_NAME%.%SUB_NAME%.pkg.xml"
exit /b

:PRINT_TO_CUSTFILE
for /f "useback tokens=*" %%a in ('%1') do set TEXT=%%~a
echo !TEXT! >> "%FILE_PATH%\%CUSTOMIZATIONS%.xml"
exit /b