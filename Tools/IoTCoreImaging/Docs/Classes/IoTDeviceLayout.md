# IoTDeviceLayout

## SHORT DESCRIPTION
Describes the IoTDeviceLayout Class

## LONG DESCRIPTION
DeviceLayout class provides methods to parse the device layout xml and assign drive letters for the file system partitions based on the host pc drives.


# Constructors
## IoTDeviceLayout(String FilePath)
Constructor for the class, requires the device layout xml file path. Throws an exception if the file is not found.

```powershell
[IoTDeviceLayout]::new([String]$FilePath)
```


# Properties
## DriveLetters
Hashtable storing the partition name with its assigned drive letter.

```yaml
Name: DriveLetters
Type: System.Collections.Hashtable
Hidden: False
Static: False
```

## FileName
Filename of the device layout xml.

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## FsPartitions
String array for file system partition information, stored in a csv format with the following values `Partition name,Drive letter,Partition id,File system,Partition type`.

```yaml
Name: FsPartitions
Type: String[]
Hidden: False
Static: False
```

## XmlDoc
XML document object for the device layout xml file.

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```


# Methods
## GenerateRecoveryScripts(String RecoveryPath)
This method creates the required recovery scripts used by the WinPE during the recovery process. This creates `setdrives.cmd`, `diskpart_assign.txt`, `diskpart_remove.txt`, `restore_junction.cmd` files.

```yaml
Name: GenerateRecoveryScripts
Return Type: Void
Hidden: False
Static: False
Definition: Void GenerateRecoveryScripts(String RecoveryPath)
```

## ParseDeviceLayout()
This method parses the xml file and populates the FsPartitions and DriveLetters.

```yaml
Name: ParseDeviceLayout
Return Type: Void
Hidden: False
Static: False
Definition: Void ParseDeviceLayout()
```

## ValidateDeviceLayout()
This method validates the device layout for various design aspects such as the partition type for EFIESP, filesytem for MMOS, partition size for MainOS etc.


```yaml
Name: ValidateDeviceLayout
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean ValidateDeviceLayout()
```


# EXAMPLES
Create a device layout object and parse the layout. Print out the assigned drive letters.
```Powershell
$dlobj = New-IoTDeviceLayout "$env:COMMON_DIR\Packages\DeviceLayout.GPT4GB\DeviceLayout.xml"
$dlobj.ParseDeviceLayout()
$dlobj.DriveLetters
```

# NOTE
This class is mainly used for recovery mechanism and also for mounting FFU files on the host machine. Assigning drive letters for the mounted FFU partitions using the device layout information makes it easy and consistent.

# TROUBLESHOOTING NOTE
None.


# SEE ALSO
The Factory method for this class is [New-IoTDeviceLayout](../New-IoTDeviceLayout.md)


# KEYWORDS

- IoTDeviceLayout
- IoT Core Device Layout
