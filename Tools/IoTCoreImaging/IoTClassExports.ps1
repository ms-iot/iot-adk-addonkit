<#
Module to wrap Classes in accessible functions
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

function New-IoTDeviceLayout {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTDeviceLayout
    
    .DESCRIPTION
    This method creates a object of class IoTDeviceLayout
    
    .PARAMETER FilePath
    Mandatory parameter, filename for the devicelayout
    
    .EXAMPLE
    $obj = New-IoTDeviceLayout "$env:COMMON_DIR\Packages\DeviceLayout.GPT4GB\DeviceLayout.xml"
    
    .NOTES
    See [IoTDeviceLayout](.\Classes\IoTDeviceLayout.md) for more details on the class.
    #>
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$FilePath
    )
    return [IoTDeviceLayout]::new($FilePath)
}
function New-IoTProduct {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTProduct
    
    .DESCRIPTION
    This method creates a object of class IoTProduct
    
    .PARAMETER Product
    Mandatory parameter, Product Name.

    .PARAMETER Config
    Mandatory parameter, Product configuration supported in the product.
    
    .EXAMPLE
    $obj = New-IoTProduct SampleA Test
    
    .NOTES
    See [IoTProduct](.\Classes\IoTProduct.md) for more details on the class.
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
        
    )    
    return [IoTProduct]::new($Product, $Config)
}

function New-IoTOemInputXML {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTOemInputXML
    
    .DESCRIPTION
    This method creates a object of class IoTOemInputXML
    
    .PARAMETER InputXML
    Mandatory parameter, OemInput XML file to load

    .PARAMETER Create
    Optional switch parameter, to create the oeminput xml file if not present
    
    .EXAMPLE
    $obj = New-IoTOemInputXML C:\MyDir\TestOEMInput.xml -Create
    
    .NOTES
    See [IoTOemInputXML](.\Classes\IoTOemInputXML.md) for more details on the class.
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$InputXML,
        [Parameter(Position = 1, Mandatory = $false)]
        [Switch]$Create
    )    
    return [IoTOemInputXML]::new($InputXML, $Create)
}

function New-IoTWMXML {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTWMXML
    
    .DESCRIPTION
    This method creates a object of class IoTWMXML
    
    .PARAMETER InputXML
    Mandatory parameter, WM XML file to load

    .PARAMETER Create
    Optional switch parameter, to create the wm xml file if not present
    
    .EXAMPLE
    $obj = New-IoTWMXML C:\MyDir\samplewm.xml -Create
    
    .NOTES
    See [IoTWMXML](.\Classes\IoTWMXML.md) for more details on the class.
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$InputXML,
        [Parameter(Position = 1, Mandatory = $false)]
        [Switch]$Create
    )    
    return [IoTWMXML]::new($InputXML, $Create)
}
function New-IoTProvisioningXML {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTProvisioningXML
    
    .DESCRIPTION
    This method creates a object of class IoTProvisioningXML
    
    .PARAMETER InputXML
    Mandatory parameter, Provisioning XML file to load

    .PARAMETER Create
    Optional switch parameter, to create the Provisioning xml file if not present
    
    .EXAMPLE
    $obj = New-IoTProvisioningXML C:\MyDir\customizations.xml -Create
    
    .NOTES
    See [IoTProvisioningXML](.\Classes\IoTProvisioningXML.md) for more details on the class.
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$InputXML,
        [Parameter(Position = 1, Mandatory = $false)]
        [Switch]$Create
    )     
    return [IoTProvisioningXML]::new($InputXML, $Create)
}

