---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery
schema: 2.0.0
---

# Test-IoTRecoveryImage

## SYNOPSIS
Validates if the recovery wim files are proper in the recovery ffu

## SYNTAX

```
Test-IoTRecoveryImage [[-product] <String>] [[-config] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function mounts the recovery ffu, uses the wim files in the recovery partition and performs the recovery process on the mounted partitions to validate if the wim files are proper.

## EXAMPLES

### EXAMPLE 1
```
Test-IoTRecoveryImage ProductA Test
```

### EXAMPLE 2
```
Test-IoTRecoveryImage ProductA Test
```

### EXAMPLE 3
```
Test-IoTRecoveryImage -product ProductA -config Test
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Returns an boolean value

## NOTES

## RELATED LINKS

[https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery](https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery)

