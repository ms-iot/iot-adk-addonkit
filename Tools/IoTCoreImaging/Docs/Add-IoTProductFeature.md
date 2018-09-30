---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTProductFeature

## SYNOPSIS
Adds feature id to the specified product's oeminput xml file.

## SYNTAX

```
Add-IoTProductFeature [-Product] <String> [-Config] <String> [-FeatureID] <String> [-OEM] [<CommonParameters>]
```

## DESCRIPTION
Adds feature id (oem feature or Microsoft feature) to the specified product's oeminput xml file for the given configuration.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTProductFeature SampleA Test CUSTOM_CMD OEM
```

Adds CUSTOM_CMD feature to the SampleA TestOEMInput.xml file.

### EXAMPLE 2
```
Add-IoTProductFeature SampleA All CUSTOM_CMD OEM
```

Adds CUSTOM_CMD feature to the SampleA TestOEMInput.xml and RetailOEMInput.xml files.

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
Mandatory parameter, specify the featureId to be added.

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

### -OEM
Optional switch parameter, to specify that the featuretype is OEM.
Default featuretype is Microsoft

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Remove-IoTProductFeature also.

## RELATED LINKS
