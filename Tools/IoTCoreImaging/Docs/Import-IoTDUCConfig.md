---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-IoTDUCConfig

## SYNOPSIS
Imports the Device Update Center Configuration files into the product directory

## SYNTAX

```
Import-IoTDUCConfig [-Product] <String> [-ZipFile] <String> [<CommonParameters>]
```

## DESCRIPTION
Imports the Device Update Center Configuration files into the product directory.
This also updates all the oeminputfiles with inclusion of the OCPUpdateFM.xml and CUS_DEVICE_INFO feature and removes IOT_GENERIC_POP feature.

## EXAMPLES

### EXAMPLE 1
```
Import-IoTDUCConfig SampleA "C:\Users\myacc\Downloads\CUSConfig.zip"
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

### -ZipFile
Mandatory parameter, the path of the CusConfig.zip file downloaded from the Device Update Center

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
See also Export-IoTDUCCab

## RELATED LINKS
