---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTFFUImage

## SYNOPSIS
Creates the IoT FFU image for the specified product / configuration.
Returns boolean true for success and false for failure.

## SYNTAX

```
New-IoTFFUImage [-Product] <String> [-Config] <String> [-Validate] [<CommonParameters>]
```

## DESCRIPTION
This command invokes Imageapp.exe to generate the Flash.ffu for the specified product/config oeminput xml file.
Before invoking the ImageApp, this command processes various product specific packages and also invokes New-IoTFIPPackage to generate the FIP packages.

## EXAMPLES

### EXAMPLE 1
```
$result = New-IoTFFUImage SampleA Test
```

### EXAMPLE 2
```
$result = New-IoTFFUImage SampleA Retail -Validate
```

## PARAMETERS

### -Product
Mandatory parameter identifying the Product directory

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

### -Config
Mandatory parameter identifying the config supported by the product.
Defined in the product settings.xml.
Together with Product parameter, this identifies the oeminputxml file to be processed.

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

### -Validate
Optional switch parameter to validate the presence of the required packages for the image creation and also verify if all binaries and packages are properly signed.

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
This command can take long time to complete in the order of few tens of minutes.

## RELATED LINKS
