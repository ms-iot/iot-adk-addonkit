---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Export-IoTDeviceModel

## SYNOPSIS
Exports the DeviceModel XML file required to register the device in the Device Update Center portal.

## SYNTAX

```
Export-IoTDeviceModel [-Product] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates the IoTDeviceModel xml file with the required contents (SMBIOS and shipping versions).
this file can be found at the product directory with the name `IoTDeviceModel_<productname>.xml`

## EXAMPLES

### EXAMPLE 1
```
Export-IoTDeviceModel SampleA
```

## PARAMETERS

### -Product
Mandatory parameter identifying the Product

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
See also Import-IoTDUCConfig

## RELATED LINKS
