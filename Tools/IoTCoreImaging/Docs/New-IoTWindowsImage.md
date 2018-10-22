---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTWindowsImage.md
schema: 2.0.0
---

# New-IoTWindowsImage

## SYNOPSIS
Builds a WinPE image with relevant drivers and recovery files

## SYNTAX

```
New-IoTWindowsImage [[-product] <String>] [[-config] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function copies the arch specific winpe.wim and adds bsp specific drivers and recovery files and stores them as a product specific winpe.wim file

## EXAMPLES

### EXAMPLE 1
```
New-IoTWindowsImage ProductA Test
```

### EXAMPLE 2
```
New-IoTWindowsImage -product ProductA -config Test
```

## PARAMETERS

### -product
Specify the product name

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

### -config
Specify the config to load ( retail/test )

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Boolean
True if the customised winpe is successfully created.
## NOTES

## RELATED LINKS

[Add Recovery](https://docs.microsoft.com/windows-hardware/manufacture/iot/recovery-mechanism)

