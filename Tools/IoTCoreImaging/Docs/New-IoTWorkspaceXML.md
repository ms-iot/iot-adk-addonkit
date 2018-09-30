---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTWorkspaceXML

## SYNOPSIS
Creates a new IoTWorkspaceXML object

## SYNTAX

### None (Default)
```
New-IoTWorkspaceXML [-File] <String> [<CommonParameters>]
```

### ConstructionArgs
```
New-IoTWorkspaceXML [-File] <String> [-Create] [-OemName] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a new IoTWorkspaceXML object from the File input file.
If the file is not present and Create switch is defined, a new IoTWorkspace xml is created with the default values.

## EXAMPLES

### EXAMPLE 1
```
$mywkspacexml = New-IoTWorkspaceXML C:\iot-adk-addonkit\IoTWorkspace.xml
```

### EXAMPLE 2
```
$mywkspacexml = New-IoTWorkspaceXML C:\iot-adk-addonkit\IoTWorkspace.xml -Create
```

## PARAMETERS

### -File
The IoTWorkspace xml file to open or create.

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
Switch parameter to indicate creation of new file.
If the file is already present, it opens the existing file.

```yaml
Type: SwitchParameter
Parameter Sets: ConstructionArgs
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -OemName
{{Fill OemName Description}}

```yaml
Type: String
Parameter Sets: ConstructionArgs
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
