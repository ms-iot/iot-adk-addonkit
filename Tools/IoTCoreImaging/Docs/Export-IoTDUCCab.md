---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Export-IoTDUCCab

## SYNOPSIS
Exports the update cab file required to upload on the Device Update Center

## SYNTAX

```
Export-IoTDUCCab [-Product] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates the single large cab containing all required cabs and signs this large cab with the EV cert registered with the Device Update Center.
This cab can be uploaded directly to the Device Update Center portal.
The output will be available in the build directory \`$env:BUILD_DIR\\\<Product\>\\\<Config\>\$env:BSP_VERSION\\\`

## EXAMPLES

### EXAMPLE 1
```
Export-IoTDUCCab SampleA Retail
```

## PARAMETERS

### -Product
Mandatory parameter identifying the Product directory

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
Mandatory parameter identifying the config supported by the product.
Defined in the product settings.xml.
Together with Product parameter, this identifies the build files to be processed.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See also Import-IoTDUCConfig

## RELATED LINKS
