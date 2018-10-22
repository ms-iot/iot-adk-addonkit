---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/New-IoTDeviceLayout.md
schema: 2.0.0
---

# New-IoTDeviceLayout

## SYNOPSIS
Factory method to create a new object of class IoTDeviceLayout

## SYNTAX

```
New-IoTDeviceLayout [-FilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
This method creates a object of class IoTDeviceLayout

## EXAMPLES

### EXAMPLE 1
```Powershell
$dlobj = New-IoTDeviceLayout "$env:COMMON_DIR\Packages\DeviceLayout.GPT4GB\DeviceLayout.xml"
$dlobj.ParseDeviceLayout()
$dlobj.DriveLetters
```

## PARAMETERS

### -FilePath
Mandatory parameter, filename for the devicelayout

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### IoTDeviceLayout
## NOTES
See IoTDeviceLayout class for more details.

## RELATED LINKS

[IoTDeviceLayout](./Classes/IoTDeviceLayout.md)

