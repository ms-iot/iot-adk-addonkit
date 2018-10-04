---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTDeviceGuard

## SYNOPSIS
Generates the device guard package (Security.DeviceGuard) contents based on the workspace specifications.

## SYNTAX

```
Add-IoTDeviceGuard [-Test] [<CommonParameters>]
```

## DESCRIPTION
Generates the device guard package (Security.DeviceGuard) contents based on the workspace specifications.
If Test is specified, then it includes test certificates from the specification and generates Security.DeviceGuardTest package.
You will need to import the required certificates into the workspace before using this command.
For Device Guard, Update certificate is mandatory.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTDeviceGuard -Test
```

## PARAMETERS

### -Test
Switch parameter, to include test certificates in the device guard package.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
For validating the device guard policy, you can as well scan the built ffu using New-IoTFFUCIPolicy and compare the policy files.
See Import-IoTCertificate before using this function.

## RELATED LINKS
