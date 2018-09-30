@echo off
REM set SIGNTOOL_OEM_SIGN=/s my /i "Issuer" /n "Subject" /ac "CrossCertRoot" /fd SHA256
REM Issuer        : Issuer of the Certificate ( see Certificate -> Details -> Issuer )
REM Subject       : Subject in the certificate ( see Certificate -> Details -> Subject)
REM CrossCertRoot : Microsoft supplied Cross Certificate Root (see Cross-Certificate List in https://msdn.microsoft.com/library/windows/hardware/dn170454(v=vs.85).aspx )

REM for HAL certificate 
REM set SIGNTOOL_OEM_SIGN_HAL=/s my /i "Issuer" /n "Subject" /ac "CrossCertRoot" /fd SHA256

set SIGN_OEM=1
set SIGN_WITH_TIMESTAMP=1

SET SIGNTOOL_OEM_SIGN=/s my /i "Symantec Class 3 SHA256 Code Signing CA" /n "Microsoft" /ac "%TOOLS_DIR%\VeriSign Class 3 Public Primary Certification Authority - G5.cer" /fd SHA256
