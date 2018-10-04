---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTSecureBoot

## SYNOPSIS
Generates the secure boot package (Security.SecureBoot) contents based on the workspace specifications.
If Test is specified, then it includes test certificates from the specification.

## SYNTAX

```
Add-IoTSecureBoot [-Test] [<CommonParameters>]
```

## DESCRIPTION
Generates the secure boot package (Security.SecureBoot) contents based on the workspace specifications.
If Test is specified, then it includes test certificates from the specification and generates Security.SecureBootTest package.
You will need to import the required certificates into the workspace before using this command.
For Secure Boot, PlatformKey and KeyExchangeKey certificates are mandatory.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTSecureBoot -Test
```

## PARAMETERS

### -Test
Switch parameter, to include test certificates in the secure boot package.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
See Import-IoTCertificate before using this function.

## RELATED LINKS
