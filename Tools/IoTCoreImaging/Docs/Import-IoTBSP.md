---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Import-IoTBSP

## SYNOPSIS
Imports a BSP folder in to the current workspace from a source workspace or a source bsp directory or a source zip file.

## SYNTAX

```
Import-IoTBSP [-BSPName] <String> [[-Source] <String>] [<CommonParameters>]
```

## DESCRIPTION
Imports a BSP folder in to the current workspace from a source workspace or a source bsp directory or a source zip file.

## EXAMPLES

### EXAMPLE 1
```
Import-IoTBSP RPi2 C:\MyWorkspace
```

Imports RPi2 bsp from C:\MyWorkspace

### EXAMPLE 2
```
Import-IoTBSP  *
```

Imports all bsps from $env:SAMPLEWKS

### EXAMPLE 3
```
Import-IoTBSP MyBSP C:\MyBSPFolder
```

Imports MyBSP from C:\MyBSPFolder

### EXAMPLE 4
```
Import-IoTBSP BYTx64 C:\Downloads\BYT_Win10_IOT_Core_MR1_BSP_337014-003.zip
```

Imports BYTx64 from C:\Downloads\BYT_Win10_IOT_Core_MR1_BSP_337014-003.zip file

### EXAMPLE 5
```
Import-IoTBSP RPi2 C:\RPi_BSP.zip
```

Imports RPi2 from C:\RPi_BSP.zip

### EXAMPLE 6
```
Import-IoTBSP Sabre_iMX6Q_1GB C:\Temp\NXPBSP.zip
```

Imports Sabre_iMX6Q_1GB from C:\Temp\NXPBSP.zip

## PARAMETERS

### -BSPName
Mandatory parameter, specifying the BSP to import, wildcard supported.

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

### -Source
Optional parameter specifying the source workspace or source bsp directory or a source zip file.
Default is $env:SAMPLEWKS

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

## NOTES
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
