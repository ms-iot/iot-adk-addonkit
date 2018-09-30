---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Get-IoTProductFeatureIDs

## SYNOPSIS
Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace.

## SYNTAX

```
Get-IoTProductFeatureIDs [[-FeatureType] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace under MSPkgRoot tag.

## EXAMPLES

### EXAMPLE 1
```
Get-IoTProductFeatureIDs
```

Returns all feature IDs including Test/Retail.

### EXAMPLE 2
```
Get-IoTProductFeatureIDs Test
```

Returns the Test feature IDs only

## PARAMETERS

### -FeatureType
Optional parameter, with values: "Developer", "Test", "Retail", "Deprecated" and "All".
Default is "All" which is equal to Test + Retail features.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See also Get-IoTProductPackagesForFeature

## RELATED LINKS
