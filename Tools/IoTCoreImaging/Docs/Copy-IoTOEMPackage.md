---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Copy-IoTOEMPackage

## SYNOPSIS
Copies an OEM package to the destination workspace from a source workspace.

## SYNTAX

```
Copy-IoTOEMPackage [-Source] <String> [-Destination] <String> [-PkgName] <String> [<CommonParameters>]
```

## DESCRIPTION
Copies an OEM package to the destination workspace from a source workspace and updates the corresponding FM file with the feature id.

## EXAMPLES

### EXAMPLE 1
```
Copy-IoTOEMPackage $env:SAMPLEWKS $env:IOTWKSPACE Appx.MyApp
```

Copies the Appx.MyApp package from $env:SAMPLEWKS to current workspace.

### EXAMPLE 2
```
Copy-IoTOEMPackage $env:SAMPLEWKS C:\DestWkspace *
```

Copies all packages from $env:SAMPLEWKS to DestWkspace

## PARAMETERS

### -Source
Mandatory parameter specifying the source workspace directory.

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

### -PkgName
Mandatory parameter, specifying the package name, typically of namespace.name format.
Wild cards supported.

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
