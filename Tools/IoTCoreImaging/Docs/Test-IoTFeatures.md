---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Test-IoTFeatures

## SYNOPSIS
Validates if all features specified in the specified product/config oeminputxml are defined.
This returns boolean true for success and false for failure.

## SYNTAX

```
Test-IoTFeatures [-Product] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
This command parses all the FM files specified in the product/config oeminputxml file and verifies if the feature ids specified in the oeminputfile are defined.
This also warns if developer feature ids or test feature ids used in a retail oeminputxml file.

## EXAMPLES

### EXAMPLE 1
```
$result = Test-IoTFeatures SampleA Retail
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
Together with Product parameter, this identifies the oeminputxml file to be processed.

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
This method is also invoked in the New-IoTFFUImage always.

## RELATED LINKS
