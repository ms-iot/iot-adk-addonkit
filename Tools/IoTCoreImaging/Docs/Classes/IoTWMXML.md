# IoTWMXML

## SHORT DESCRIPTION
Describes the IoTWMXML Class

## LONG DESCRIPTION
This class helps in creating and managing a windows manifest file.


# Constructors
## IoTWMXML(String inputxml, Boolean Create)
Constructor, the wm.xml file is created with inputxml name if the Create flag is specified.

```powershell
[IoTWMXML]::new([String]$inputxml, [Boolean]$Create)
```


# Properties
## FileName
Name of the file created with full path info. Filename should be dot separated text - like namespace.name.wm.xml

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## XmlDoc
The XML document corresponding to the FileName

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```

## xmlns
Namespace used for the windows manifest file

```yaml
Name: xmlns
Type: String
Hidden: False
Static: True
```


# Methods
## AddFile(String destpath, String srcname, String destname)
Adds a file entry for the given destpath, srcname and destname.

```yaml
Name: AddFile
Return Type: Void
Hidden: False
Static: False
Definition: Void AddFile(String destpath, String srcname, String destname)
```

## AddRegistry(String keyName, String regValue, String regType, String regData)
Adds a registry entry for the given parameters if not already present.

```yaml
Name: AddRegistry
Return Type: Void
Hidden: False
Static: False
Definition: Void AddRegistry(String keyName, String regValue, String regType, String regData)
```

## CreateWMXML()
Internal method to create a new wm xml file.

```yaml
Name: CreateWMXML
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void CreateWMXML()
```

## RemoveFile(String srcname)
Removes the file entry with the srcname

```yaml
Name: RemoveFile
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveFile(String srcname)
```

## RemoveRegistry(String keyName, String regValue)
Removes the registry key/value entry, if the regValue is present only the value entry is removed and not the key. To remove all regvalues under the key and the key itself, pass $null for regValue.

```yaml
Name: RemoveRegistry
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveRegistry(String keyName, String regValue)
```

## SetTargetPartition(String partition)
Sets the targetparition value.

```yaml
Name: SetTargetPartition
Return Type: Void
Hidden: False
Static: False
Definition: Void SetTargetPartition(String partition)
```


# EXAMPLES
A sample use of the class
```powershell
    $wmfile = New-IoTWMXML C:\Test\File.Settings.wm.xml -Create
    $wmfile.AddFile("`$(runtime.bootDrive)\Test","Myfile.txt","MyfileonDevice.txt")
    $wmfile.AddRegistry("HKLM\Test","MyValue","REG_SZ","01")
```

# NOTE


# TROUBLESHOOTING NOTE

# SEE ALSO
* [New-IoTWMWriter](../New-IoTWMWriter.md)


# KEYWORDS
