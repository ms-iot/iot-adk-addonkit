---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTWMWriter

## SYNOPSIS
Factory method, returing the [IoTWMWriter](Classes/IoTWMWriter.md) class object used to write namespace.name.wm.xml file.

## SYNTAX

```
New-IoTWMWriter [-FileDir] <String> [-Namespace] <String> [[-Name] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Factory method, returing the [IoTWMWriter](Classes/IoTWMWriter.md) class object.

## EXAMPLES

### EXAMPLE 1
```Powershell
$wmwriter = New-IoTWMWriter C:\Test Custom Settings
$wmwriter.Start("MainOS")
$wmwriter.AddRegKeys("\`$(hklm.software)\Contoso\EmptyKey", $null)
$wmwriter.Finish()
```

## PARAMETERS

### -FileDir
Mandatory parameter, specifying the directory where the wm.xml file needs to be created.

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

### -Namespace
Mandatory parameter, specifying the namespace.

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

### -Name
Mandatory parameter, specifying the name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Mandatory parameter, specifying the name.```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This class is used in the Add-IoT* methods.

## RELATED LINKS
