---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTBitLocker.md
schema: 2.0.0
---

# Add-IoTBitLocker

## SYNOPSIS
Generates the Bitlocker package (Security.BitLocker) contents based on the workspace specifications.

## SYNTAX

```
Add-IoTBitLocker
```

## DESCRIPTION
Generates the Bitlocker package (Security.BitLocker) contents based on the workspace specifications.
You will need to import the required certificates into the workspace before using this command.
For Bitlocker, DataRecoveryAgent certificate is mandatory.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTBitLocker
```

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
See Import-IoTCertificate before using this function.

## RELATED LINKS

[Import-IoTCertificate](Import-IoTCertificate.md)

