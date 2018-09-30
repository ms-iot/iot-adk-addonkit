---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Redo-IoTCabSignature

## SYNOPSIS
Resigns the cab file and its contents / cat files with the certificate set in the environment.

## SYNTAX

```
Redo-IoTCabSignature [-Path] <String> [-DestinationPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Resigns the cab file and its contents / cat files with the certificate set in the environment.
This is useful to sign the cabs from Silicon Vendors with OEM Cross certificate.

## EXAMPLES

### EXAMPLE 1
```
Redo-IoTCabSignature C:\QCSBSP C:\QCBSP-Signed
```

## PARAMETERS

### -Path
Path containing the source cab files

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

### -DestinationPath
Path where the resigned cabs are stored.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
