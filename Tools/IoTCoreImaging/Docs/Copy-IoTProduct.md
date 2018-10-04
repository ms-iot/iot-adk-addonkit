---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# Copy-IoTProduct

## SYNOPSIS
Copies a product folder to the destination workspace from a source workspace.

## SYNTAX

```
Copy-IoTProduct [-Source] <String> [-Destination] <String> [-ProductName] <String> [<CommonParameters>]
```

## DESCRIPTION
Copies a product folder to the destination workspace from a source workspace.

## EXAMPLES

### EXAMPLE 1
```
Copy-IoTProduct $env:SAMPLEWKS $env:IOTWKSPACE SampleA
```

Copies SampleA from SampleWkspace to current workspace

### EXAMPLE 2
```
Copy-IoTProduct $env:SAMPLEWKS $env:IOTWKSPACE *
```

Copies all products from SampleWkspace to current workspace

## PARAMETERS

### -Source
Mandatory parameter specifying the source workspace directory.

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

### -Destination
Mandatory parameter specifying the destination workspace directory.

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

### -ProductName
Mandatory parameter, specifying the Product, supports wild cards

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
See Add-IoT* and Import-IoT* methods.

## RELATED LINKS
