---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTDriverPackage

## SYNOPSIS
Adds a driver package directory to the workspace and generates the required wm.xml file.

## SYNTAX

```
Add-IoTDriverPackage [-InfFile] <String> [[-OutputName] <String>] [[-BSPName] <String>] [<CommonParameters>]
```

## DESCRIPTION
This command creates a driver package directory in the Source-arch\packages folder and generates the wm.xml file and copies all files in the inf directory including the inf file.
If BSPName is specified, then it creates the package directory in Source-arch\BSP\\\<BSPName\>\Packages directory.
In addition to that, it also adds a driver specific feature id (DRV_InfName) in the OEMFM.xml ( or in the BSPFM.xml if BSPName specified).

## EXAMPLES

### EXAMPLE 1
```
Add-IoTDriverPackage C:\Test\gpiodrv.inf Drivers.GPIO
```

Creates Drivers.GPIO in Source-arch\packages folder.

### EXAMPLE 2
```
Add-IoTDriverPackage C:\Test\gpiodrv.inf Drivers.GPIO RPi2
```

Creates Drivers.GPIO in Source-arch\BSP\RPi2\packages folder

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
Optional parameter specifying the directory name (namespace.name format).
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

### -BSPName
Optional parameter specifying the BSP. If this is specified, the driver directory will be under the BSP folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See New-IoTCabPackage to build a cab file.

## RELATED LINKS

[Add-IoTCommonPackage](Add-IoTCommonPackage.md)
[Add-IoTAppxPackage](Add-IoTAppxPackage.md)
[New-IoTCabPackage](New-IoTCabPackage.md)