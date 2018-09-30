---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Set-IoTRetailSign

## SYNOPSIS
Sets the signing certificate to the retail cert or test cert.

## SYNTAX

```
Set-IoTRetailSign [-Mode] <String> [<CommonParameters>]
```

## DESCRIPTION
Sets the environment variable used for code signing to the retail certificate (specified in Workspace xml as RetailSignToolParam when the mode parameter is on.
When its off, it sets to the test certificate.

## EXAMPLES

### EXAMPLE 1
```
Set-IoTRetailSign On
```

## PARAMETERS

### -Mode
On/Off, specifies if retail certificate to be set or not.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The alias for this is retailsign

## RELATED LINKS