function New-IoTProductSettingsXML {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTProductSettingsXML
    
    .DESCRIPTION
    This method creates a object of class IoTProductSettingsXML
    
    .PARAMETER InputXML
    Mandatory parameter, Product settings XML file to load

    .PARAMETER Create
    Optional switch parameter, to create the product settings xml file if not present
    
    .PARAMETER oemName
    Mandatory parameter, OEM name for the SMBIOS

    .PARAMETER familyName
    Mandatory parameter, product family name for the SMBIOS

    .PARAMETER skuNumber
    Mandatory parameter, SKU name for the SMBIOS

    .PARAMETER baseboardManufacturer
    Mandatory parameter, baseboard Manufacturere for the SMBIOS

    .PARAMETER baseboardProduct
    Mandatory parameter, baseboard Product for the SMBIOS

    .PARAMETER pkgDir
    Mandatory parameter, BSP package path for the product build configs

    .EXAMPLE
    $obj = New-IoTProductSettingsXML $env:SRC_DIR\Products\SampleA\SampleASettings.xml -Create:$false OEMName ProdFamily ProdSKU1 Fabrikam RPiCustom2
    
    .NOTES
    See [IoTProductSettingsXML](.\Classes\IoTProductSettingsXML.md) for more details on the class.
    #>
    [CmdletBinding(DefaultParametersetName='None')]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String] $InputXML,
        [Parameter(Position=1, ParameterSetName='ConstructionArgs', Mandatory=$false)][switch] $Create,
        [Parameter(Position=2, ParameterSetName='ConstructionArgs', Mandatory=$true)][String] $oemName,
        [Parameter(Position=3, ParameterSetName='ConstructionArgs', Mandatory=$true)][String] $familyName,
        [Parameter(Position=4, ParameterSetName='ConstructionArgs', Mandatory=$true)][String] $skuNumber,
        [Parameter(Position=5, ParameterSetName='ConstructionArgs', Mandatory=$true)][String] $baseboardManufacturer,
        [Parameter(Position=6, ParameterSetName='ConstructionArgs', Mandatory=$true)][String] $baseboardProduct,
        [Parameter(Position=7, ParameterSetName='ConstructionArgs', Mandatory=$false)][String] $pkgDir = $null
    )

    $bCreate = $true
    # We always have to pass these arguments, but they're unneeded unless we're constructing a new XML.
    if (-not $Create) {
        $oemName = $familyName = $skuNumber = $baseboardManufacturer = $baseboardProduct = $pkgDir = $null
        $bCreate = $false
    }
    return [IoTProductSettingsXML]::new($InputXML, $bCreate, $oemName, $familyName, $skuNumber, $baseboardManufacturer, $baseboardProduct, $pkgDir)
}

function New-IoTFMXML {
    <#
    .SYNOPSIS
    Factory method to create a new object of class IoTFMXML
    
    .DESCRIPTION
    This method creates a object of class IoTFMXML
    
    .PARAMETER InputXML
    Mandatory parameter, feature manifest XML file to load

    .PARAMETER Create
    Optional switch parameter, to create the feature manifest xml file if not present
    
    .EXAMPLE
    $obj = New-IoTFMXML $env:COMMON_DIR\Packages\OEMCommonFM.xml
    
    .NOTES
    See [IoTFMXML](.\Classes\IoTFMXML.md) for more details on the class.
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$InputXML,
        [Parameter(Position = 1, Mandatory = $false)]
        [Switch]$Create
    )     
    return [IoTFMXML]::new($InputXML, $Create)
}

