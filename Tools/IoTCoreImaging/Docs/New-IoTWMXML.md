---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTWMXML

## SYNOPSIS
Factory method to create a new object of class IoTWMXML

## SYNTAX

```
New-IoTWMXML [-InputXML] <String> [-Create] [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTWMXML

## EXAMPLES

### EXAMPLE 1
```
$obj = New-IoTWMXML C:\MyDir\samplewm.xml -Create
```

## PARAMETERS

### -InputXML
Mandatory parameter, WM XML file to load

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
Optional switch parameter, to create the wm xml file if not present

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

## OUTPUTS

## NOTES
See \[IoTWMXML\](Classes/IoTWMXML.md) for more details on the class.

## RELATED LINKS
