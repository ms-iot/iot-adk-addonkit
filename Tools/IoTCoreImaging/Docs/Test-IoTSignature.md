---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Test-IoTSignature

## SYNOPSIS
Checks if the file is properly signed.

## SYNTAX

```
Test-IoTSignature [-FileName] <String> [-Config] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks if the file is properly signed.
For Retail Config, it checks if the signature is rooted to Microsoft or a cross rooted cert.

## EXAMPLES

### EXAMPLE 1
```
$result = Test-IoTSignature C:\myfile.dll Retail
```

## PARAMETERS

### -FileName
Mandatory parameter, the file to be inspected

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
Mandatory parameter, specifying the Config.
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
This verifies using the signtool.
\[ signtool verify /v /pa FileName \]

## RELATED LINKS
