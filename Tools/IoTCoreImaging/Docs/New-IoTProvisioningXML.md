---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTProvisioningXML

## SYNOPSIS
Factory method to create a new object of class [IoTProvisioningXML](Classes/IoTProvisioningXML.md)

## SYNTAX

```
New-IoTProvisioningXML [-InputXML] <String> [-Create] [<CommonParameters>]
```

## DESCRIPTION
Factory method to create a new object of class [IoTProvisioningXML](Classes/IoTProvisioningXML.md)

## EXAMPLES

### Example 1
```Powershell
$provxml = New-IoTProvisioningXML C:\Mydir\customisations.xml
```

Loads the provisioning xml C:\Mydir\customisations.xml

## PARAMETERS

### -InputXML
Mandatory parameter, Provisioning XML file to load
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
Optional switch parameter, to create the Provisioning xml file if not present

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
See [IoTProvisioningXML](Classes/IoTProvisioningXML.md) for more details on the class.

## RELATED LINKS
