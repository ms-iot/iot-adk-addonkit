@echo off

goto START

:ERROR_USAGE
@echo Unrecognized command
set ERROR_CODE=1
goto :USAGE

:USAGE
@echo.
@echo Signs the exe/dll provided at the command-line.
@echo.
@echo sign [/-?] filename [filename2] [filename3]
@echo.
@echo usage:
@echo.
@echo sign [ -pkg] ^<file1^> ^<file2^> [..]  -- signs file1, file2, etc.
@echo.
@echo Signing related switches
@echo -pkg      sign package
@echo.
@echo Examples:
@echo.
@echo      sign.cmd file.dll - sign file.dll with the default WP EKU

goto :EOF

:START
setlocal

set PAGE_HASH=

:GETPARAMS

if "%~1"==""   goto USAGE
if "%~1"=="/?" goto USAGE
if "%~1"=="-?" goto USAGE
if "%~1"=="-help" goto USAGE

rem Parse parameters
if /I "%~1"=="/hal" (
    set CERTIFICATEFLAG=hal
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-hal" (
    set CERTIFICATEFLAG=hal
    shift
    goto :GETPARAMS
)
if /I "%~1"=="/oem" (
    set SIGN_OEM=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-oem" (
    set SIGN_OEM=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="/pkg" (
    set CERTIFICATEFLAG=pkg
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-pkg" (
    set CERTIFICATEFLAG=pkg
    shift
    goto :GETPARAMS
)
if /I "%~1"=="/testonly" (
    set TEST_ONLY_SIGNATURE=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-testonly" (
    set TEST_ONLY_SIGNATURE=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="/test" (
    set TEST_ONLY_SIGNATURE=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-test" (
    set TEST_ONLY_SIGNATURE=1
    shift
    goto :GETPARAMS
)
if /I "%~1"=="/nosigninfo" (
    set SIGNINFO_GENERATION=/nosigninfo
    shift
    goto :GETPARAMS
)
if /I "%~1"=="-nosigninfo" (
    set SIGNINFO_GENERATION=/nosigninfo
    shift
    goto :GETPARAMS
)

set FILELIST=

REM if "%SIGN_OEM%"=="1" goto :UseOEMTestCertificates

REM Ensure the crosscert variables are both set and give error messages if wrong
if defined CROSS_CERT_ISSUER (
    if not defined CROSS_CERT_SUBJECTNAME (
        echo Must set both CROSS_CERT_ISSUER and CROSS_CERT_SUBJECTNAME
        set ERRORLEVEL=1
        goto :SIGN_REPORT
    )
) else (
    if defined CROSS_CERT_SUBJECTNAME (
        echo Must set both CROSS_CERT_ISSUER and CROSS_CERT_SUBJECTNAME
        set ERRORLEVEL=1
        goto :SIGN_REPORT
    )
)

set SIGN_NULL=1
for %%i in (%SIGNTOOL_OEM_SIGN%) do if not "%%i"=="" set SIGN_NULL=0

if "%SIGN_NULL%"=="1" (
    if defined CROSS_CERT_ISSUER (
        set SIGNTOOL_OEM_SIGN=/s my /i "%CROSS_CERT_ISSUER%" /n "%CROSS_CERT_SUBJECTNAME%" /fd SHA256
    ) else (
        set SIGNTOOL_OEM_SIGN=/a /s my /i "Windows OEM Intermediate 2017 (TEST ONLY)" /n "Windows OEM Test Cert 2017 (TEST ONLY)" /fd SHA256
    )
)

set SIGN_NULL=1
for %%i in (%SIGNTOOL_OEM_SIGN_HAL%) do if not "%%i"=="" set SIGN_NULL=0

if "%SIGN_NULL%"=="1" (
    set SIGNTOOL_OEM_SIGN_HAL=/a /s my /i "Windows OEM Intermediate 2017 (TEST ONLY)" /n "Windows OEM HAL Extension Test Cert 2017 (TEST ONLY)" /fd SHA256
)

REM reset default to OEM cert
set CERTIFICATE=%SIGNTOOL_OEM_SIGN%

if "%CERTIFICATEFLAG%"=="hal" set CERTIFICATE=%SIGNTOOL_OEM_SIGN_HAL%

goto :SIGNLOOP

:SIGNLOOP

    if "%~1"=="" goto :FILELISTCOMPLETE
    set FILELIST=%FILELIST% "%~1"
    shift
    goto :SIGNLOOP

:FILELISTCOMPLETE

if "%SIGN_WITH_TIMESTAMP%"=="1" set TIMESERVER=/t http://timestamp.digicert.com/scripts/timestamp.dll
set SIGNTOOL_EXE=signtool.exe

echo %SIGNTOOL_EXE% sign /v %Certificate% %PAGE_HASH% %TIMESERVER% %TESTFILEIDARG% %FILELIST%
%SIGNTOOL_EXE% sign /v %Certificate% %PAGE_HASH% %TIMESERVER% %TESTFILEIDARG% %FILELIST%

:SIGN_REPORT

if "%ERRORLEVEL%"=="0" (
    @echo signed: %FILELIST%
) else (
    @echo %SIGNTOOL_EXE% : fatal error : Signing failed with %ERRORLEVEL% on %*
)
:END

endlocal & set RC=%ERRORLEVEL%
echo Sign.Cmd RC=%RC%
exit /B %RC%
