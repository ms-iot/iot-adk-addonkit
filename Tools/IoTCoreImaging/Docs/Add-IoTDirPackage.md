---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version: https://github.com/ms-iot/iot-adk-addonkit/blob/master/Tools/IoTCoreImaging/Docs/Add-IoTDirPackage.md
schema: 2.0.0
---

# Add-IoTDirPackage

## SYNOPSIS
Adds the directory contents into a IoT file package definition.

## SYNTAX

```
Add-IoTDirPackage [-InputDir] <String> [-TargetDir] <String> [-OutputName] <String> [-Common]
 [<CommonParameters>]
```

## DESCRIPTION
Adds the directory contents  into a IoT file package definition.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTDirPackage C:\Temp\MyFiles \MyFiles Files.MyFiles
```

## PARAMETERS

### -InputDir
Mandatory parameter, specifying the directory contents to be added.

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

### -TargetDir
Mandatory parameter specifying the directory name on the target device relative to the rood dir(C:\\).

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

### -OutputName
Mandatory parameter specifying the directory name (namespace.name format) for importing.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Common
Optional switch parameter, if defined the package is created in the common folder.

```yaml
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Enables easy add multiple files with their folder structure.

## RELATED LINKS

* [Add-IoTFilePackage](Add-IoTFilePackage.md)
* [Add-IoTZipPackage](Add-IoTZipPackage.md)
* [New-IoTCabPackage](New-IoTCabPackage.md)