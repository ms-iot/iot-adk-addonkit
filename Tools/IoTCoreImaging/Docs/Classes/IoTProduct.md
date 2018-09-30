# IoTProduct

## SHORT DESCRIPTION
Describes the IoTProduct Class

## LONG DESCRIPTION
This class provides functions to manage the product configurations. This uses ProductSettingsXML class and OEMInputXML class for managing the xml files and provides additional functionality such as creation of recovery scripts, OCP package management etc.


# Constructors
## IoTProduct(String name, String config)
Constructor, creates the IoTProduct object and initialises with the oeminput file corresponding to the given config.

```powershell
[IoTProduct]::new([String]$name, [String]$config)
```


# Properties
## AvailableOEMFIDs
Stores the array of OEM feature ids available in the FM files listed under AdditionalFMs section of the oeminput file.

```yaml
Name: AvailableOEMFIDs
Type: String[]
Hidden: False
Static: False
```

## BspName
Stores the BSP used in this product.

```yaml
Name: BspName
Type: String
Hidden: False
Static: False
```

## Config
Stores the current active configuration that is loaded. ( can be Retail / Test or any user created config)

```yaml
Name: Config
Type: String
Hidden: False
Static: False
```

## FFUName
The file name of the FFU corresponding to the config.

```yaml
Name: FFUName
Type: String
Hidden: False
Static: False
```

## Name
Name of the product.

```yaml
Name: Name
Type: String
Hidden: False
Static: False
```

## OEMCerts
Array of the OEMCerts used in the product.

```yaml
Name: OEMCerts
Type: String[]
Hidden: False
Static: False
```

## OemXML
[IoTOemInputXML](IoTOemInputXML.md) object corresponding to the config.

```yaml
Name: OemXML
Type: IoTOemInputXML
Hidden: False
Static: False
```

## SettingsXML
[IoTProductSettingsXML](IoTProductSettingsXML.md) object corresponding to this product.

```yaml
Name: SettingsXML
Type: IoTProductSettingsXML
Hidden: False
Static: False
```

## UsedOEMPkgList
Array of the OEM packages included in this current configuration.

```yaml
Name: UsedOEMPkgList
Type: String[]
Hidden: False
Static: False
```


# Methods
## AddFeatureID(String fid, Boolean IsOEM, Boolean AllConfig)
Adds featureID to the active OEMInput xml. If AllConfig is true, then it adds the feature to all supported configuration xml files.

```yaml
Name: AddFeatureID
Return Type: Void
Hidden: False
Static: False
Definition: Void AddFeatureID(String fid, Boolean IsOEM, Boolean AllConfig)
```


## CreateDeviceModel()
Creates the Device Inventory xml, used in registration of this product in the Device Update Center.

```yaml
Name: CreateDeviceModel
Return Type: Void
Hidden: False
Static: False
Definition: Void CreateDeviceModel()
```

## ExportOCP()
Exports the OCP cab bundle that can be uploaded to the Device Update Center.

```yaml
Name: ExportOCP
Return Type: Void
Hidden: False
Static: False
Definition: Void ExportOCP()
```

## GetDeviceLayout()
Returns the [IoTDeviceLayout](IoTDeviceLayout.md) object corresponding to this config.

```yaml
Name: GetDeviceLayout
Return Type: IoTDeviceLayout
Hidden: False
Static: False
Definition: IoTDeviceLayout GetDeviceLayout()
```

## ImportDUCConfig(String zipfile)
Imports the CUSConfig.zip file into the product directory and updates the required settings in the oeminputxml files.

```yaml
Name: ImportDUCConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void ImportDUCConfig(String zipfile)
```


## LoadConfig(String config)
Loads the oeminputxml file corresponding to the specified config.

```yaml
Name: LoadConfig
Return Type: Void
Hidden: False
Static: False
Definition: Void LoadConfig(String config)
```

## PopulateCerts()
Scans the workspace and updates the certs used in the product configuration. This updates OEMCerts.

```yaml
Name: PopulateCerts
Return Type: Void
Hidden: False
Static: False
Definition: Void PopulateCerts()
```

## ProcessFeatureManifests()
Parses all the feature manifest files specified in the AdditionalFMs section and updates the AvailableOEMFIDs

```yaml
Name: ProcessFeatureManifests
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean ProcessFeatureManifests()
```

## RemoveFeatureID(String fid, Boolean AllConfig)
Removes featureID to the active OEMInput xml. If AllConfig is true, then it removes the featureID from all supported configuration xml files.

```yaml
Name: RemoveFeatureID
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveFeatureID(String fid, Boolean AllConfig)
```


## ValidateFeatures()
Validates if all the feature ids specified in the oeminput file are defined and are allowed in that configuration. 

```yaml
Name: ValidateFeatures
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean ValidateFeatures()
```

## ValidatePackages()
Validates if all the packages used in the product configuration are present and properly signed (both the package and its contents)

```yaml
Name: ValidatePackages
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean ValidatePackages()
```


# EXAMPLES
A Sample use of this class
```powershell
    $prod = New-IoTProduct SampleA Test
    $prod.ValidateFeatures()
    $prod.ValidatePackages()
```

# NOTE
None

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [New-IoTProduct](../New-IoTProduct.md)

# KEYWORDS

- IoT Core Product Class
