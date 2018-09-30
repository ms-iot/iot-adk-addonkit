---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Copy-IoTBSP

## SYNOPSIS
Copies a BSP folder to the destination workspace from a source workspace or a source bsp directory.

## SYNTAX

```
Copy-IoTBSP [-Source] <String> [-Destination] <String> [-BSPName] <String> [<CommonParameters>]
```

## DESCRIPTION
Copies a BSP folder to the destination workspace from a source workspace.

## EXAMPLES

### EXAMPLE 1
```
Copy-IoTBSP C:\MyWorkspace $env:IOTWKSPACE RPi
```

Copies RPi BSP from C:\MyWorkspace to current workspace

### EXAMPLE 2
```
Copy-IoTBSP C:\MyBspDir C:\MyWorkspace MyBSP
```

Copies MyBSP from C:\MyBspDir to C:\MyWorkspace

## PARAMETERS

### -Source
Mandatory parameter specifying the source workspace or a source bsp directory.

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

### -Destination
Mandatory parameter specifying the destination workspace directory.

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

### -BSPName
Mandatory parameter, specifying the BSP name, wildcards supported.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
