# IoTOemInputXML

## SHORT DESCRIPTION
Describes the IoTOemInputXML Class

## LONG DESCRIPTION
This Class helps with managing the OEM Input xml files. It supports creating new oeminput xml file, adding/removing features and feature manifests.


# Constructors
## IoTOemInputXML(String inputxml, Boolean Create)
Constructor, creates the IoTOemInputXML object and initialises with the inputxml file contents. If Create flag is specified, then it creates a new file if it doesnt already exist.

```powershell
[IoTOemInputXML]::new([String]$inputxml, [Boolean]$Create)
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

## FileName
Stores the file name of the oem input xml file.

```yaml
Name: FileName
Type: String
Hidden: False
Static: False
```

## XmlDoc
The XML object of oem input xml file.

```yaml
Name: XmlDoc
Type: System.Xml.XmlDocument
Hidden: False
Static: False
```

## xmlns
Namespace used for OEMInput.

```yaml
Name: xmlns
Type: String
Hidden: True
Static: True
```


# Methods
## AddAdditionalFM(String fmfile)
Adds the fm file to the AdditionalFM section.

```yaml
Name: AddAdditionalFM
Return Type: Void
Hidden: False
Static: False
Definition: Void AddAdditionalFM(String fmfile)
```

## AddFeatureID(String fid, Boolean IsOEM)
Adds the feature id to the oem section if IsOEM is true, otherwise it adds to Microsoft section.

```yaml
Name: AddFeatureID
Return Type: Void
Hidden: False
Static: False
Definition: Void AddFeatureID(String fid, Boolean IsOEM)
```

## CreateOemInputXML()
Creates an oeminput xml file.

```yaml
Name: CreateOemInputXML
Return Type: Void
Hidden: True
Static: False
Definition: hidden Void CreateOemInputXML()
```

## GetAdditionalFMs(Boolean ExpandPath)
Returns the list of AdditionalFMs defined in the oem input file. If ExpandPath is true, the FM file paths are expanded with the env vars.

```yaml
Name: GetAdditionalFMs
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetAdditionalFMs(Boolean ExpandPath)
```

## GetAdditionalFMsSource()
Returns the list of source fm files corresponding to the fm files defined in AdditionalFMs.

```yaml
Name: GetAdditionalFMsSource
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetAdditionalFMsSource()
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

## GetMicrosoftFeatureIDs()
Returns an array of Microsoft feature ids.

```yaml
Name: GetMicrosoftFeatureIDs
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetMicrosoftFeatureIDs()
```

## GetOEMFeatureIDs()
Returns an array of OEM feature ids.

```yaml
Name: GetOEMFeatureIDs
Return Type: String[]
Hidden: False
Static: False
Definition: String[] GetOEMFeatureIDs()
```

## GetSOC()
Returns the SOC ID that identifies the device layout in the bsp fm xml file.

```yaml
Name: GetSOC
Return Type: String
Hidden: False
Static: False
Definition: String GetSOC()
```

## IsFeaturePresent(String fid)
Returns whether fid feature is present ( checks both Microsoft and OEM sections).

```yaml
Name: IsFeaturePresent
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsFeaturePresent(String fid)
```

## IsRetail()
Returns whether the oem input is an retail configuration. (Releasetype = Production)

```yaml
Name: IsRetail
Return Type: Boolean
Hidden: False
Static: False
Definition: Boolean IsRetail()
```

## RemoveAdditionalFM(String fmfile)
Removes the fmfile from the AdditionalFMs section.

```yaml
Name: RemoveAdditionalFM
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveAdditionalFM(String fmfile)
```

## RemoveFeatureID(String fid)
Removes the feature fid.

```yaml
Name: RemoveFeatureID
Return Type: Void
Hidden: False
Static: False
Definition: Void RemoveFeatureID(String fid)
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


# EXAMPLES
A Sample use of this class
```Powershell
    $inputxml = New-IoTOemInputXML "$env:SRC_DIR\Products\SampleA\RetailOEMInput.xml"
    $inputxml.IsRetail()
    $inputxml.GetMicrosoftFeatureIDs()
    $inputxml.GetOEMFeatureIDs()
```

# NOTE
None

# TROUBLESHOOTING NOTE
None

# SEE ALSO

* [New-IoTOemInputXML](../New-IoTOemInputXML.md)

# KEYWORDS

- IoT Core OEMInput XML
