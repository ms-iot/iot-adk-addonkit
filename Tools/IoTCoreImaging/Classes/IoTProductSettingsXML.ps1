<#
IoTProductSettingsXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTProductSettingsXML {
    [string] $FileName
    [xml] $XmlDoc
    #static [string] $xmlns = ""#"urn:schemas-microsoft-com:windows-provisioning"
    static [string[]] $SettingsKeys = @( 'Name', 'Arch', 'BSP')
    static [string[]] $SMBIOSKeys = @( 'Manufacturer', 'Family', 'ProductName', 'SKUNumber', 'BaseboardManufacturer', 'BaseboardProduct')
    static [string[]] $BuildConfigKeys = @( 'BSPPkgDir')

    # Constructor
    IoTProductSettingsXML (
            [string] $SettingsXML,
            [Boolean] $Create,
            [string] $oemName,
            [string] $familyName,
            [string] $skuNumber,
            [string] $baseboardManufacturer,
            [string] $baseboardProduct,
            [string] $pkgDir
        ) {
        $fileexist = Test-Path $SettingsXML -PathType Leaf
        if (!$Create -and !$fileexist ) {throw "$SettingsXML file not found" }
        $this.FileName = $SettingsXML
        if ($Create) {  
            if (!$fileexist ) {
                Publish-Status "Creating $SettingsXML..." 
                $this.CreateSettingsXML($oemName, $familyName, $skuNumber, $baseboardManufacturer, $baseboardProduct, $pkgDir)
            }
            else { Publish-Warning "$SettingsXML already exists, opening existing file" }
        }
        $this.XmlDoc = [xml](Get-Content -Path $SettingsXML)
    }

    hidden [void] CreateSettingsXML (
            [string] $oemName,                  # default: $env:OEM_NAME
            [string] $familyName,               # default: $env:OEM_NAME + "Family"
            [string] $skuNumber,                # default: $productName + "01"
            [string] $baseboardManufacturer,    # default: "Fabrikam"
            [string] $baseboardProduct,         # default: $productName + "_v01"
            [string] $pkgDir                    # default: ""
        ) {
        $product = Split-Path -Path $this.FileName -Leaf
        $proddir = Split-Path -Path $this.FileName -Parent
        $productName = $product.Replace("Settings.xml", "")

        # Create new XML document
        $xmlwriter = New-Object System.Xml.XmlTextWriter($this.FileName, [System.Text.Encoding]::UTF8)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 4
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("IoTProductSettings")
        $xmlwriter.WriteElementString("Name", $productName)
        $xmlwriter.WriteElementString("Arch", $env:BSP_ARCH)
        $configtxt = "$proddir\prodconfig.txt"
        if (Test-Path $configtxt) {
            $configinfo = (Get-Content $configtxt)
            $configdata = $configinfo.Split("=")
            $BSPName = $configdata[1]
            Remove-Item $configtxt
        }
        else { $BSPName = "" }
        $xmlwriter.WriteElementString("BSP", $BSPName)

        # SMBIOS XML snippet
        $xmlwriter.WriteStartElement("SMBIOS")
        $xmlwriter.WriteElementString("Manufacturer", $oemName)
        $xmlwriter.WriteElementString("Family", $familyName)
        $xmlwriter.WriteElementString("ProductName", $productName)
        $xmlwriter.WriteElementString("SKUNumber", $skuNumber)
        $xmlwriter.WriteElementString("BaseboardManufacturer", $baseboardManufacturer)
        $xmlwriter.WriteElementString("BaseboardProduct", $baseboardProduct)
        $xmlwriter.WriteEndElement() # SMBIOS element

        if ($pkgDir -eq $null) {
            $pkgDir = ""
        }
        # BuildConfig XML snippet
        $xmlwriter.WriteStartElement("BuildConfig")
        $xmlwriter.WriteAttributeString("Name", "Test")
        $xmlwriter.WriteElementString("BSPPkgDir", $pkgDir)
        $xmlwriter.WriteEndElement() # BuildConfig element
        $xmlwriter.WriteStartElement("BuildConfig")
        $xmlwriter.WriteAttributeString("Name", "Retail")
        $xmlwriter.WriteElementString("BSPPkgDir", $pkgDir)
        $xmlwriter.WriteEndElement() # BuildConfig element
        $xmlwriter.WriteEndElement() # IoTProductSettings element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()
    }

    [hashtable] GetSettings() {
        $retval = @{}
        foreach ($key in [IoTProductSettingsXML]::SettingsKeys) {
            Write-Debug "Reading $key"
            $node = $this.XmlDoc.IoTProductSettings.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetSettings([hashtable] $config) {
        foreach ($key in $config.Keys) {
            if ([IoTProductSettingsXML]::SettingsKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $this.XmlDoc.IoTProductSettings.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.XmlDoc.Save($this.FileName)
    }

    [hashtable] GetSMBIOS() {
        $retval = @{}
        foreach ($key in [IoTProductSettingsXML]::SMBIOSKeys) {
            Write-Debug "Reading $key"
            $node = $this.XmlDoc.IoTProductSettings.SMBIOS.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetSMBIOS([hashtable] $config) {
        foreach ($key in $config.Keys) {
            if ([IoTProductSettingsXML]::SMBIOSKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $this.XmlDoc.IoTProductSettings.SMBIOS.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.XmlDoc.Save($this.FileName)
    }

    [Boolean] IsBuildConfigSupported([string]$config) {
        $retval = $false
        $node = $this.XmlDoc.IoTProductSettings.BuildConfig | Where-Object { $_.Name -ieq $config}
        if ($node) { $retval = $true }
        return $retval
    }

    [string[]] GetSupportedBuildConfigs() {
        return $this.XmlDoc.IoTProductSettings.BuildConfig | Foreach-Object { $_.Name }
    }

    [hashtable] GetBuildConfig([string]$config) {
        $retval = @{}
        $node = $this.XmlDoc.IoTProductSettings.BuildConfig | Where-Object { $_.Name -ieq $config}
        foreach ($key in [IoTProductSettingsXML]::BuildConfigKeys) {
            Write-Debug "Reading $key"
            $node = $node.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetBuildConfig([string]$config, [hashtable] $buildcfg) {
        $node = $this.XmlDoc.IoTProductSettings.BuildConfig | Where-Object { $_.Name -ieq $config}
        foreach ($key in $buildcfg.Keys) {
            if ([IoTProductSettingsXML]::BuildConfigKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $node.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $buildcfg[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.XmlDoc.Save($this.FileName)
    }

}
