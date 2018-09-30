---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTWorkspace

## SYNOPSIS
Creates a new IoTWorkspace xml and the directory structure at the specified input directory.

## SYNTAX

```
New-IoTWorkspace [-DirName] <String> [-OemName] <String> [-Arch] <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a new IoTWorkspace xml and the directory structure at the specified input directory..

## EXAMPLES

### EXAMPLE 1
```
New-IoTWorkspace "C:\MyIoTProject" Contoso arm
```

## PARAMETERS

### -DirName
Mandatory parameter, specifying the directory for the workspace.

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

### -OemName
Mandatory parameter, specifying the OEMName for the workspace.

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

### -Arch
Mandatory parameter, specifying the architecture for the workspace.
Additional archs can be added if required using Add-IoTEnvironment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
