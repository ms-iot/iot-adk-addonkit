:: Setup bitlocker

reg query HKLM\Software\IoT /v DeviceGuardBitlockerSetup >nul 2>&1

if %errorlevel% == 1 (
    schtasks /Create /TN "\Microsoft\Windows\IoT\DeviceEncryption" /XML %~dp0DETask.xml /f
    reg add HKLM\Software\IoT /v DeviceGuardBitlockerSetup /t REG_DWORD /d 1 /f >nul 2>&1
)
