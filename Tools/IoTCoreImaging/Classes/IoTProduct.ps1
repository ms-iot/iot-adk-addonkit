<#
IoTProduct Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTProduct {
    [string] $Name
    [string] $Config
    [string] $BspName
    [IoTOemInputXML] $OemXML
    [IoTProductSettingsXML] $SettingsXML
    [string] $FFUName
    [string[]] $UsedOEMPkgList # to store OEM packages used in this product
    [string[]] $OEMCerts # to store the oem certs used in this product
    [string[]] $AvailableOEMFIDs # to store the feature ids from FM files

    # Constructor
    IoTProduct([string] $name, [string] $config) {
        $proddir = "$env:SRC_DIR\Products\$name"
        if (!(Test-Path $proddir)) {
            throw "$proddir is not found"
        }
        if (!$config) {
            throw "Config is not defined"
        }

        # Load the project settings xml
        $settingsfile = "$proddir\$name" + "Settings.xml"
        if (!(Test-Path $settingsfile)) {
            throw "$settingsfile is not found"
        }
        $this.SettingsXML = New-IoTProductSettingsXML $settingsfile
        $this.Name = $name
        $settings = $this.SettingsXML.GetSettings()
        $this.BspName = $settings.BSP
        if ($this.SettingsXML.IsBuildConfigSupported($config)) {
            $this.LoadConfig($config)
        }
        else { throw "$config not supported" }
    }

    [void] LoadConfig([string] $config) {
        #Load the Build config settings
        $settings = $this.SettingsXML.GetBuildConfig($config)
        $oeminputfile = "$env:SRC_DIR\Products\$($this.Name)\$($config)OemInput.xml"
        if (!(Test-Path $oeminputfile)) { throw "$oeminputfile is not found" }

        $this.FFUName = "$env:BLD_DIR\$($this.Name)\$config\Flash.ffu"
        $this.OemXML = New-IoTOEMInputXML $oeminputfile
        $this.Config = $config
        $this.AvailableOEMFIDs = @()
        $this.OEMCerts = @()
        $this.UsedOEMPkgList = @()
        if (!([string]::IsNullOrWhiteSpace($settings.BSPPkgDir))) {
            [System.Environment]::SetEnvironmentVariable("BSPPKG_DIR", $settings.BSPPkgDir)
        }
    }

    [Boolean] ProcessFeatureManifests() {
        $retval = $true
        $addfmfiles = $this.OemXML.GetAdditionalFMsSource()
        $this.AvailableOEMFIDs = @() 
        $this.UsedOEMPkgList = @()
        $oemfids = $this.OemXML.GetOEMFeatureIDs()
        
        Foreach ($fmfile in $addfmfiles) {
            if ($fmfile.Contains("IoTUAPNonProductionPartnerShareFM")) {
                if ($this.OemXML.IsRetail()) {
                    Publish-Error "Test FM included in retail build"
                    $retval = $false
                }
            }
            else {
                if (! (Test-Path $fmfile)) {
                    Publish-Error "$fmfile not found"
                    $retval = $false
                }
                else {
                    Publish-Status "Reading feature ids in $fmfile"
                    # Parse the FM xml file for feature ids
                    $fmdoc = New-IoTFMXML $fmfile
                    # Get the feature ids in the fm file.
                    $basepkgs = $fmdoc.GetBasePackages()
                    if ($basepkgs) {
                        $this.UsedOEMPkgList += $basepkgs
                    }
                    $this.AvailableOEMFIDs += $fmdoc.GetFeatureIDs()
                    # Get the list of packages for each feature
                    foreach ($fid in $oemfids) {
                        if ($fmdoc.IsFeaturePresent($fid)) {
                            $this.UsedOEMPkgList += $fmdoc.GetPackagesForFeature($fid)
                        }
                    }
                }
            }
        }
        return $retval
    }
    [Boolean] ValidateFeatures() {
        $retval = $true
        $retval = $this.ProcessFeatureManifests()

        $msids = Get-IoTProductFeatureIDs
        $devfids = Get-IoTProductFeatureIDs Developer
        $dpopFound = $false
        $cusconfigFound = $false

        # Check if the ms feature ids in the oeminputxml are defined in msids
        Publish-Status "Checking Microsoft features in OEMInput file.."
        $msfids = $this.OemXML.GetMicrosoftFeatureIDs()
        foreach ($fid in $msfids) {
            if ($msids -notcontains $fid) { Publish-Warning "$fid is not defined" }
            if ($this.OemXML.IsRetail()) {
                if ($devfids -contains $fid) { Publish-Warning  "$fid is a developer feature used in retail" }
            }
            if ($fid -ieq "IOT_GENERIC_POP") { $dpopFound = $true }
        }

        # Check if the oem feature ids in the oeminputxml are defined in AvailableOEMFIDs
        Publish-Status "Checking OEM features in OEMInput file.."
        $oemfids = $this.OemXML.GetOEMFeatureIDs()
        foreach ($fid in $oemfids) {
            if ($this.AvailableOEMFIDs -notcontains $fid) { Publish-Warning "$fid is not defined" }
            if ($fid -ieq "CUS_DEVICE_INFO") { $cusconfigFound = $true }
        }
        # 17763 is the major release version for RS5 - October 2018 release. 
        if ($env:COREKIT_VER -notcontains "17763"){
            if (!($cusconfigFound -xor $dpopFound)) {
                Publish-Error "Images with Windows 10 IoT Core versions prior to 1809 must include either IOT_GENERIC_POP or CUS_DEVICE_INFO."
                $retval = $false
            }
        }
        return $retval
    }

    [Boolean] ValidatePackages() {
        $retval = $true
        #get the list of specified AdditionalFM files
        $addfmfiles = $this.OemXML.GetAdditionalFMsSource()
        Foreach ($fmfile in $addfmfiles) {
            if ($fmfile.Contains("IoTUAPNonProductionPartnerShareFM")) {
                Write-Verbose "Skipping $fmfile"
            }
            else {
                if (! (Test-Path $fmfile) ) { 
                    #Make sure the fm file is present
                    Publish-Error "$fmfile not found"
                    return $false 
                }
                Publish-Status "Verifying packages in $fmfile"
                # Parse the FM xml file for package names
                $fmdoc = New-IoTFMXML $fmfile
                $result = $fmdoc.ValidatePackages($this.Config)
                if (!$result) { $retval = $false }
            }
        } # Processing FM files complete.
        return $retval
    }

    [void] CreateDeviceModel() {

        $settings = $this.SettingsXML.GetSettings()
        $smbios = $this.SettingsXML.GetSMBIOS()
        $dixmlfile = "$env:SRC_DIR\Products\$($this.Name)\IoTDeviceModel_$($this.Name).xml"
        Publish-Status "DeviceInventory file : $dixmlfile"
        Publish-Status "OS Version           : $env:IOTCORE_VER"
        Publish-Status "BSP Version          : $env:BSP_VERSION"

        $encoding = [System.Text.Encoding]::UTF8
        $xmlwriter = New-Object System.Xml.XmlTextWriter($dixmlfile, $encoding)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 4
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("DeviceInventory")
        $xmlwriter.WriteAttributeString("SchemaVersion", "1")
        $xmlwriter.WriteAttributeString("BuildArch", $settings.Arch)
        $xmlwriter.WriteAttributeString("OSString", $env:IOTCORE_VER)
        $xmlwriter.WriteAttributeString("OCPString", $env:BSP_VERSION)
        $xmlwriter.WriteStartElement("MachineInfo")
        $xmlwriter.WriteAttributeString("Manufacturer", $smbios.Manufacturer)
        $xmlwriter.WriteAttributeString("Family", $smbios.Family)
        $xmlwriter.WriteAttributeString("ProductName", $smbios.ProductName)
        $xmlwriter.WriteAttributeString("SKUNumber", $smbios.SKUNumber)
        $xmlwriter.WriteAttributeString("BaseboardManufacturer", $smbios.BaseboardManufacturer)
        $xmlwriter.WriteAttributeString("BaseboardProduct", $smbios.BaseboardProduct)
        $xmlwriter.WriteEndElement() # MachineInfo element
        $xmlwriter.WriteEndElement() # DeviceInventory element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()
        Publish-Success "DeviceInventory created"
    }

    [void] ExportOCP() {
        # Check if the ffu is present
        $ffudir = Split-Path -Path $this.FFUName -Parent
        if (!(Test-Path $this.FFUName)) {
            throw "$($this.FFUName) is not found"
        }

        $BSPDBPublishxml = $ffudir + "\Flash.BSPDB_publish.xml"
        $BSPDBXML = $ffudir + "\Flash.BSPDB.xml"
        $bspdbdoc = [xml] (get-content $BSPDBPublishxml)
        $BSPVersion = $bspdbdoc.CompDBPublishingInfo.BSPVersion
        Publish-Status "BSP Version : $BSPVersion"

        if ($BSPVersion -ine $env:BSP_VERSION ) {
            Publish-Error "OCP is not used in this product. So skipping Export."
            return
        }
        $outputpath = Join-Path -Path $ffudir -ChildPath $BSPVersion
        $cabpath = Join-Path -Path $outputpath -ChildPath "packages"
        $ocpcab = $this.Name + "_OCP_" + $BSPVersion + ".cab"

        # If output directory does not exist, create one
        New-DirIfNotExist $cabpath

        Publish-Status "Exporting required packages to $outputpath"
        $bspdbcab = $cabpath + "\Flash.BSPDB.xml.cab"
        $packages = $bspdbdoc.GetElementsByTagName("Package")
        Foreach ($package in $packages) {
            Publish-Status $package.Path
            if (!(Test-Path $package.Path )) {
                $package.Path = $env:MSPACKAGE + "\" + $package.Path
                if (!(Test-Path $package.Path )) {
                    Publish-Error "$($package.Path) not found" 
                }
            }
            Copy-Item $package.Path $cabpath
        }

        # Make bspdbxml cab
        Publish-Status "Creating $bspdbcab"
        makecab $BSPDBXML $bspdbcab | Out-Null

        # Sign the bspdb cab
        Publish-Status "Signing $bspdbcab"
        sign $bspdbcab #| Out-Null
        cmd /r "dir /s /b /a-d $cabpath > $outputpath\cablist.txt"

        # Make ocp cab
        Publish-Status "Creating $ocpcab"
        Push-Location $outputpath
        makecab /d CabinetName1=$ocpcab /d DiskDirectoryTemplate=. /d InfFileName=NUL /d RptFileName=NUL /d MaxDiskSize=0 /f $outputpath\cablist.txt
        Publish-Status "Signing $ocpcab"
        #Switch signing certificate for this cab 
        $signparam = $env:SIGNTOOL_OEM_SIGN
        $env:SIGNTOOL_OEM_SIGN = $env:DUCSIGNPARAM
        sign $ocpcab | Out-Null
        #restore signing certificate
        $env:SIGNTOOL_OEM_SIGN = $signparam
        # Cleanup
        Pop-Location
        Remove-Item $cabpath -Force -Recurse
    }

    [void] ImportDUCConfig([string] $zipfile) {
        if (!(Test-Path $zipfile -PathType Leaf -Include *.zip)) {
            Publish-Error "$zipfile is invalid"
            return
        }
        $prodpkgdir = "$env:SRC_DIR\Products\$($this.Name)\Packages\CUSConfig"
        if (Test-Path $prodpkgdir) {
            Publish-Error "CUSConfig already exists."
            return
        }
        Expand-Archive -Path $zipfile -DestinationPath $prodpkgdir
        # Edit the oeminput files to include OCPUpdateFM files and CUS_DEVICE_INFO Feature id; Remove IOT_GENERIC_POP
        Write-Verbose "Updating $($this.Config)"
        $this.OemXML.AddAdditionalFM("%BLD_DIR%\MergedFMs\OCPUpdateFM.xml")
        $this.OemXML.RemoveFeatureID("IOT_GENERIC_POP")
        $this.OemXML.AddFeatureID("CUS_DEVICE_INFO", $true)

        #Update the other config files as well
        $configs = $this.SettingsXML.GetSupportedBuildConfigs()
        foreach ($config in $configs) {
            if ($config -ieq $this.Config) { continue }
            Write-Verbose "Updating $config"
            $oeminputfile = "$env:SRC_DIR\Products\$($this.Name)\$($config)OemInput.xml"
            $oeminputobj = New-IoTOEMInputXML $oeminputfile
            $oeminputobj.AddAdditionalFM("%BLD_DIR%\MergedFMs\OCPUpdateFM.xml")
            $oeminputobj.RemoveFeatureID("IOT_GENERIC_POP")
            $oeminputobj.AddFeatureID("CUS_DEVICE_INFO", $true)
        }
    }

    [void] AddFeatureID([string]$fid, [Boolean]$IsOEM, [Boolean]$AllConfig) {
        Write-Verbose "Adding $fid to $($this.Config)"
        $this.OemXML.AddFeatureID($fid, $IsOEM)
        if ($AllConfig) {
            #Update the other config files as well
            $configs = $this.SettingsXML.GetSupportedBuildConfigs()
            foreach ($config in $configs) {
                if ($config -ieq $this.Config) { continue }
                Write-Verbose "  Adding $fid to $config"
                $oeminputfile = "$env:SRC_DIR\Products\$($this.Name)\$($config)OemInput.xml"
                $oeminputobj = New-IoTOEMInputXML $oeminputfile
                $oeminputobj.AddFeatureID($fid, $IsOEM)
            }
        }
    }

    [void] RemoveFeatureID([string]$fid, [Boolean]$AllConfig) {
        Write-Verbose "Removing $fid to $($this.Config)"
        $this.OemXML.RemoveFeatureID($fid)
        if ($AllConfig) {
            #Update the other config files as well
            $configs = $this.SettingsXML.GetSupportedBuildConfigs()
            foreach ($config in $configs) {
                if ($config -ieq $this.Config) { continue }
                Write-Verbose "  Removing $fid to $config"
                $oeminputfile = "$env:SRC_DIR\Products\$($this.Name)\$($config)OemInput.xml"
                $oeminputobj = New-IoTOEMInputXML $oeminputfile
                $oeminputobj.RemoveFeatureID($fid)
            }
        }
    }    

    [IoTDeviceLayout] GetDeviceLayout() {
        $bsp = $this.BspName
        $fmfile = "$env:BSPSRC_DIR\$bsp\Packages\$bsp" + "FM.xml"
        if (!(Test-Path $fmfile)) {
            Publish-Error "$fmfile file not found"
            return $null
        }

        # Start parsing the fm file to get device layout component
        $fmdoc = New-IoTFMXML $fmfile
        $devlayout = $fmdoc.GetDeviceLayout($this.OemXML.GetSOC())
        return $devlayout
    }

    [void] PopulateCerts() {
        # Get the cert files in the source path 
        $this.OEMCerts = @()
        $certs = Get-ChildItem -Path $env:SRC_DIR, $env:COMMON_DIR -File -Filter *.cer -Recurse | Foreach-Object {$_.FullName}
        if ($certs -eq $null ) {
            Publish-Status "No certs found."
        }
        $certs = @($certs)

        if (!$this.UsedOEMPkgList) {
            $this.ProcessFeatureManifests()
        }

        $provxml = "$env:SRC_DIR\Products\$($this.Name)\prov\customizations.xml"
        $provdoc = New-IoTProvisioningXML $provxml
        foreach ($cert in $certs) {
            $certname = Split-Path $cert -Leaf
            $certdir = Split-Path $cert -Parent
            $certcomp = Split-Path $certdir -Leaf
            $certcomp = "%OEM_NAME%." + $certcomp + ".cab"
            if ($this.UsedOEMPkgList.Contains($certcomp)) {
                Publish-Status "Processing $certname"
                $provdoc.AddRootCertificate($cert)
                $this.OEMCerts += $cert
                # Check if there is a prov xml in the same dir and remove this cert in that xml file
                $appxml = "$certdir\customizations.xml"
                if (Test-Path $appxml) {
                    $appdoc = New-IoTProvisioningXML $appxml
                    $appdoc.RemoveRootCertificate($certname)
                }
            }
            else {
                Publish-Status "Skipping $certname"
            }
        }
    }
}
