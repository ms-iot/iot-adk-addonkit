@echo off

goto START

:Usage
echo Usage: createprovpkg customizations.xml provpkgname
echo    customizations.xml.......... Input customization.xml file
echo    provpkgname................. Output filename
echo    [/?]........................ Displays this usage string.
echo    Example:
echo        createprovpkg C:\IotCoreOEMSDK\Templates\customizations.xml C:\temp\provpkg.ppkg

exit /b 1

:START

setlocal
REM Input validation
if [%1] == [/?] goto Usage
if [%1] == [-?] goto Usage
if [%1] == [] goto Usage
if [%2] == [] goto Usage
REM Checking prerequisites
if NOT DEFINED SRC_DIR (
    echo Environment not defined. Call setenv
    goto End
)
REM Start processing command
set STORE_DIR=%KITSROOT%\Assessment and Deployment Kit\Imaging and Configuration Designer\x86

echo Creating Provisioning Package using %1
cd %~dp1
call icd.exe /Build-ProvisioningPackage /CustomizationXML:"%1" /PackagePath:%2 /StoreFile:"%STORE_DIR%\Microsoft-IoTUAP-Provisioning.dat" +Overwrite /Variables:"BSPVER=%PKG_VER%"
if errorlevel 1 goto Error

goto End

:Error
endlocal
echo "provpkg %1" failed with error %ERRORLEVEL%
exit /b 1

:End
endlocal
exit /b 0