---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTAppxPackage

## SYNOPSIS
Adds an Appx package directory to the workspace and generates the required wm.xml and customizations.xml files

## SYNTAX

```
Add-IoTAppxPackage [-AppxFile] <String> [-StartupType] <String> [[-OutputName] <String>] [-SkipCert]
 [<CommonParameters>]
```

## DESCRIPTION
This command creates an appx directory in the Source-arch\packages folder and generates the wm.xml and customisations.xml file by processing the input appx/appxbundle file.
This also copies the appx files including the dependencies and the cert or the license file to the appx directory.
In addition, this also adds an appx specific feature id (APPX_AppxName) in the OEMFM.xml file.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTAppxPackage C:\MyApps\Sample1.Appx fga Appx.Sample
```

## PARAMETERS

### -AppxFile
Mandatory parameter, specifying the appx (or) appxbundle filename.

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

### -StartupType
Mandatory parameter, specifying the appx startup type, fga for foreground app, bgt for background task and none for no startup specification.
Default is none.

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
Optional parameter specifying the directory name (namespace.name format).
Default is Appx.\<appxname\>.

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

### -SkipCert
Optional switch parameter to skip processing of cert file .This copies the cert file to the directory but does not add the cert specification in the customizations.xml file.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See New-IoTCabPackage to build a cab file.

## RELATED LINKS

[Add-IoTDriverPackage](Add-IoTDriverPackage.md)
[Add-IoTCommonPackage](Add-IoTCommonPackage.md)
[New-IoTCabPackage](New-IoTCabPackage.md)