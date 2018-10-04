# IoTProductSettingsXML

## SHORT DESCRIPTION
Describes the IoTProductSettingsXML Class

## LONG DESCRIPTION
This class helps in managing the product settings XML configuration.


# Constructors
## IoTProductSettingsXML(String SettingsXML, Boolean Create, String oemName, String familyName, String skuNumber, String baseboardManufacturer, String baseboardProduct, String pkgDir)
Constructor. If the file is not present and the Create flag is false, it throws an exception.
```powershell
[IoTProductSettingsXML]::new(String SettingsXML, Boolean Create, String oemName, String familyName, String skuNumber, String baseboardManufacturer, String baseboardProduct, String pkgDir)
```
# Properties
## BuildConfigKeys
This is the array of keys supported in the GetBuildConfig/SetBuildConfig methods.

```yaml
Name: BuildConfigKeys
Type: String[]
Hidden: False
Static: True
```

## FileName
Filename of the product settings xml

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## SettingsKeys
This is the array of keys supported in the GetSettings/SetSettings methods.

```yaml
Name: SettingsKeys
Type: String[]
Hidden: False
Static: True
```

## SMBIOSKeys
This is the array of keys supported in the GetSMBIOS/SetSMBIOS methods.

```yaml
Name: SMBIOSKeys
Type: String[]
Hidden: False
Static: True
```

## XmlDoc
XML document object for the product settings xml

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```


# Methods
## CreateSettingsXML(String oemName, String familyName, String skuNumber, String baseboardManufacturer, String baseboardProduct, String pkgDir)

## GetBuildConfig(String config)
Returns an hashtable of config elements with the values. See ConfigKeys for the list of keys returned.

```yaml
Name: GetBuildConfig
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetBuildConfig(String config)
```

## GetSettings()
Returns an hashtable of config elements with the values. See ConfigKeys for the list of keys returned.

```yaml
Name: GetSettings
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetSettings()
```

## GetSMBIOS()
Returns an hashtable of config elements with the values. See ConfigKeys for the list of keys returned.

```yaml
Name: GetSMBIOS
Return Type: System.Collections.Hashtable
Hidden: False
Static: False
Definition: System.Collections.Hashtable GetSMBIOS()
```

## GetSupportedBuildConfigs()
Returns the array of supported build configs in this product.

```yaml
Name: GetSupportedBuildConfigs
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetSupportedBuildConfigs()
```

## IsBuildConfigSupported(String config)
Returns if the buildconfig is defined.

```yaml
Name: IsBuildConfigSupported
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsBuildConfigSupported(String config)
```

## SetBuildConfig(String config, System.Collections.Hashtable buildcfg)
Sets the current config elements with the hashtable values provided. See ConfigKeys for the supported keys.

```yaml
Name: SetBuildConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void SetBuildConfig(String config, System.Collections.Hashtable buildcfg)
```

## SetSettings(System.Collections.Hashtable config)
Sets the current config elements with the hashtable values provided. See ConfigKeys for the supported keys.

```yaml
Name: SetSettings
Return Type: Void
Hidden: False
Static: False
Definition: Void SetSettings(System.Collections.Hashtable config)
```

## SetSMBIOS(System.Collections.Hashtable config)
Sets the current config elements with the hashtable values provided. See ConfigKeys for the supported keys.

```yaml
Name: SetSMBIOS
Return Type: Void
Hidden: False
Static: False
Definition: Void SetSMBIOS(System.Collections.Hashtable config)
```


# EXAMPLES

A Sample use of this class
```Powershell
    $samplea = New-IoTProductSettingsXML "$env:SRC_DIR\Products\SampleA\SampleASettings.xml"
    $samplea_smbios = $samplea.GetSMBIOS()
```

# NOTE
None

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [New-IoTProductSettingsXML](../New-IoTProductSettingsXML.md)

# KEYWORDS

- IoT Core Product Settings
