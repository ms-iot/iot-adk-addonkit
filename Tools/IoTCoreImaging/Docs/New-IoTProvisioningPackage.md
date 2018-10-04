---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTProvisioningPackage

## SYNOPSIS
Creates a .ppkg file from the customizations.xml input file.
Returns a boolean indicating success or failure.

## SYNTAX

```
New-IoTProvisioningPackage [-File] <String> [-Output] <String> [<CommonParameters>]
```

## DESCRIPTION
This command invokes icd.exe command line to process the provided settings.xml file and generates the ppkg.

## EXAMPLES

### EXAMPLE 1
```
$result = New-IoTProvisioningPackage C:\Sample\Customizations.xml C:\Build\Myfile.ppkg
```

## PARAMETERS

### -File
Input settings/customizations.xml file

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

### -Output
Output file name, with full path.
If path is not included, it creates the ppkg in the same dir as the input xml file.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Install ADK with Windows Customization Designer tool to use this functionality.

## RELATED LINKS
