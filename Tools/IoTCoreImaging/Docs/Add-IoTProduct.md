---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTProduct

## SYNOPSIS
Generates a new product directory under Source-arch\Products\.

## SYNTAX

```
Add-IoTProduct [-ProductName] <String> [-BSPName] <String> [-OemName] <String> [-FamilyName] <String>
 [-SkuNumber] <String> [-BaseboardManufacturer] <String> [-BaseboardProduct] <String> [[-PkgDir] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Generates a new product directory under Source-arch\Products\ based on the OEMInputSamples specified in the BSP directory Source-arch\BSP\\\<BSPName\>\OEMInputSamples

## EXAMPLES

### EXAMPLE 1
```
Add-IoTProduct SampleA RPi2 OEMName ProdFamily ProdSKU1 Fabrikam RPiCustom2
```

## PARAMETERS

### -ProductName
Mandatory parameter, specify the product name.

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

### -BSPName
Mandatory paramter, specify the BSP used in the product.

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

### -OemName
Mandatory parameter, specify the OEM name for the SMBIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FamilyName
Mandatory parameter, specify the Family name for the SMBIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkuNumber
Mandatory parameter, specify the SkuNumber for the SMBIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseboardManufacturer
Mandatory parameter, specify the BaseboardManufacturer for the SMBIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseboardProduct
Mandatory parameter, specify the BaseboardProduct for the SMBIOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PkgDir
Optional parameter, specify the BSP package path for the build configurations.

```yaml
Type: String
Parameter Sets: (All)
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

## OUTPUTS

## NOTES
See BuildFFU for creating FFU image for a given product.

## RELATED LINKS

[New-IoTFFUImage](New-IoTFFUImage.md)