---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery
schema: 2.0.0
---

# New-IoTRecoveryImage

## SYNOPSIS
Creates recovery ffu from a regular ffu

## SYNTAX

```
New-IoTRecoveryImage [[-product] <String>] [[-config] <String>] [[-wimmode] <String>] [[-wimdir] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function mounts the regular ffu, extracts the required wim files and populates the MMOS (recovery )\`
partition with the required files and saves the resultant ffu as Flash_Recovery.ffu

## EXAMPLES

### EXAMPLE 1
```
New-IoTRecoveryImage ProductA Test
```

### EXAMPLE 2
```
New-IoTRecoveryImage ProductA Test Import C:\wimfiles
```

### EXAMPLE 3
```
New-IoTRecoveryImage -product ProductA -config Test -wimmode Import -wimdir C:\wimfiles
```

## PARAMETERS

### -product
Product name

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

### -config
Config to load ( retail/test )

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -wimmode
Optional, the mode Import/Export

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

### -wimdir
The directory for the wim files.
Mandatory when wimmode is specified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None, function doesnt return anything. Generates the wim files and ffu file.

## NOTES

## RELATED LINKS

[https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery](https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery)

