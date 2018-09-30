---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTCommonPackage

## SYNOPSIS
Adds a common(generic) package directory to the workspace and generates the required wm.xml file.

## SYNTAX

```
Add-IoTCommonPackage [-OutputName] <String> [<CommonParameters>]
```

## DESCRIPTION
This command creates a common (generic) package directory in the Common\packages folder and generates the wm.xml file. 
In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTCommonPackage Custom.Settings
```

## PARAMETERS

### -OutputName
Mandatory parameter specifying the directory name (namespace.name format).

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
See New-IoTCabPackage to build a cab file.

## RELATED LINKS

[Add-IoTDriverPackage](Add-IoTDriverPackage.md)
[Add-IoTAppxPackage](Add-IoTAppxPackage.md)
[New-IoTCabPackage](New-IoTCabPackage.md)