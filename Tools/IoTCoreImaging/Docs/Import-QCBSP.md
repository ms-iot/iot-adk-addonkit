---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-QCBSP

## SYNOPSIS
Import QC BSP into your workspace and update the bsp files as required by the latest tools.

## SYNTAX

```
Import-QCBSP [-BSPZipFile] <String> [-BSPPkgDir] <String> [-ImportBSP] [<CommonParameters>]
```

## DESCRIPTION
Import QC BSP into your workspace and update the bsp files as required by the latest tools.

## EXAMPLES

### EXAMPLE 1
```
Import-QCBSP C:\Temp\db410c_bsp.zip C:\QCBSP -ImportBSP
```

## PARAMETERS

### -BSPZipFile
Mandatory parameter, BSP Zip file from QC.

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

### -BSPPkgDir
Mandatory parameter, Location where to extract the required BSP cab files.

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

### -ImportBSP
Optional switch parameter, to import the QCDB410C BSP.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
You will need to download the QC BSP from the QC website first before using this method

## RELATED LINKS
