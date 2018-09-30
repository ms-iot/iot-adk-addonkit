---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-IoTOEMPackage

## SYNOPSIS
Imports an OEM package in to the current workspace from a source workspace.

## SYNTAX

```
Import-IoTOEMPackage [-PkgName] <String> [[-SourceWkspace] <String>] [<CommonParameters>]
```

## DESCRIPTION
Imports an OEM package in to the current workspace from a source workspace and updates the corresponding FM file with the feature id.

## EXAMPLES

### EXAMPLE 1
```
Import-IoTOEMPackage Appx.MyApp C:\MyWorkspace
```

Imports Appx.MyApp package from C:\MyWorkspace

### EXAMPLE 2
```
Import-IoTOEMPackage *
```

Imports all the packages in the sample workspace that comes along with tooling.
($env:SAMPLEWKS)

## PARAMETERS

### -PkgName
Mandatory parameter, specifying the package name, typically of namespace.name format. Wild cards supported.

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
