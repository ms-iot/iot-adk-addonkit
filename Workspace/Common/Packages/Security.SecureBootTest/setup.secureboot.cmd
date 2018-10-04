:: Setup secure boot 

reg query HKLM\Software\IoT /v DeviceGuardSecureBootSetup >nul 2>&1

if %errorlevel% == 1 (
    FWVar.exe put imagesecurity:db %~dp0SetVariable_db.bin NV BS RT TA >nul
    FWVar.exe put efiglobal:KEK %~dp0SetVariable_kek.bin NV BS RT TA >nul
    FWVar.exe put efiglobal:PK %~dp0SetVariable_pk.bin NV BS RT TA >nul
    reg add HKLM\Software\IoT /v DeviceGuardSecureBootSetup /t REG_DWORD /d 1 /f >nul 2>&1
)
