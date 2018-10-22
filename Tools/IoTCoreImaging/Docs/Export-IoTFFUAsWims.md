---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Export-IoTFFUAsWims.md
schema: 2.0.0
---

# Export-IoTFFUAsWims

## SYNOPSIS
Extracts the mounted partitions as wim files

## SYNTAX

```
Export-IoTFFUAsWims
```

## DESCRIPTION
This function exports the mounted partitions (EFIESP, MainOS and Data) as wim files and stores them in the same directory as the ffu.
Note that the FFU must be mounted before calling this function.

## EXAMPLES

### EXAMPLE 1
```
Export-IoTFFUAsWims
```

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
See also Mount-IoTFFUImage

## RELATED LINKS

[Mount-IoTFFUImage](Mount-IoTFFUImage.md)

