---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTFIPPackage

## SYNOPSIS
Creates Feature Identifier Packages (FIP packages) for the given feature manifest files and updates the feature manifest files with the generated FIP packages.
Returns boolean true for success and false for failure.

## SYNTAX

```
New-IoTFIPPackage [[-BSP] <String>] [-IncludeOCP] [<CommonParameters>]
```

## DESCRIPTION
This command runs FeatureMerger.exe for the predefined FMList files in the workspace.
It processes by default the OEMFMList  file present in the Source-arch\Packages\ directory.
In addition, when the -IncludeOCP is specified it processes the OCPFMList present in the templates directory.
When the BSP parameter is defined, it processess the bspfmlist present in the source-arm\bsp\packages directory.
The updated FM files are stored in the build dir under MergedFM folder.

## EXAMPLES

### EXAMPLE 1
```
$result = New-IoTFIPPackage QCDB410C -IncludeOCP
```

Builds all three - OEM / BSP and OCP FM files.

### EXAMPLE 2
```
$result = New-IoTFIPPackage
```

Builds only the OEM FM files.

## PARAMETERS

### -BSP
Optional parameter to specify the bsp to be processed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeOCP
Optional parameter to specify inclusion of OCPFMList processing

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
All the packages referred in the FM files must be available before running this command.
In general there is no need to execute this command stand alone as this is invoked in the New-IoTFFUImage cmdlet.

## RELATED LINKS
