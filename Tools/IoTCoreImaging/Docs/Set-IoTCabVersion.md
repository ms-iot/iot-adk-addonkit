---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Set-IoTCabVersion

## SYNOPSIS
Sets the version to be used in the Cab package creation.

## SYNTAX

```
Set-IoTCabVersion [-version] <String> [<CommonParameters>]
```

## DESCRIPTION
Sets the environment variable used for Cab package creation (Env:BSP_VERSION).
Also updates the version in the IoTWorkspace xml file.

## EXAMPLES

### EXAMPLE 1
```
Set-IoTCabVersion 10.0.1.0
```

## PARAMETERS

### -version
Specifies the version value to be set.
This version has to be a four part version number.

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
The alias for this is setversion

## RELATED LINKS
