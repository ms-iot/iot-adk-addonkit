---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Export-IoTFFUAsWims

## SYNOPSIS
Extracts the mounted partitions as wim files

## SYNTAX

```
Export-IoTFFUAsWims [<CommonParameters>]
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See also Mount-IoTFFUImage

## RELATED LINKS
