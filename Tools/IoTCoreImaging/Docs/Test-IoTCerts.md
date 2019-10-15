---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Test-IoTCerts.md
schema: 2.0.0
---

# Test-IoTCerts

## SYNOPSIS
Checks if the certs in the workspace folder are all valid.

## SYNTAX

```
Test-IoTCerts [<CommonParameters>]
```

## DESCRIPTION
Checks if the certs in the workspace folder are all valid.

## EXAMPLES

### EXAMPLE 1
```
$result = Test-IoTCerts
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Boolean
### True if the file is properly signed.
## NOTES
This verifies using the Test-Certificate.

## RELATED LINKS

[[Test-Certificate](https://docs.microsoft.com/powershell/module/pkiclient/test-certificate?view=win10-ps)]()

