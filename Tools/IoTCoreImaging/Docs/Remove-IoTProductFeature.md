---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Remove-IoTProductFeature

## SYNOPSIS
Removes feature id from the specified product's oeminput xml file.

## SYNTAX

```
Remove-IoTProductFeature [-Product] <String> [-Config] <String> [-FeatureID] <String> [<CommonParameters>]
```

## DESCRIPTION
Removes feature id (oem feature or Microsoft feature) from the specified product's oeminput xml file for the given configuration.

## EXAMPLES

### EXAMPLE 1
```
Remove-IoTProductFeature SampleA Test CUSTOM_CMD
```

Removes CUSTOM_CMD feature to the SampleA TestOEMInput.xml file.

### EXAMPLE 2
```
Remove-IoTProductFeature SampleA All CUSTOM_CMD
```

Removes CUSTOM_CMD feature to the SampleA TestOEMInput.xml and RetailOEMInput.xml files.

## PARAMETERS

### -Product
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

### -Config
Mandatory paramter, specify the config.
Supported values : Test,Retail and All

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

### -FeatureID
Mandatory parameter, specify the featureId to be removed.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Add-IoTProductFeature also.

## RELATED LINKS
