---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTBSP

## SYNOPSIS
Generates a BSP directory under Source-arch\BSP\ using a BSP directory template.

## SYNTAX

```
Add-IoTBSP [-BSPName] <String> [<CommonParameters>]
```

## DESCRIPTION
Generates a BSP directory under Source-arch\BSP\ using a BSP directory template.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTBSP MyRPi
```

## PARAMETERS

### -BSPName
Mandatory paramter, specifying the BSP name.

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
See Add-IoTProduct for creating new product directory.

## RELATED LINKS

[Add-IoTProduct](Add-IoTProduct.md)
[New-IoTCabPackage](New-IoTCabPackage.md)
