---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Set-IoTSignature

## SYNOPSIS
Sets the signing related env vars with the cert information provided.

## SYNTAX

```
Set-IoTSignature [[-SignParam] <String>] [<CommonParameters>]
```

## DESCRIPTION
Sets the signing related env vars with the cert information provided.

## EXAMPLES

### EXAMPLE 1
```
Set-IoTSignature "/a /s my /i `"Windows OEM Intermediate 2017 (TEST ONLY)`" /n `"Windows OEM Test Cert 2017 (TEST ONLY)`" /fd SHA256"
```

## PARAMETERS

### -SignParam
The parameters of the sign tool to select the certificate to sign.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Code signing requirements for more details.

## RELATED LINKS
