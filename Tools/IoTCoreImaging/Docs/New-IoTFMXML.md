---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTFMXML.md
schema: 2.0.0
---

# New-IoTFMXML

## SYNOPSIS
Factory method to create a new object of class IoTFMXML

## SYNTAX

```
New-IoTFMXML [-InputXML] <String> [-Create] [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTFMXML

## EXAMPLES

### Example 1
```Powershell
$fmobj = New-IoTFMXML $env:PKGSRC_DIR\OEMFM.xml"
```

Loads the OEMFM.xml file

## PARAMETERS

### -InputXML
Mandatory parameter, feature manifest XML file to load

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

### -Create
Optional switch parameter, to create the feature manifest xml file if not present

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### IoTFMXML
## NOTES
See IoTFMXML class for more details.

## RELATED LINKS

[IoTFMXML](./Classes/IoTFMXML.md)

