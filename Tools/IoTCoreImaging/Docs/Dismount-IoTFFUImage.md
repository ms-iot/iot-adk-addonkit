---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Dismount-IoTFFUImage

## SYNOPSIS
Dismounts the mounted ffu image and saves it as a new ffu if an ffuname is specified.

## SYNTAX

```
Dismount-IoTFFUImage [[-FFUName] <String>] [<CommonParameters>]
```

## DESCRIPTION
Dismounts the mounted FFU image.
If ffuname is specified, the ffu is saved in that name.
If the ffuname is not specified, the mounted ffu is not saved.

## EXAMPLES

### EXAMPLE 1
```
Dismount-IoTFFUImage
```

Dismounts the mounted ffu without saving.

### EXAMPLE 2
```
Dismount-IoTFFUImage C:\MyNewImage.ffu
```

Dismounts and saves the mounted ffu as MyNewImage.ffu.

## PARAMETERS

### -FFUName
Optional FFU name to save the mounted FFU.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
See also Mount-IoTFFUImage

## RELATED LINKS
