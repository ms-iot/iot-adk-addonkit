# IoTFMXML

## SHORT DESCRIPTION
Describes the IoTFMXML Class

## LONG DESCRIPTION
This Class helps with managing the Feature Manifest files. It supports creating new fm.xml file, adding/removing features definitions.


# Constructors
## IoTFMXML(String fmxml, Boolean Create)
Constructor, creates the FMXML object and initialises with the fmxml file contents. If Create flag is specified, then it creates a new fm file if it doesnt already exist.

```powershell
[IoTFMXML]::new([String]$fmxml, [Boolean]$Create)
```


# Properties
## FileName
Stores the filename of the FM XML file.

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## IsOEM
Flag indicating if the FM xml is an OEM FM xml. An OEM FM xml defines OEM feature identifiers.

```yaml
Name: IsOEM
Type: Boolean
Hidden: False
Static: False
```

## XmlDoc
The XML object for the FM XML file.

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```

## xmlns
Namespace used for the Feature Manifest.

```yaml
Name: xmlns
Type: String
Hidden: True
Static: True
```


# Methods
## AddOEMPackage(String pkgpath, String pkgname, String[] featureid)
Adds an OEM package specification with the pkgpath and pkgname. Adds the feature id specified in featureid. It supports one or more feature ids. To add a package to the base section, specify featureid as "Base".

```yaml
Name: AddOEMPackage
Return Type: Void
Hidden: False
Static: False
Definition: Void AddOEMPackage(String pkgpath, String pkgname, String[] featureid)
```

## CreateFMList(String[] fmlist, String arch)
Creates an arch specific FMList xml file, which is a container of various fmfiles specified in fmlist.

```yaml
Name: CreateFMList
Return Type: Void
Hidden: False
Static: False
Definition: Void CreateFMList(String[] fmlist, String arch)
```

## CreateOEMFM()
Creates an new OEM FM XML file.

```yaml
Name: CreateOEMFM
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void CreateOEMFM()
```

## GetBasePackages()
Returns the list of packages in the base section of the feature manifest.

```yaml
Name: GetBasePackages
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetBasePackages()
```

## GetDeviceLayout(String socid)
Returns the device layout object from the device layout xml contained in the package corresponding to the socid(under device layout section).

```yaml
Name: GetDeviceLayout
Return Type: IoTDeviceLayout
Hidden: False
Static: False
Definition: IoTDeviceLayout GetDeviceLayout(String socid)
```

## GetFeatureForPackage(String pkgname)
Returns an array of feature id associated with the given pkgname. The pkgname should be of the format `%OEM_NAME%.abc.def.cab`

```yaml
Name: GetFeatureForPackage
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetFeatureForPackage(String pkgname)
```

## GetFeatureIDs()
Returns an array of feature ids defined in the feature manifest.

```yaml
Name: GetFeatureIDs
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetFeatureIDs()
```

## GetPackageFullNames()
Returns an array of fully resolved package names contained in the feature manifest.

```yaml
Name: GetPackageFullNames
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetPackageFullNames()
```

## GetPackageNames()
Returns an array of package names (with symbols) contained in the feature manifest.

```yaml
Name: GetPackageNames
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetPackageNames()
```

## GetPackagesForFeature(String fid)
Returns an array of packages corresponding to the given feature fid.

```yaml
Name: GetPackagesForFeature
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetPackagesForFeature(String fid)
```

## IsFeaturePresent(String fid)
Returns whether the feature is defined in the feature manifest.

```yaml
Name: IsFeaturePresent
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsFeaturePresent(String fid)
```

## IsPackagePresent(String pkgname)
Returns whether the package is present in the feature manifest.The pkgname should be of the format `%OEM_NAME%.abc.def.cab`

```yaml
Name: IsPackagePresent
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsPackagePresent(String pkgname)
```

## ValidatePackages(String config)
Validates if the packages present in the feature manifest are present, properly signed (both the cab itself and its contents).Config can take values "Retail" or "Test". 

```yaml
Name: ValidatePackages
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean ValidatePackages(String config)
```


# EXAMPLES
A Sample use of this class
```Powershell
    $fmxml = New-IoTFMXML "$env:COMMON_DIR\Packages\OEMCommonFM.xml"
    $fmxml.GetFeatureIDs()
    $fmxml.ValidatePackages("Retail")
```

# NOTE
None

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [New-IoTFMXML](../New-IoTFMXML.md)

# KEYWORDS

- IoT Core Feature Manifest Class
