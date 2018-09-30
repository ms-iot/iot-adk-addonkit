---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Get-IoTWorkspaceProducts

## SYNOPSIS
Returns the list of product names in the workspace.

## SYNTAX

```
Get-IoTWorkspaceProducts [[-SourceWkspace] <String>] [<CommonParameters>]
```

## DESCRIPTION
Returns the list of product names in the specified workspace or from the $env:SAMPLEWKS.
The workspace's architecture is used to determine which architecture to search.

## EXAMPLES

### EXAMPLE 1
```
Get-IoTWorkspaceProducts
```

Returns the products from the default workspace.

### EXAMPLE 2
```
Get-IoTWorkspaceProducts C:\IoTWorkSpaces\Workspace
```

Returns the products from the specified workspace

## PARAMETERS

### -SourceWkspace
Optional parameter, specifies the workspace to search.
Default is from the $env:SAMPLEWKS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:SAMPLEWKS
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
