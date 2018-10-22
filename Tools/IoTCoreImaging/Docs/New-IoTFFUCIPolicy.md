---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTFFUCIPolicy.md
schema: 2.0.0
---

# New-IoTFFUCIPolicy

## SYNOPSIS
This function scans the mounted FFU Main OS partition and creates a CI policy.

## SYNTAX

```
New-IoTFFUCIPolicy
```

## DESCRIPTION
This function scans the mounted FFU Main OS partition and creates a CI policy.
The FFU must be mounted before calling this function.
This creates an \`security\initialpolicy.xml\` in the same folder as the FFU.

## EXAMPLES

### EXAMPLE 1
```
New-IoTFFUCIPolicy
```

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
See also Mount-IoTFFUImage

## RELATED LINKS

[Mount-IoTFFUImage](Mount-IoTFFUImage.md)

