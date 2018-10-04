---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Set-IoTEnvironment

## SYNOPSIS
Sets the environment variables as per requested architecture

## SYNTAX

```
Set-IoTEnvironment [[-arch] <String>] [<CommonParameters>]
```

## DESCRIPTION
Reads the IoTWorkspace xml file and configures all the environment variables as per the requested architecture. 
This also exports the environment settings as SetEnvVars.cmd.

## EXAMPLES

### EXAMPLE 1
```
Set-IoTEnvironment arm
```

## PARAMETERS

### -arch
Specifies the required architecture.
Supported values are arm,x86 and x64.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Default
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
The alias for this is setenv

## RELATED LINKS
