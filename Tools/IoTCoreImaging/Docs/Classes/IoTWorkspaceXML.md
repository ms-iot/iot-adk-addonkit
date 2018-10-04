# IoTWorkspaceXML

## SHORT DESCRIPTION
Describes the IoTWorkspaceXML Class

## LONG DESCRIPTION
This class helps in managing the Workspace XML configuration.


# Constructors
## IoTWorkspaceXML(String wsxml, Boolean Create, String OemName)
Constructor. If the file is not present and the Create flag is false, it throws an exception.

```powershell
[IoTWorkspaceXML]::new([String]$wsxml, [Boolean]$Create, [string]$OemName)
```


# Properties
## ConfigKeys
This is the array of keys supported in the GetConfig/SetConfig methods.

```yaml
Name: ConfigKeys
Type: String[]
Hidden: False
Static: True
```

## EnvArchs
This is the array of supported architectures. Values are `x86`, `x64`, and `arm`.

```yaml
Name: EnvArchs
Type: String[]
Hidden: False
Static: True
```

## EnvConfigKeys
This is the array of keys supported in the GetEnvConfig/SetEnvConfig methods.

```yaml
Name: EnvConfigKeys
Type: String[]
Hidden: False
Static: True
```

## FileName
Filename of the workspace xml

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## XmlDoc
XML document object for the workspace xml

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```


# Methods
## AddCertificate(String certfile, String certnode, Boolean istest)
Adds the certificate to the requested cert node. Also copies the cert to the workspace certs folder.

```yaml
Name: AddCertificate
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean AddCertificate(String certfile, String certnode, Boolean istest)
```


## AddEnv(String Arch)
Adds an new Arch environment settings and creates the directory structure and files required for this new Arch. If the Arch is already present, it returns false.

```yaml
Name: AddEnv
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean AddEnv(String Arch)
```

## CreateWSXML(String oemName)
Internal method called from the constructor to create a new workspace xml file.

```yaml
Name: CreateWSXML
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void CreateWSXML(String oemName)
```

## GetBSPPkgDir()
Returns the BSPPkgDir value for the current env.

```yaml
Name: GetBSPPkgDir
Return Type: String
Hidden: False
Static: False
Definition: String GetBSPPkgDir()
```

## GetConfig()
Returns an hashtable of config elements with the values. See ConfigKeys for the list of keys returned.

```yaml
Name: GetConfig
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetConfig()
```

## GetCurrentEnv()
Returns the current selected env.

```yaml
Name: GetCurrentEnv
Return Type: String
Hidden: False
Static: False
Definition: String GetCurrentEnv()
```

## GetEnvConfig(String arch)
Returns a hashtable of current env settings.

```yaml
Name: GetEnvConfig
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetEnvConfig(String arch)
```

## GetVersion()
Returns the current version for current env.

```yaml
Name: GetVersion
Return Type: String
Hidden: False
Static: False
Definition: String GetVersion()
```

## Save()
Saves the xml object with the same filename.

```yaml
Name: Save
Return Type: Void
Hidden: False
Static: False
Definition: Void Save()
```

## SetBSPPkgDir(String bsppkgdir)
Sets BSPPkgDir for the current env.

```yaml
Name: SetBSPPkgDir
Return Type: Void
Hidden: False
Static: False
Definition: Void SetBSPPkgDir(String bsppkgdir)
```

## SetConfig(System.Collections.Hashtable config)
Sets the current config elements with the hashtable values provided. See ConfigKeys for the supported keys.

```yaml
Name: SetConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void SetConfig(System.Collections.Hashtable config)
```

## SetCurrentEnv(String arch)
Sets the current env value.

```yaml
Name: SetCurrentEnv
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean SetCurrentEnv(String arch)
```

## SetEnvConfig(String arch, System.Collections.Hashtable config)
Sets the env config elements with the hashtable values. See EnvConfigKeys for supported keys.

```yaml
Name: SetEnvConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void SetEnvConfig(String arch, System.Collections.Hashtable config)
```

## SetVersion(String version)
Sets the version for the current env.

```yaml
Name: SetVersion
Return Type: Void
Hidden: False
Static: False
Definition: Void SetVersion(String version)
```


# EXAMPLES
This class is used internally. See IoTWorkspace methods for its usage.

# NOTE
The Factory method for this class is not exported.

# TROUBLESHOOTING NOTE
None

# SEE ALSO
 See Workspace related methods
- [New-IoTWorkspace](../New-IoTWorkspace.md)
- [Open-IoTWorkspace](../Open-IoTWorkspace.md)

# KEYWORDS

- IoT Core Workspace XML
