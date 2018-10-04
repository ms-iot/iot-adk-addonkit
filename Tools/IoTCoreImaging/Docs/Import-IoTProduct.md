---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-IoTProduct

## SYNOPSIS
Imports a product folder in to the current workspace from a source workspace.

## SYNTAX

```
Import-IoTProduct [-ProductName] <String> [[-SourceWkspace] <String>] [<CommonParameters>]
```

## DESCRIPTION
Imports a product folder in to the current workspace from a source workspace.

## EXAMPLES

### EXAMPLE 1
```
Import-IoTProduct SampleA C:\MyWorkspace
```

Imports SampleA product from C:\MyWorkspace

### EXAMPLE 2
```
Import-IoTProduct *
```

Imports all products from $env:SAMPLEWKS

## PARAMETERS

### -ProductName
Mandatory parameter, specifying the Product, wildcards supported.

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

### -SourceWkspace
Optional parameter specifying the source workspace directory.
Default is $env:SAMPLEWKS

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $env:SAMPLEWKS
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
