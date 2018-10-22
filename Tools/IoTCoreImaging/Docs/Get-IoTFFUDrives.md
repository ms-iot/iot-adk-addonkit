---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Get-IoTFFUDrives.md
schema: 2.0.0
---

# Get-IoTFFUDrives

## SYNOPSIS
Returns a hashtable of the drive letters of the mounted partitions

## SYNTAX

```
Get-IoTFFUDrives
```

## DESCRIPTION
Returns a hashtable of the drive letters of the mounted file partitions of the FFU.
The FFU must be mounted before calling this method.

## EXAMPLES

### EXAMPLE 1
```
Get-IoTFFUDrives
```

## PARAMETERS

## INPUTS

### None
## OUTPUTS

### System.Hashtable
Hashtable of drive letters of the mounted partitions.
## NOTES
See also Mount-IoTFFUImage

## RELATED LINKS

[Mount-IoTFFUImage](Mount-IoTFFUImage.md)

