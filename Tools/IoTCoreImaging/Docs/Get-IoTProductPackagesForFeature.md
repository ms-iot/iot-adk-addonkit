---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Get-IoTProductPackagesForFeature

## SYNOPSIS
Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace.

## SYNTAX

```
Get-IoTProductPackagesForFeature [-FeatureID] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace under MSPkgRoot tag.

## EXAMPLES

### EXAMPLE 1
```
Get-IoTProductPackagesForFeature IOT_BERTHA
```

Returns the list of packages included for IOT_BERTHA feature.

## PARAMETERS

### -FeatureID
A Valid Feature ID defined in the Windows 10 IoT Core OS.

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
See also Get-IoTProductFeatureIDs

## RELATED LINKS
