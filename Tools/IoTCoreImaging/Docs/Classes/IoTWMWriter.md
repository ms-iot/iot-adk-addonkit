# IoTWMWriter

## SHORT DESCRIPTION
Describes the IoTWMWriter Class

## LONG DESCRIPTION
This is a class that helps in constructing a Windows Manifest xml file (.wm.xml)


# Constructors
## IoTWMWriter(String filedir, String namespace, String name, System.Management.Automation.SwitchParameter force)
Constructor, the wm.xml file is created at `$filedir\$namespace.$name.wm.xml`

```powershell
[IoTWMWriter]::new([String]$filedir, [String]$namespace, [String]$name, [System.Management.Automation.SwitchParameter]$force)
```


# Properties
## FileDir
The Directory where the xml file is created

```yaml
Name: FileDir
Type: String
Hidden: False
Static: False
```

## Filename
Name of the file created

```yaml
Name: Filename
Type: String
Hidden: True
Static: False
```

## IsWritingStarted
Flag indicating if the writing session is started.

```yaml
Name: IsWritingStarted
Type: Boolean
Hidden: True
Static: False
```

## Name
Name of the component, specified in the wm.xml file.

```yaml
Name: Name
Type: String
Hidden: False
Static: False
```

## Namespace
Namespaceof the component, specified in the wm.xml file.

```yaml
Name: Namespace
Type: String
Hidden: False
Static: False
```

## NestedSection
String indicating which nested section is being written currently. Values are `drivers`, `files`, `regKeys`.

```yaml
Name: NestedSection
Type: String
Hidden: True
Static: False
```

## SkipLegacyName
Flag to skip the setting of LegacyName. Default is false i.e. LegacyName is not skipped.

```yaml
Name: SkipLegacyName
Type: Boolean
Hidden: False
Static: False
```

## WmWriter
XML Text Writer object used for the xml writing process.

```yaml
Name: WmWriter
Type: System.Xml.XmlTextWriter
Hidden: False
Static: False
```


# Methods
## AddComment(String comment)
Adds comment to the xml.

```yaml
Name: AddComment
Return Type: Void
Hidden: False
Static: False
Definition: Void AddComment(String comment)
```

## AddDriver(String inffile)
Adds a driver specification for the provided inffile.

```yaml
Name: AddDriver
Return Type: Void
Hidden: False
Static: False
Definition: Void AddDriver(String inffile)
```

## AddFiles(String destinationDir, String source, String name)
Adds a file specification for the provided file name with its source and destination values.

```yaml
Name: AddFiles
Return Type: Void
Hidden: False
Static: False
Definition: Void AddFiles(String destinationDir, String source, String name)
```

## AddRegKeys(String keyName, String[][] regvalue)
Adds a registry key specification based on the specified reg keyname and value. The RegValue is an array of array of strings with the following values (`valuename`,`value type`, `value text` ). If the RegValue is null, it just creates the key.

```yaml
Name: AddRegKeys
Return Type: Void
Hidden: False
Static: False
Definition: Void AddRegKeys(String keyName, String[][] regvalue)
```

## AddRegKeyValue(String keyName, String regValue, String regValueType, String regValueData)
Adds a registry key specification based on the specified reg keyname and value. If the RegValue is null, it just creates the key.

```yaml
Name: AddRegKeyValue
Return Type: Void
Hidden: False
Static: False
Definition: Void AddRegKeyValue(String keyName, String regValue, String regValueType, String regValueData)
```

## Finish()
Method indicating the completion of writing, writes the xml closing tags and saves the xml document.

```yaml
Name: Finish
Return Type: Void
Hidden: False
Static: False
Definition: Void Finish()
```

## Start(String oemname, String partition)
Similar to the Start method above, additionally you can specify the oemname field. By default the oemname is defined as a environment variable `$(OEMNAME)`.

```yaml
Name: Start
Return Type: Void
Hidden: False
Static: False
Definition: Void Start(String oemname, String partition)
```


## Start(String partition)
Method indicating the start of the xml writing. The Partition string is used for the target parititon field. The values supported are `MainOS` , `EFIESP`, `Data`.

```yaml
Name: Start
Return Type: Void
Hidden: False
Static: False
Definition: Void Start(String partition)
```

# EXAMPLES
A sample code creating an driver file, registry file package.
```Powershell
# Create a registry wm.xml file
    $wmwriter = New-IoTWMWriter C:\Temp Registry Test
    $wmwriter.Start($null) # uses MainOS as default
    $wmwriter.AddComment("Sample registry file")
    $regkeyvals = @(("StringValue", "REG_SZ", "Test string"), ("DWordValue", "REG_DWORD", "0x12AB34CD"))
    $wmwriter.AddRegKeys("`$(hklm.software)\`$(OEMNAME)\Test", $regkeyvals)
    $wmwriter.AddRegKeys("`$(hklm.software)\`$(OEMNAME)\EmptyKey", $null)
    $wmwriter.Finish()
# Create a driver wm.xml file
    $wmwriter = New-IoTWMWriter C:\Temp Driver Sample
    $wmwriter.Start($null)
    $wmwriter.AddDriver("C:\Driver.inf")
    $wmwriter.Finish()
```

# NOTE
This class only supports files, registry and driver addition. Does not support other constructs in the wm.xml schema.

# TROUBLESHOOTING NOTE
None

# SEE ALSO
The following commands use this class.
- [Add-IoTAppxPackage](../Add-IoTAppxPackage.md)
- [Add-IoTDriverPackage](../Add-IoTDriverPackage.md)
- [Add-IoTCommonPackage](../Add-IoTCommonPackage.md)

# KEYWORDS

- IoT Core WM Writer
