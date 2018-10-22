---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTInf2Cab.md
schema: 2.0.0
---

# New-IoTInf2Cab

## SYNOPSIS
Creates a cab file for the given inf.

## SYNTAX

```
New-IoTInf2Cab [-InfFile] <String> [[-OutputName] <String>] [<CommonParameters>]
```

## DESCRIPTION
This command creates the wm.xml file in the same location as the inf file and builds a cab file.
This does not add the driver to the workspace.
See Add-IoTDriverPackage for adding driver to workspace.

## EXAMPLES

### EXAMPLE 1
```
New-IoTInf2Cab C:\Test\gpiodrv.inf Drivers.GPIO
```

Creates Oemname.Drivers.GPIO.cab in the build\\\<arch\>\pkg directory.

## PARAMETERS

### -InfFile
Mandatory parameter, specifying the inf file.

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

### -OutputName
Optional parameter specifying the package name (namespace.name format).
Default is Drivers.\<InfName\>.

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

## OUTPUTS

## NOTES
See Add-IoTDriverPackage to add driver to workspace and New-IoTCabPackage to build a cab file.

## RELATED LINKS

[Add-IoTDriverPackage](Add-IoTDriverPackage.md)

