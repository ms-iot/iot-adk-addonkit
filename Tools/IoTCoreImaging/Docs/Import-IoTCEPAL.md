---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Import-IoTCEPAL.md
schema: 2.0.0
---

# Import-IoTCEPAL

## SYNOPSIS
Import a flat release directory and prepare for packaging into IoT Core.

**Preview:** See [CE Migration](https://aka.ms/cemigration) for more details.

## SYNTAX

```
Import-IoTCEPAL [-FlatReleaseDirectory] <String> [<CommonParameters>]
```

## DESCRIPTION
This command copies $FlatReleaseDirectory\CEPAL_PKG into the workspace and generates CEPALFMFileList.xml.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -FlatReleaseDirectory
The flat release directory where to source CEPAL.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
