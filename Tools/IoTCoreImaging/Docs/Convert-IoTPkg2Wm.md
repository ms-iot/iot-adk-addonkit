---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Convert-IoTPkg2Wm

## SYNOPSIS
Converts the existing pkg.xml files to wm.xml files.

## SYNTAX

```
Convert-IoTPkg2Wm [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Converts the existing pkg.xml files to wm.xml files with same name and at the same location and deletes the old pkg.xml files

## EXAMPLES

### EXAMPLE 1
```
$result = Convert-IoTPkg2Wm C:\MyDir
```

## PARAMETERS

### -Path
Mandatory parameter specifying the path for the pkg.xml files

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
Since the pkg.xml files are deleted, recommend to take a backup before proceeding with this function.

## RELATED LINKS
