# IoTFFU

## SHORT DESCRIPTION
Describes the IoTFFU Class

## LONG DESCRIPTION
This class provides functions to mount/unmount FFU and perform various actions on the mounted FFU such as CIPolicy scan. This class is implemented as a singleton, to ensure that there is only one mounted ffu at a time.


# Constructors
## IoTFFU()
Constructor. Allows only one instance.

```powershell
[IoTFFU]::new()
```


# Properties
## DeviceLayout
[IoTDeviceLayout](IoTDeviceLayout.md) object associated with the mounted FFU.

```yaml
Name: DeviceLayout
Type: IoTDeviceLayout
Hidden: False
Static: False
```


## DiskDrive
Stores the disk drive of the mounted ffu.

```yaml
Name: DiskDrive
Type: String
Hidden: False
Static: False
```

## FFUObject
Singleton FFU object of this class.

```yaml
Name: FFUObject
Type: IoTFFU
Hidden: False
Static: True
```

## FileDir
FFU File location (directory).

```yaml
Name: FileDir
Type: String
Hidden: False
Static: False
```

## FileName
FFU File name.

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## MountPath
Mount path of the mounted FFU file.

```yaml
Name: MountPath
Type: String
Hidden: False
Static: False
```


# Methods
## AssignDriveLetters()
Assigns drive letters to the mounted partitions based on the device layout FsPartitions information.

```yaml
Name: AssignDriveLetters
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void AssignDriveLetters()
```

## Dismount(String filename)
Dismounts the mounted FFU.

```yaml
Name: Dismount
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean Dismount(String filename)
```

## ExtractWims()
Extracts the EFIESP,MainOS and Data partitions of the mounted FFU as wim files and stores in the same ffu directory.

```yaml
Name: ExtractWims
Return Type: Void
Hidden: False
Static: False
Definition: Void ExtractWims()
```

## GetInstance()
Singleton method to get access to the instance.

```yaml
Name: GetInstance
Return Type: IoTFFU
Hidden: False
Static: True
Definition: static IoTFFU GetInstance()
```

## Initialize(String ffufile)
Initializes the static FFU object with the ffufile.

```yaml
Name: Initialize
Return Type: Void
Hidden: False
Static: False
Definition: Void Initialize(String ffufile)
```

## IsMounted()
Query method to check if ffu is mounted.

```yaml
Name: IsMounted
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsMounted()
```

## Mount()
Method to mount the FFU file. This method also parses the device layout in the mounted ffu and assigns the drive letters using AssignDriveLetters method.

```yaml
Name: Mount
Return Type: Void
Hidden: False
Static: False
Definition: Void Mount()
```

## RemoveDriveLetters()
Removes the assigned drive letters from the mounted partition.

```yaml
Name: RemoveDriveLetters
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void RemoveDriveLetters()
```

## ScanNewCIPolicy()
This method invokes the [New-CIPolicy](https://docs.microsoft.com/powershell/module/configci/new-cipolicy?view=win10-ps) cmdlet to create the initial policy by scanning the main os partition of the mounted ffu. The result is stored in the `<ffudir>\security\initialpolicy.xml` file.

```yaml
Name: ScanNewCIPolicy
Return Type: Void
Hidden: False
Static: False
Definition: Void ScanNewCIPolicy()
```


# EXAMPLES
A Sample use of this class
```Powershell
    $ffuobj = [IoTFFU]::GetInstance()
    if ($ffuobj.IsMounted()) {
        $ffuobj.Dismount()
    }
    $ffuobj.Initialize("C:\MyImage.ffu")
    $ffuobj.Mount()
    $ffuobj.DeviceLayout.DriveLetters
    $ffuobj.ExtractWims()
    $ffuobj.Dismount()
```

# NOTE
Use the exported functions listed in the *See Also* section to work with FFU directly.

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [Mount-IoTFFUImage](../Mount-IoTFFUImage.md)
* [Dismount-IoTFFUImage](../Dismount-IoTFFUImage.md)
* [Export-IoTFFUAsWims](../Export-IoTFFUAsWims.md)
* [New-IoTFFUCIPolicy](../New-IoTFFUCIPolicy.md)
* [Get-IoTFFUDrives](../Get-IoTFFUDrives.md)

# KEYWORDS

- IoT Core FFU


