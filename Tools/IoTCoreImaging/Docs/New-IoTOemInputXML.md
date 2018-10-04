---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTOemInputXML

## SYNOPSIS
Factory method to create a new object of class IoTOemInputXML

## SYNTAX

```
New-IoTOemInputXML [-InputXML] <String> [-Create] [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTOemInputXML

## EXAMPLES

### EXAMPLE 1
```
$obj = New-IoTOemInputXML C:\MyDir\TestOEMInput.xml -Create
```

## PARAMETERS

### -InputXML
Mandatory parameter, OemInput XML file to load

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
Optional switch parameter, to create the oeminput xml file if not present

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
See [IoTOemInputXML](Classes/IoTOemInputXML.md) for more details on the class.

## RELATED LINKS
