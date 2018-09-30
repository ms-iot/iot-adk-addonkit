# IoTProvisioningXML

## SHORT DESCRIPTION
Describes the IoTProvisioningXML Class

## LONG DESCRIPTION
This class helps in managing the provisioning XML configurations (customizations.xml).


# Constructors
## IoTProvisioningXML(String provxml, Boolean Create)
Constructor, creates the IoTProvisioningXML object and initialises with the provxml file contents. If Create flag is specified, then it creates a new file if it doesnt already exist.

```powershell
[IoTProvisioningXML]::new([String]$provxml, [Boolean]$Create)
```


# Properties
## ConfigKeys
This is the array of keys supported in the GetPackageConfig/SetPackageConfig methods.

```yaml
Name: ConfigKeys
Type: String[]
Hidden: False
Static: True
```

## FileName
Filename of the provisioning xml

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## XmlDoc
XML document object for the provisioning xml

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```

## xmlns
Namespace used for Provisioning.

```yaml
Name: xmlns
Type: String
Hidden: False
Static: True
```


# Methods
## AddPolicy(String group, String name, String value)
Adds a policy specification to the provisioning xml.

```yaml
Name: AddPolicy
Return Type: Void
Hidden: False
Static: False
Definition: Void AddPolicy(String group, String name, String value)
```

## AddRootCertificate(String certfile)
Adds root certificate specification with the certfile information.

```yaml
Name: AddRootCertificate
Return Type: Void
Hidden: False
Static: False
Definition: Void AddRootCertificate(String certfile)
```

## AddStartupSettings(String AppName, String AppType)
Adds Startup settings specification for the given app. The AppType supported are `fga` and `bgt`.

```yaml
Name: AddStartupSettings
Return Type: Void
Hidden: False
Static: False
Definition: Void AddStartupSettings(String AppName, String AppType)
```

## AddTrustedProvCertificate(String certfile)
Adds Trusted Provisioner certificate with the certfile information.

```yaml
Name: AddTrustedProvCertificate
Return Type: Void
Hidden: False
Static: False
Definition: Void AddTrustedProvCertificate(String certfile)
```


## AddUniversalAppInstall(String FamilyName, String AppName, String[] Dependency, String LicenseId, String Licensefile)
Adds an universal app install specification for the given values.

```yaml
Name: AddUniversalAppInstall
Return Type: Void
Hidden: False
Static: False
Definition: Void AddUniversalAppInstall(String FamilyName, String AppName, String[] Dependency, String LicenseId, String Licensefile)
```

## CreateICDProject()
Creates the icdproj.xml based on the ID/Name specified in the customisations.xml. Enables editing of the Customisations.xml using the ICD.exe User interface.

```yaml
Name: CreateICDProject
Return Type: Void
Hidden: False
Static: False
Definition: Void CreateICDProject()
```


## CreateProvXML()
Internal method called from the constructor to create a new provisioning xml file.

```yaml
Name: CreateProvXML
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void CreateProvXML()
```

## GetPackageConfig()
Returns an hashtable of config elements with the values. See ConfigKeys for the list of keys returned.

```yaml
Name: GetPackageConfig
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetPackageConfig()
```

## IncrementVersion()
Increments version and saves the xml

```yaml
Name: IncrementVersion
Return Type: Void
Hidden: False
Static: False
Definition: Void IncrementVersion()
```

## RemoveRootCertificate(String certname)
Removes Root certificate specification for the certname if present.

```yaml
Name: RemoveRootCertificate
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveRootCertificate(String certname)
```

## RemoveTrustedProvCertificate(String certname)
Removes Trusted Provisioner certificate for the certname if present.

```yaml
Name: RemoveTrustedProvCertificate
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveTrustedProvCertificate(String certname)
```


## SetPackageConfig(System.Collections.Hashtable config)
Sets the current config elements with the hashtable values provided. See ConfigKeys for the supported keys.

```yaml
Name: SetPackageConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void SetPackageConfig(System.Collections.Hashtable config)
```

## SetVersion(String version)
Sets the version number provided.

```yaml
Name: SetVersion
Return Type: Void
Hidden: False
Static: False
Definition: Void SetVersion(String version)
```


# EXAMPLES
A Sample use of this class
```powershell
    $provxml = New-IoTProvisioningXML "$env:SRC_DIR\Products\SampleA\prov\customisations.xml"
    $provxml.AddPolicy("ApplicationManagement", "AllowAllTrustedApps", "Yes")
```

# NOTE
None

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [New-IoTProvisioningXML](../New-IoTProvisioningXML.md)

# KEYWORDS

- IoT Core Provisioning XML

