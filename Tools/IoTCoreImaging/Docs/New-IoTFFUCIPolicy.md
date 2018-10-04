---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTFFUCIPolicy

## SYNOPSIS
This function scans the mounted FFU Main OS partition and creates a CI policy.

## SYNTAX

```
New-IoTFFUCIPolicy [<CommonParameters>]
```

## DESCRIPTION
This function scans the mounted FFU Main OS partition and creates a CI policy. The FFU must be mounted before calling this function. This creates an `security\initialpolicy.xml` in the same folder as the FFU.

## EXAMPLES

### Example 1
```
New-IoTFFUCIPolicy
```

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See also Mount-IoTFFUImage

## RELATED LINKS
