---
external help file: IoTCoreImaging-help.xml
Module Name: IoTCoreImaging
online version:
schema: 2.0.0
---

# New-IoTCabPackage

## SYNOPSIS
Creates a cab package file for the specified wm.xml file or the wm.xml files in the specified directory. Returns a boolean indicating success or failure.

## SYNTAX

```
New-IoTCabPackage [-PkgFile] <String> [[-Product] <String>] [<CommonParameters>]
```

## DESCRIPTION
This command runs the pkggen.exe with the appropriate parameters to generate a .cab file from the given wm.xml file,  or the wm.xml files present in the directory. It also supports special switches to build all packages in the workspace(-All) and to delete all previously built packages (-Clean).  The generated cab files are available in build directory $env:PKGBLD_DIR

## EXAMPLES

### Example 1
```Powershell
$result = New-IoTCabPackage All
```

Builds all packages

### Example 2
```Powershell
$result = New-IoTCabPackage Clean
```

Cleans up the build directory and deletes all .cab files.

### Example 3
```Powershell
$result = New-IoTCabPackage C:\Sample\abc.wm.xml
```

Builds abc.wm.xml file.

### Example 4
```Powershell
$result = New-IoTCabPackage Registry.Version
```

Builds wm.xml files in the directory Registry.Version

### Example 5
```Powershell
$result = New-IoTCabPackage C:\Sample
```

Builds wm.xml files in the directory C:\Sample

### Example 6
```Powershell
$result = New-IoTCabPackage $env:COMMON_DIR\ProdPackages SampleA
```

Builds wm.xml files in the directory COMMON_DIR\ProdPackages with the Product parameter SampleA.

## PARAMETERS

### -PkgFile
Accepts the following inputs
    - All     : Special keyword, builds all packages in CommonDir and Source-arch dirs
    - Clean   : Special keyword, deletes all cab files from the build directory
    - .wm.xml : Fully qualified file path for the .wm.xml file (even outside the workspace)
    - pkgname : Directory name that is present under CommonDir or Source-arch dir within the workspace
    - fulldir : Fully qualified directory path (even outside the workspace)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Product
Optional parameter specifying the product directory to be used for fetching product specific contents.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
