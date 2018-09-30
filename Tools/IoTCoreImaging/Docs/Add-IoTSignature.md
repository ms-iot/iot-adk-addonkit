---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTSignature

## SYNOPSIS
Signs the files with the certificate selected via Set-IoTSignature

## SYNTAX

```
Add-IoTSignature [-Path] <String> [[-Type] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Signs the files with the certificate selected via Set-IoTSignature

## EXAMPLES

### EXAMPLE 1
```
Add-IoTSignature C:\QCSBSP
```

### EXAMPLE 2
```
Add-IoTSignature C:\QCSBSP *.sys,*.dll
```

## PARAMETERS

### -Path
Path for the files to be signed.
Can be a single file or a directory of files

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

### -Type
Optional parameter indicating the file type(s) to be signed.
If omitted, all file types (*.exe,*.dll.*.sys,*.cat) will be signed.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
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

## RELATED LINKS
