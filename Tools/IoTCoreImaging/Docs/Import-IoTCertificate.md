---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-IoTCertificate

## SYNOPSIS
Imports an certificate and adds to the Workspace security specification.

## SYNTAX

```
Import-IoTCertificate [-CertFile] <String> [-CertType] <String> [-Test] [<CommonParameters>]
```

## DESCRIPTION
Imports an certificate and adds to the Workspace security specification.
For Secure boot functionality, it is mandatory to specify the PlatformKey and the KeyExchangeKey.
For Bitlocker functionality, DataRecoveryAgent is required.
For Device guard functionality, Update is mandatory.
You will also need the following certs in the local cert store of the build machine (either installed directly or on a smart card).
For signing purpose
 - Certificate with private key corresponding to PlatformKey
 - Certificate with private key corresponding to KeyExchangeKey 
 For testing purposes, you can use the sample pfx files provided in the sample workspace and install them by double clicking on them.

## EXAMPLES

### EXAMPLE 1
```
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-UEFISB.cer KeyExchangeKey
```

Imports OEM-UEFISB.cer as a KeyExchangeKey certificate for secure boot policy.
The cert is also copied to the workspace certs folder.

### EXAMPLE 2
```
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-PK.cer PlatformKey
```

Imports OEM-PK.cer as a Platform key certificate for secure boot policy.
The cert is also copied to the workspace certs folder.

### EXAMPLE 3
```
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-DRA.cer DataRecoveryAgent
```

Imports OEM-DRA.cer as a DataRecoveryAgent certificate for bitlocker policy.
The cert is also copied to the workspace certs folder.

### EXAMPLE 4
```
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-PAUTH.cer Update
```

Imports OEM-PAUTH.cer as a update certificate for device guard policy.
The cert is also copied to the workspace certs folder.

### EXAMPLE 5
```
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-UMCI.cer User
```

Imports OEM-UMCI.cer as a user mode code signing certificate for device guard.
The cert is also copied to the workspace certs folder.

## PARAMETERS

### -CertFile
Mandatory parameter, specifying the package name, typically of namespace.name format.
Wild cards supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertType
Mandatory parameter specifying the cert type.
The supported values are 
for secure boot  : "PlatformKey","KeyExchangeKey","Database"
for bit locker   : "DataRecoveryAgent"
for device guard : "Update","User","Kernel"
See IoTWorkspace.xml for the cert definitions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Test
Switch parameter specifying if the certificate is test certificate

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
