---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Test-IoTPackages

## SYNOPSIS
Validates if all packages required for the specified product/config image creation are available and properly signed.
This returns boolean true for success and false for failure.

## SYNTAX

```
Test-IoTPackages [-Product] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
This command parses all the FM files specified in the product/config oeminputxml file and identifies the packages required for the image creation.
With the required package list, it checks the presence of the .cab file and validates the signature of the cab file and its contents.

## EXAMPLES

### EXAMPLE 1
```
$result = Test-IoTPackages SampleA Retail
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
This method is also invoked in the New-IoTFFUImage if -Validate switch is specified.

## RELATED LINKS
