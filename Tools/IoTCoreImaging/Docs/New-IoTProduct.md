---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTProduct.md
schema: 2.0.0
---

# New-IoTProduct

## SYNOPSIS
Factory method to create a new object of class IoTProduct

## SYNTAX

```
New-IoTProduct [-Product] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTProduct

## EXAMPLES

### Example 1
```Powershell
$prod = New-IoTProduct SampleA Retail
$prod.ValidatePackages()
```

Creates a product object and validates if all packages are present and properly signed.

## PARAMETERS

### -Product
Mandatory parameter, Product Name.

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

### -Config
Mandatory parameter, Product configuration supported in the product.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### IoTProduct
## NOTES
See IoTProduct class for more details.

## RELATED LINKS

[IoTProduct](./Classes/IoTProduct.md)

