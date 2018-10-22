---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTProductSettingsXML.md
schema: 2.0.0
---

# New-IoTProductSettingsXML

## SYNOPSIS
Factory method to create a new object of class IoTProductSettingsXML

## SYNTAX

### None (Default)
```
New-IoTProductSettingsXML [-InputXML] <String> [<CommonParameters>]
```

### ConstructionArgs
```
New-IoTProductSettingsXML [-InputXML] <String> [-Create] [-oemName] <String> [-familyName] <String>
 [-skuNumber] <String> [-baseboardManufacturer] <String> [-baseboardProduct] <String> [[-pkgDir] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTProductSettingsXML

## EXAMPLES

### EXAMPLE 1
```
$obj = New-IoTProductSettingsXML $env:SRC_DIR\Products\SampleA\SampleASettings.xml -Create:$false OEMName ProdFamily ProdSKU1 Fabrikam RPiCustom2
```

## PARAMETERS

### -InputXML
Mandatory parameter, Product settings XML file to load

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

### -Create
Optional switch parameter, to create the product settings xml file if not present

```yaml
Type: SwitchParameter
Parameter Sets: ConstructionArgs
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -oemName
Mandatory parameter, System Manufacturer Name for the SMBIOS

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -familyName
Mandatory parameter, product family name for the SMBIOS

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -skuNumber
Mandatory parameter, SKU name for the SMBIOS

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -baseboardManufacturer
Mandatory parameter, baseboard Manufacturere for the SMBIOS

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -baseboardProduct
Mandatory parameter, baseboard Product for the SMBIOS

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -pkgDir
Optional parameter, BSP package path for the product build configs

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: False
Position: 8
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

### IoTProductSettingsXML
## NOTES
See IoTProductSettingsXML class for more details.

## RELATED LINKS

[IoTProductSettingsXML](./Classes/IoTProductSettingsXML.md)

