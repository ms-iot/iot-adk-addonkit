---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTEnvironment

## SYNOPSIS
Adds a new architecture to the workspace

## SYNTAX

```
Add-IoTEnvironment [-Arch] <String> [<CommonParameters>]
```

## DESCRIPTION
Adds new architecture to the workspace and creates the required template directories.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTEnvironment arm
```

## PARAMETERS

### -Arch
Specifies the required architecture.
Supported values are arm,arm64,x86 and x64.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The alias for this is addenv

## RELATED LINKS
