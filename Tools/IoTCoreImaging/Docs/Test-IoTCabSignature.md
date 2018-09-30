---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Test-IoTCabSignature

## SYNOPSIS
Checks if the cab file and its contents are properly signed.

## SYNTAX

```
Test-IoTCabSignature [-CabFile] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks if the cab file and its contents are properly signed.

## EXAMPLES

### EXAMPLE 1
```
$result = Test-IoTCabSignature C:\myfile.cab Retail
```

## PARAMETERS

### -CabFile
Mandatory parameter, the cab file to be inspected

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

### -Config
Mandatory parameter, specifing the Config.
Can be "Retail" or any other ("Test"/"Dev" etc)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Uses Test-IoTSignature cmdlet to validate the .cab file, and its contents - .cat.
.exe, .dll and .sys

## RELATED LINKS
