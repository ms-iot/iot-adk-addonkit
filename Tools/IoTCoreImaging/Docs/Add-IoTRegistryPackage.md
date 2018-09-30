---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTRegistryPackage

## SYNOPSIS
Adds a registry package directory to the workspace and generates the required wm.xml file.

## SYNTAX

```
Add-IoTRegistryPackage [-OutputName] <String> [-RegKeys] <String[][]> [<CommonParameters>]
```

## DESCRIPTION
This command creates a registry package directory in the Common\packages folder and generates the wm.xml file. 
In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTRegistryPackage Registry.Settings
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

### -RegKeys
Mandatory parameter specifying the reg keys to be specified (array of arrays).
Each element should contain reg key, reg value , reg value type and reg value data in that order.
For just the keys with no value, the remaining fields can be $null.

```yaml
Type: String[][]
Parameter Sets: (All)
Aliases:

Required: True
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
See New-IoTCabPackage to build a cab file.

## RELATED LINKS
