---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTFMXML

## SYNOPSIS
Factory method to create a new object of class [IoTFMXML](Classes/IoTFMXML.md).

## SYNTAX

```
New-IoTFMXML [-InputXML] <String> [-Create] [<CommonParameters>]
```

## DESCRIPTION
Factory method to create a new object of class [IoTFMXML](Classes/IoTFMXML.md).

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See [IoTFMXML](Classes/IoTFMXML.md) for more details on the class.

## RELATED LINKS