function New-IoTWMWriter {
    <#
    .SYNOPSIS
    Factory method, returing the IoTWMWriter class object used to write namespace.name.wm.xml file.
    
    .DESCRIPTION
    Factory method, returing the IoTWMWriter class object. 
    
    .PARAMETER FileDir
    Mandatory parameter, specifying the directory where the wm.xml file needs to be created.
    
    .PARAMETER Namespace
    Mandatory parameter, specifying the namespace.
    
    .PARAMETER Name
    Mandatory parameter, specifying the name. 
    
    .PARAMETER Force
    Mandatory parameter, specifying the name. 
    .EXAMPLE
    $wmwriter = New-IoTWMWriter C:\Test Custom Settings
    
    .NOTES
    This class is used in the Add-IoT* methods.
    ```
    $wmwriter.Start("MainOS")
    $wmwriter.AddRegKeys("`$(hklm.software)\Contoso\EmptyKey", $null)
    $wmwriter.Finish()
    ```
    #>
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [String]$FileDir,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Namespace,
        # Validate packages option
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$Name = $null,
        [Parameter(Position = 3, Mandatory = $false)]
        [Switch]$Force        
    )
    return [IoTWMWriter]::new($FileDir, $Namespace, $Name, $Force)
}

function Mount-IoTFFUImage {
    <#
    .SYNOPSIS
    Mounts the specifed FFU, parses the device layout and assigns drive letters for the partitions with file system defined.
    
    .DESCRIPTION
    Mounts the specifed FFU, parses the device layout and assigns drive letters for the partitions with file system defined.No other FFU must be mounted when this is called. 
    
    .PARAMETER FFUName
    Name of the FFU to be mounted.
    
    .EXAMPLE
    Mount-IoTFFUImage c:\MyTestImage.ffu
    Mounts the MyTestImage.ffu and assigns free drive letter.
    
    .NOTES
    See also Unmount-IoTFFUImage
    #>    
    Param
    (
        # FFU file name to mount
        [Parameter(Position = 0,Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$FFUName
    )    
    $retval = $true
    $ffuobj = [IoTFFU]::GetInstance()
    if ($ffuobj.IsMounted()) {
        Publish-Error "$($ffuobj.FileName) already mounted."
        retval = $false
    }
    else {
        try {
            $ffuobj.Initialize($FFUName)
            $ffuobj.Mount()
        }
        catch {
            $msg = $_.Exception.Message
            Publish-Error "$msg"
            $retval = $false
        }
    }
    return $retval
}

function Dismount-IoTFFUImage {
    <#
    .SYNOPSIS
    Dismounts the mounted ffu image and saves it as a new ffu if an ffuname is specified.
    
    .DESCRIPTION
    Dismounts the mounted FFU image. If ffuname is specified, the ffu is saved in that name. If the ffuname is not specified, the mounted ffu is not saved.
    
    .PARAMETER FFUName
    Optional FFU name to save the mounted FFU.
   
    .EXAMPLE
    Dismount-IoTFFUImage
    Dismounts the mounted ffu without saving.
    
    .EXAMPLE
    Dismount-IoTFFUImage C:\MyNewImage.ffu
    Dismounts and saves the mounted ffu as MyNewImage.ffu.

    .NOTES
    See also Mount-IoTFFUImage
    #>    
    Param
    (
        # FFU file name to mount
        [Parameter(Position = 0,Mandatory = $false)]
        [String]$FFUName
    )    
    $ffuobj = [IoTFFU]::GetInstance()
    return $ffuobj.Dismount($FFUName)
}

function Export-IoTFFUAsWims {
    <#
    .SYNOPSIS
    Extracts the mounted partitions as wim files
    
    .DESCRIPTION
    This function exports the mounted partitions (EFIESP, MainOS and Data) as wim files and stores them in the same directory as the ffu. Note that the FFU must be mounted before calling this function.
    
    .EXAMPLE
    Export-IoTFFUAsWims
    
    .NOTES
    See also Mount-IoTFFUImage
    #>    
    $ffuobj = [IoTFFU]::GetInstance()
    $ffuobj.ExtractWims()
}

function New-IoTFFUCIPolicy {
    <#
    .SYNOPSIS
    This function scans the mounted FFU Main OS partition and creates a CI policy.
    
    .DESCRIPTION
    This function scans the mounted FFU Main OS partition and creates a CI policy. The FFU must be mounted before calling this function. This creates an `security\initialpolicy.xml` in the same folder as the FFU.
    
    .EXAMPLE
    New-IoTFFUCIPolicy
    
    .NOTES
    See also Mount-IoTFFUImage
    #>    
    $ffuobj = [IoTFFU]::GetInstance()
    $ffuobj.ScanNewCIPolicy()
}

function Get-IoTFFUDrives {
    <#
    .SYNOPSIS
    Returns a hashtable of the drive letters of the mounted partitions
    
    .DESCRIPTION
    Returns a hashtable of the drive letters of the mounted file partitions of the FFU. The FFU must be mounted before calling this method.
    
    .EXAMPLE
    Get-IoTFFUDrives
    
    .NOTES
    See also Mount-IoTFFUImage
    #>     
    $ffuobj = [IoTFFU]::GetInstance()
    return $ffuobj.DeviceLayout.DriveLetters
}


#instance of product fm xml
[IoTFMXML] $ProdFM
#instance of product non production fm xml
[IoTFMXML] $NonProdFM 

function Open-ProductFM {
    $msfmpkg = Get-ChildItem -Path $env:MSPKG_DIR -Filter "Microsoft.IoTUAP.IoTUAPFM*.cab" | Foreach-Object {$_.FullName}
    $cabname = Split-Path $msfmpkg -Leaf

    Copy-Item $msfmpkg $env:TMP\
    Set-Location $env:TMP

    cmd /r "expand $cabname $env:TMP -F:*.xml" | Out-Null

    $filehandle = Get-ChildItem -Path $env:TMP -Filter "IoTUAPFM.xml" -Recurse | Foreach-Object {$_.FullName}
    $Script:ProdFM = New-IoTFMXML $filehandle

    # Get the feature ids in the FM file.
    Set-Location $env:IOTWKSPACE
    Remove-Item $env:TMP\* -Recurse | Out-Null	
}

function Open-NonProductFM {
    $npfmxml = "$env:AKROOT\FMFiles\$env:BSP_ARCH\IoTUAPNonProductionPartnerShareFM.xml"
    $Script:NonProdFM = New-IoTFMXML $npfmxml
}

function Get-IoTProductFeatureIDs {
    <#
    .SYNOPSIS
    Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace.
    
    .DESCRIPTION
    Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace under MSPkgRoot tag.
    
    .PARAMETER FeatureType
    Optional parameter, with values: "Developer", "Test", "Retail", "Deprecated" and "All". Default is "All" which is equal to Test + Retail features.
   
    .EXAMPLE
    Get-IoTProductFeatureIDs
    Returns all feature IDs including Test/Retail..
    
    .EXAMPLE
    Get-IoTProductFeatureIDs Test
    Returns the Test feature IDs only

    .NOTES
    See also Get-IoTProductPackagesForFeature
    #>     
    Param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Developer", "Test", "Retail", "Deprecated", "All")]
        [String]$FeatureType = "All"
    )
    $retval = @()
    switch ($FeatureType) {
        'Developer' {
            $ConfigFile = "$PSScriptRoot\IoTEnvSettings.xml"
            [xml] $Config = Get-Content -Path $ConfigFile
            $retval = $Config.IoTEnvironment.DevFeatureIDs.DevFeatureID
            break
        }
        'Test' {
            if (!$Script:NonProdFM) { Open-NonProductFM }
            $retval = $Script:NonProdFM.GetFeatureIDs()
            break
        }
        'Retail' {
            if (!$Script:ProdFM) { Open-ProductFM }
            $retval = $Script:ProdFM.GetFeatureIDs()
            break
        }
        'Deprecated' {
            $ConfigFile = "$PSScriptRoot\IoTEnvSettings.xml"
            [xml] $Config = Get-Content -Path $ConfigFile
            $retval = $Config.IoTEnvironment.DeprecatedIDs.DeprecatedID
            break
        }
        'All' {
            if (!$Script:ProdFM) { Open-ProductFM }
            $retval = $Script:ProdFM.GetFeatureIDs()
            if (!$Script:NonProdFM) { Open-NonProductFM }
            $retval += $Script:NonProdFM.GetFeatureIDs()
            break
        }
        default { }
    }
    return $retval    
}

function Get-IoTProductPackagesForFeature {
    <#
    .SYNOPSIS
    Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace.
    
    .DESCRIPTION
    Returns the list of supported feature IDs in the Windows 10 IoT Core OS release defined in the workspace under MSPkgRoot tag.
    
    .PARAMETER FeatureID
    A Valid Feature ID defined in the Windows 10 IoT Core OS.
   
    .EXAMPLE
    Get-IoTProductPackagesForFeature IOT_BERTHA
    Returns the list of packages included for IOT_BERTHA feature.

    .NOTES
    See also Get-IoTProductFeatureIDs
    #>     
    Param
    (
        # FeatureID
        [Parameter(Mandatory = $true)]
        [String]$FeatureID
    )
    if ($Script:ProdFM -eq $null) { Open-ProductFM }
    if ($Script:ProdFM.IsFeaturePresent($FeatureID)) { 
        return $Script:ProdFM.GetPackagesForFeature($FeatureID) 
    }
    if ($Script:NonProdFM -eq $null) { Open-NonProductFM }
    if ($Script:NonProdFM.IsFeaturePresent($FeatureID)) { 
        return $Script:NonProdFM.GetPackagesForFeature($FeatureID) 
    }
    Publish-Error "$FeatureID not present"
    return $null
}

function Add-IoTProductFeature {
    <#
    .SYNOPSIS
    Adds feature id to the specified product's oeminput xml file.
    
    .DESCRIPTION
    Adds feature id (oem feature or Microsoft feature) to the specified product's oeminput xml file for the given configuration.
    
    .PARAMETER Product
    Mandatory parameter, specify the product name.
    
    .PARAMETER Config
    Mandatory paramter, specify the config. Supported values : Test,Retail and All
    
    .PARAMETER FeatureID
    Mandatory parameter, specify the featureId to be added.
    
    .PARAMETER OEM
    Optional switch parameter, to specify that the featuretype is OEM. Default featuretype is Microsoft

    .EXAMPLE
    Add-IoTProductFeature SampleA Test CUSTOM_CMD OEM
    Adds CUSTOM_CMD feature to the SampleA TestOEMInput.xml file.

    .EXAMPLE
    Add-IoTProductFeature SampleA All CUSTOM_CMD OEM
    Adds CUSTOM_CMD feature to the SampleA TestOEMInput.xml and RetailOEMInput.xml files.

    .NOTES
    See Remove-IoTProductFeature also.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Product,
        [Parameter(Position=1, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Config,
        [Parameter(Position=2, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$FeatureID,
        [Parameter(Position=3, Mandatory=$false)][Switch]$OEM
    )
    $ProdConfig = $Config
    $AllConfig = $false
    if ($Config -ieq "All"){
        $ProdConfig = "Test"
        $AllConfig = $true
    }
    try {
        $iotprod = New-IoTProduct $Product $ProdConfig
        $iotprod.AddFeatureID($FeatureID,$OEM,$AllConfig)
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}
function Remove-IoTProductFeature {
    <#
    .SYNOPSIS
    Removes feature id from the specified product's oeminput xml file.
    
    .DESCRIPTION
    Removes feature id (oem feature or Microsoft feature) from the specified product's oeminput xml file for the given configuration.
    
    .PARAMETER Product
    Mandatory parameter, specify the product name.
    
    .PARAMETER Config
    Mandatory paramter, specify the config. Supported values : Test,Retail and All
    
    .PARAMETER FeatureID
    Mandatory parameter, specify the featureId to be removed.

    .EXAMPLE
    Remove-IoTProductFeature SampleA Test CUSTOM_CMD
    Removes CUSTOM_CMD feature to the SampleA TestOEMInput.xml file.

    .EXAMPLE
    Remove-IoTProductFeature SampleA All CUSTOM_CMD
    Removes CUSTOM_CMD feature to the SampleA TestOEMInput.xml and RetailOEMInput.xml files.

    .NOTES
    See Add-IoTProductFeature also.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Product,
        [Parameter(Position=1, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Config,
        [Parameter(Position=2, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$FeatureID
    )
    $ProdConfig = $Config
    $AllConfig = $false
    if ($Config -ieq "All"){
        $ProdConfig = "Test"
        $AllConfig = $true
    }
    try {
        $iotprod = New-IoTProduct $Product $ProdConfig
        $iotprod.RemoveFeatureID($FeatureID,$AllConfig)
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}