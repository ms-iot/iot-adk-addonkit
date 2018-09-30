---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Redo-IoTWorkspace

## SYNOPSIS
Updates an old iot-adk-addonkit folder with required xml files to make it a proper workspace.

## SYNTAX

```
Redo-IoTWorkspace [-DirName] <String> [<CommonParameters>]
```

## DESCRIPTION
Updates an old iot-adk-addonkit folder to a proper workspace.
- creates the IoTWorkspace.xml parsing the setoem.cmd / versioninfo.txt files.
- prompts to gather SMBIOS information for every product.
- fixes the wm.xml using ppkg files to point to correct path and also include the .cat files
- deletes old Custom.Cmd and Provisioning.Auto pkgs and copies the new versions to ProdPackages folder
- regenerates all driver packages to the new wm.xml

## EXAMPLES

### EXAMPLE 1
```
Redo-IoTWorkspace C:\iot-adk-addonkit
```

## PARAMETERS

### -DirName
{{Fill DirName Description}}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
