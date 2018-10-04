---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Add-IoTProvisioningPackage

## SYNOPSIS
Adds a provisioning package directory to the workspace and generates the required wm.xml file, customizations.xml file and the icdproject file.

## SYNTAX

```
Add-IoTProvisioningPackage [-OutputName] <String> [[-PpkgFile] <String>] [<CommonParameters>]
```

## DESCRIPTION
This command creates a provisioning package directory in the Common\packages folder and generates the wm.xml file,customizations.xml file and the icdproject file. 
In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml.

## EXAMPLES

### EXAMPLE 1
```
Add-IoTProvisioningPackage Custom.Settings
```

## PARAMETERS

### -OutputName
Mandatory parameter specifying the directory name (namespace.name format).

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

### -PpkgFile
Optional parameter specifying the ppkg file from the ICD output directory.(C:\Users\<user>\Documents\Windows Imaging and Configuration Designer (WICD)).```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Undefined
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See New-IoTProvisioningPackage to build a provisioning package.

## RELATED LINKS
