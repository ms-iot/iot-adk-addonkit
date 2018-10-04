---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Mount-IoTFFUImage

## SYNOPSIS
Mounts the specifed FFU, parses the device layout and assigns drive letters for the partitions with file system defined.

## SYNTAX

```
Mount-IoTFFUImage [-FFUName] <String> [<CommonParameters>]
```

## DESCRIPTION
Mounts the specifed FFU, parses the device layout and assigns drive letters for the partitions with file system defined.No other FFU must be mounted when this is called.

## EXAMPLES

### EXAMPLE 1
```
Mount-IoTFFUImage c:\MyTestImage.ffu
```

Mounts the MyTestImage.ffu and assigns free drive letter.

## PARAMETERS

### -FFUName
Name of the FFU to be mounted.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See also Unmount-IoTFFUImage

## RELATED LINKS
