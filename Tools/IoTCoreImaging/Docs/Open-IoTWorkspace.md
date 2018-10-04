---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Open-IoTWorkspace

## SYNOPSIS
Opens the IoTWorkspace xml at the specified input directory and sets up the environment with those settings.

## SYNTAX

```
Open-IoTWorkspace [-WsXML] <String> [<CommonParameters>]
```

## DESCRIPTION
Opens the IoTWorkspace xml and sets up the environment with those settings.

## EXAMPLES

### EXAMPLE 1
```
Open-IoTWorkspace C:\MyIoTProject\IoTWorkspace.xml
```

## PARAMETERS

### -WsXML
Mandatory parameter, specifying the IoTWorkspace.xml file or the directory containing IoTWorkspace.xml file.

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
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
