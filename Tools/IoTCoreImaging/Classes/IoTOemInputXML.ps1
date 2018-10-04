<#
This contains IoTOemInputXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTOemInputXML {
    [string] $FileName
    [xml] $XmlDoc
    hidden static [string] $xmlns = "http://schemas.microsoft.com/embedded/2004/10/ImageUpdate"
    static [string[]] $ConfigKeys = @( 'Description', 'SOC', 'SV', 'Device', 'ReleaseType', 'BuildType', 'BootUILanguage', 'BootLocale')
    # Constructor
    IoTOemInputXML ([string]$inputxml, [Boolean]$Create) {
        $fileexist = Test-Path $inputxml -PathType Leaf
        if (!$Create -and !$fileexist ) { throw "$inputxml file not found" }
        $this.FileName = $inputxml
        if ($Create) {
            if (!$fileexist) {
                $this.CreateOemInputXML()
            }
            else { Publish-Warning "$inputxml already exists, opening existing file" }
        }
        $this.XmlDoc = [xml]( Get-Content -Path $inputxml)
    }

    hidden [void] CreateOemInputXML() {
        Write-Verbose "Creating $($this.FileName)..."
        $xmlwriter = New-Object System.Xml.XmlTextWriter($this.Filename, [System.Text.Encoding]::UTF8)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 2
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("OEMInput")
        $xmlwriter.WriteAttributeString("xmlns", "xsi", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema-instance")
        $xmlwriter.WriteAttributeString("xmlns", "xsd", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema")
        $xmlwriter.WriteAttributeString("xmlns", [IoTOemInputXML]::xmlns)

        $xmlwriter.WriteElementString("Description", "Windows 10 IoT Core FFU")
        $xmlwriter.WriteElementString("SOC", "{BSP}_Soc")
        $xmlwriter.WriteElementString("SV", "SiliconVendor")
        $xmlwriter.WriteElementString("Device", "{BSP}_Device")
        $xmlwriter.WriteElementString("ReleaseType", "Production")
        $xmlwriter.WriteElementString("BuildType", "fre")
        # Language specifics
        $xmlwriter.WriteStartElement("SupportedLanguages")
        $xmlwriter.WriteStartElement("UserInterface")
        $xmlwriter.WriteElementString("Language", "en-us")
        $xmlwriter.WriteEndElement() # UserInterface element
        $xmlwriter.WriteStartElement("Keyboard")
        $xmlwriter.WriteElementString("Language", "en-us")
        $xmlwriter.WriteEndElement() # Keyboard element
        $xmlwriter.WriteStartElement("Speech")
        $xmlwriter.WriteElementString("Language", "en-us")
        $xmlwriter.WriteEndElement() # Speech element
        $xmlwriter.WriteEndElement() # SupportedLanguages element  
        $xmlwriter.WriteElementString("BootUILanguage", "en-us")
        $xmlwriter.WriteElementString("BootLocale", "en-us") 
        $xmlwriter.WriteStartElement("Resolutions")
        $xmlwriter.WriteElementString("Resolution", "1024x768")
        $xmlwriter.WriteEndElement() # Resolutions element
        # Additional FMs
        $xmlwriter.WriteStartElement("AdditionalFMs")
        $xmlwriter.WriteComment("Including BSP feature manifest")
        $xmlwriter.WriteElementString("AdditionalFM", "%BLD_DIR%\MergedFMs\{BSP}FM.xml")
        $xmlwriter.WriteComment("Including OEM feature manifest")
        $xmlwriter.WriteElementString("AdditionalFM", "%BLD_DIR%\MergedFMs\OEMCommonFM.xml")
        $xmlwriter.WriteElementString("AdditionalFM", "%BLD_DIR%\MergedFMs\OEMFM.xml")
        $xmlwriter.WriteEndElement() # AdditionalFMs element 
        #Features section
        $xmlwriter.WriteStartElement("Features")
        $xmlwriter.WriteStartElement("Microsoft")
        $xmlwriter.WriteComment("Include IoT Core OS Features here")
        $xmlwriter.WriteElementString("Feature", "IOT_EFIESP")
        $xmlwriter.WriteEndElement() # Microsoft element
        $xmlwriter.WriteStartElement("OEM")
        $xmlwriter.WriteComment("Include OEM Features here")
        $xmlwriter.WriteElementString("Feature", "CUSTOM_CMD")
        $xmlwriter.WriteElementString("Feature", "PROV_AUTO")
        $xmlwriter.WriteEndElement() # OEM element
        $xmlwriter.WriteEndElement() # Features element
        $xmlwriter.WriteElementString("Product", "Windows 10 IoT Core")
        $xmlwriter.WriteEndElement() # OEMInput element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()
    }

    [Boolean] IsRetail() {
        return ($this.XmlDoc.OEMInput.ReleaseType -ieq "Production")
    }

    [string] GetSOC() {
        return $this.XmlDoc.OEMInput.SOC
    }

    [hashtable] GetConfig() {
        $retval = @{}
        foreach ($key in [IoTOemInputXML]::ConfigKeys) {
            Write-Debug "Reading $key"
            $node = $this.XmlDoc.OEMInput.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key,$node.InnerText)
        }
        return $retval
    }

    [void] SetConfig([hashtable] $config) {
        foreach ($key in $config.Keys) {
            if ([IoTOemInputXML]::ConfigKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $this.XmlDoc.OEMInput.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.XmlDoc.Save($this.FileName)
    }

    [string[]] GetMicrosoftFeatureIDs() {
        $fids = ($this.XmlDoc.OEMInput.Features.Microsoft.Feature) | Sort-Object -Unique
        return @() + $fids  # prevent returning null
    }

    [string[]] GetOEMFeatureIDs() {
        $fids = ($this.XmlDoc.OEMInput.Features.OEM.Feature) | Sort-Object -Unique
        return @() + $fids  # prevent returning null
    }

    [Boolean] IsFeaturePresent([string] $fid) {
        $existingfids = $this.GetMicrosoftFeatureIDs() + $this.GetOEMFeatureIDs()
        return $existingfids.Contains($fid)
    }

    [void] AddFeatureID([string]$fid, [Boolean]$IsOEM) {
        $node = $this.XmlDoc.GetElementsByTagName("Feature") |  Where-Object { ($_.InnerText) -ieq $fid }
        if ($node) {
            Publish-Warning "$fid already defined"
            return
        }
        if ($IsOEM) {
            $node = $this.XmlDoc.OEMInput.Features.OEM
        }
        else { $node = $this.XmlDoc.OEMInput.Features.Microsoft }
        $newfid = $this.XmlDoc.CreateElement("Feature", [IoTOemInputXML]::xmlns)
        $newfid.InnerText = $fid
        $node.AppendChild($newfid)
        Write-Debug "$newfid added"
        $this.XmlDoc.Save($this.FileName)
    }

    [void] RemoveFeatureID([string]$fid) {

        $node = $this.XmlDoc.GetElementsByTagName("Feature") |  Where-Object { ($_.InnerText) -ieq $fid }
        if (!$node) {
            Publish-Warning "$fid not present"
            return
        }
        $parentnode = $node.ParentNode
        $oldnode = $parentnode.RemoveChild($node)
        Write-Debug "$oldnode removed"
        $this.XmlDoc.Save($this.FileName)
    }

    [string[]] GetAdditionalFMs([Boolean] $ExpandPath) {
        $retval = $this.XmlDoc.OEMInput.AdditionalFMs.AdditionalFM
        if ($ExpandPath) {
            $retval = $retval | ForEach-Object { Expand-IoTPath($_) }
        }
        return $retval
    }

    [string[]] GetAdditionalFMsSource() {
        $retval = @()
        $addfmfiles = $this.XmlDoc.OEMInput.AdditionalFMs.AdditionalFM
        Foreach ($fmfile in $addfmfiles) {
            if ($fmfile.Contains("IoTUAPNonProductionPartnerShareFM")) {
                $retval += Expand-IoTPath($fmfile)
            }
            else {
                # Remove filename relative path
                $name = $fmfile.Replace("%BLD_DIR%\MergedFMs\", "")
                Write-Debug "Looking for $name"
                # Get the absolute path of filename
                $filehandle = Get-ChildItem -Path $env:SRC_DIR, $env:COMMON_DIR, $env:TEMPLATES_DIR -Filter $name -Recurse | Foreach-Object {$_.FullName}
                if (! $filehandle ) {
                    Publish-Error "$name not found"
                }
                else {
                    $retval += $filehandle
                }
            }
        }
        return $retval
    }

    [void] AddAdditionalFM([string]$fmfile) {

        $node = $this.XmlDoc.GetElementsByTagName("AdditionalFM") |  Where-Object { ($_.InnerText) -ieq $fmfile }
        if ($node) {
            Publish-Warning "$fmfile already defined"
            return
        }
        $fmnode = $this.XmlDoc.OEMInput.AdditionalFMs
        $newfm = $this.XmlDoc.CreateElement("AdditionalFM", [IoTOemInputXML]::xmlns)
        $newfm.InnerText = $fmfile
        $fmnode.AppendChild($newfm)
        Write-Debug "$newfm added"
        $this.XmlDoc.Save($this.FileName)
    }

    [void] RemoveAdditionalFM([string]$fmfile) {

        $node = $this.XmlDoc.GetElementsByTagName("AdditionalFM") |  Where-Object { ($_.InnerText) -ieq $fmfile }
        if (!$node) {
            Publish-Warning "$fmfile not present"
            return
        }
        $parentnode = $node.ParentNode
        $oldnode = $parentnode.RemoveChild($node)
        Write-Debug "$oldnode removed"
        $this.XmlDoc.Save($this.FileName)
    }
    # TODO Add Lanugage specific methods
}
