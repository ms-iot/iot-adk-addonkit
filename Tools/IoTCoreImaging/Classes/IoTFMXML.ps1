<#
IoTFMXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTFMXML {
    [string] $FileName
    [xml] $XmlDoc
    [Boolean] $IsOEM
    hidden static [string] $xmlns = "http://schemas.microsoft.com/embedded/2004/10/ImageUpdate"

    # Constructor
    IoTFMXML ([string]$fmxml, [Boolean]$Create) {
        $fileexist = Test-Path $fmxml -PathType Leaf
        if (!$Create -and !$fileexist ) { throw "$fmxml file not found" }
        $this.FileName = $fmxml
        if ($Create) {
            if (!$fileexist) {
                Write-Verbose "Creating $fmxml..." 
                $this.CreateOEMFM()
            }
            else { Publish-Warning "$fmxml already exists, opening existing file" }
        }
        $this.XmlDoc = [xml]( Get-Content -Path $fmxml)
        $oemnode = $this.XmlDoc.FeatureManifest.Features.OEM
        $this.IsOEM = ($oemnode -ne $null )
    }

    hidden [void] CreateOEMFM() {
        $FmWriter = New-Object System.Xml.XmlTextWriter($this.Filename, [System.Text.Encoding]::UTF8)
        $FmWriter.Formatting = "Indented"
        $FmWriter.Indentation = 4
        $FmWriter.WriteStartDocument()
        $FmWriter.WriteStartElement("FeatureManifest")
        $FmWriter.WriteAttributeString("xmlns", "xsi", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema-instance")
        $FmWriter.WriteAttributeString("xmlns", "xsd", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema")
        $FmWriter.WriteAttributeString("xmlns", [IoTFMXML]::xmlns)

        $FmWriter.WriteStartElement("BasePackages")
        $FmWriter.WriteComment("Base packages goes here")
        $FmWriter.WriteEndElement() # BasePackages element
        $FmWriter.WriteStartElement("Features")
        $FmWriter.WriteStartElement("OEM")
        $FmWriter.WriteComment("OEM feature packages goes here")
        $FmWriter.WriteEndElement() # OEM element       
        $FmWriter.WriteElementString("OEMFeatureGroups", "")
        $FmWriter.WriteEndElement() # Features element
        $FmWriter.WriteEndElement() # IoTWorkspace element
        $FmWriter.WriteEndDocument()
        $FmWriter.Flush()
        $FmWriter.Close()
    }

    [void] CreateFMList([string[]]$fmlist, [string]$arch) {
        $fmlistxml = ($this.FileName).Replace("FM.xml", "FMFileList.xml")
        $xmlwriter = New-Object System.Xml.XmlTextWriter($fmlistxml, [System.Text.Encoding]::UTF8)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 4
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("FMCollectionManifest")
        $xmlwriter.WriteAttributeString("xmlns", "xsi", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema-instance")
        $xmlwriter.WriteAttributeString("xmlns", "xsd", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema")
        $xmlwriter.WriteAttributeString("xmlns", [IoTFMXML]::xmlns)
        $xmlwriter.WriteAttributeString("Product", "IoTUAP")
        $xmlwriter.WriteElementString("IsBuildFeatureEnabled", "true")
        $xmlwriter.WriteStartElement("FMs")
        foreach ($fm in $fmlist) {
            $xmlwriter.WriteStartElement("FM")
            $xmlwriter.WriteAttributeString("ID", $fm)
            $xmlwriter.WriteAttributeString("Path", "`$(FMDirectory)\$($fm)FM.xml")
            $xmlwriter.WriteAttributeString("ReleaseType", "Production")
            $xmlwriter.WriteAttributeString("OwnerName", "OEM_NAME")
            $xmlwriter.WriteAttributeString("OwnerType", "OEM")
            $xmlwriter.WriteAttributeString("CPUType", $arch.ToUpper())
            $xmlwriter.WriteAttributeString("Critical", "true")
            $xmlwriter.WriteEndElement() #FM element
        }
        $xmlwriter.WriteEndElement() #FMs element
        $xmlwriter.WriteStartElement("SupportedResolutions")
        $xmlwriter.WriteElementString("Resolution", "1024x768")
        $xmlwriter.WriteEndElement() # SupportedResolutions element
        $xmlwriter.WriteStartElement("SupportedLanguages")
        $xmlwriter.WriteElementString("Language", "en-US")
        $xmlwriter.WriteEndElement() # SupportedLanguages element
        $xmlwriter.WriteStartElement("SupportedLocales")
        $xmlwriter.WriteElementString("Locale", "en-US")
        $xmlwriter.WriteEndElement() # SupportedLocales element

        $xmlwriter.WriteEndElement() # FMCollectionManifest element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()
    }

    [string[]] GetFeatureIDs() {
        $fidKind = if ($this.IsOEM) { "OEM" } else { "Microsoft" }
        $fids = ($this.XmlDoc.FeatureManifest.Features | Select-Object -exp $fidKind).PackageFile.FeatureIDs.FeatureID | Sort-Object -Unique
        return @() + $fids  # prevent returning null
    }

    [string[]] GetPackageNames() {
        $pkgnames = $this.XmlDoc.GetElementsByTagName("PackageFile") | Foreach-Object {$_.Name} | Sort-Object
        return @() + $pkgnames  # prevent returning null
    }

    [string[]] GetPackageFullNames() {
        $retval = @()
        $pkglist = $this.XmlDoc.GetElementsByTagName("PackageFile")
        if ($pkglist -ne $null) {
            foreach ($pkg in $pkglist) {
                $retval += Expand-IoTPath "$($pkg.Path)\$($pkg.Name)"
            }
        }
        return $retval | Sort-Object
    }

    [Boolean] ValidatePackages([string] $config) {
        $retval = $true
        $pkglist = $this.XmlDoc.GetElementsByTagName("PackageFile")
        if ($pkglist -ine $null) {
            foreach ($pkg in $pkglist) {
                $fullname = Expand-IoTPath "$($pkg.Path)\$($pkg.Name)"
                #check if cab file exists
                if (!(Test-Path $fullname)) {
                    Publish-Error "Missing $fullname"
                    $retval = $false
                }
                else {
                    $result = Test-IoTCabSignature $fullname $config
                    if (!$result) { $retval = $false }
                }
            }
        }
        else {
            Publish-Error "No packages found"
            retval = $false
        }
        return $retval
    }

    [Boolean] IsPackagePresent([string] $pkgname) {
        $existingpkgs = $this.GetPackageNames()
        return $existingpkgs.Contains($pkgname)
    }

    [Boolean] IsFeaturePresent([string] $fid) {
        $existingfids = $this.GetFeatureIDs()
        return $existingfids.Contains($fid)
    }

    [string[]] GetBasePackages() {
        return $this.XmlDoc.FeatureManifest.BasePackages.PackageFile | Foreach-Object {$_.Name}
    }

    [string[]] GetPackagesForFeature([string] $fid) {
        $fidKind = if ($this.IsOEM) { "OEM" } else { "Microsoft" }
        $pkgsNode = ($this.XmlDoc.FeatureManifest.Features | Select-Object -exp $fidKind).PackageFile

        # For each package, find the ones associated with this feature. Then return the package names.
        $retval = $pkgsNode | Where-Object { @($_.FeatureIDs.FeatureID) -contains $fid } | ForEach-Object { $_.Name }

        if ($retval.Count -eq 0) { Publish-Error "$fid not found" }
        return $retval
    }

    [string[]] GetFeatureForPackage([string] $pkgname) {
        $retval = @()
        $fidKind = if ($this.IsOEM) { "OEM" } else { "Microsoft" }
        $pkgNode = ($this.XmlDoc.FeatureManifest.Features | Select-Object -exp $fidKind).PackageFile |  Where-Object { ($_.Name) -ieq $pkgname }
        if ($pkgNode) {
            $retval += $pkgNode.FeatureIDs.FeatureID
        }
        else {
            $pkgNode = $this.XmlDoc.FeatureManifest.BasePackages.PackageFile |  Where-Object { ($_.Name) -ieq $pkgname }
            if ($pkgNode) {
                $retval += "Base"
            }
            else { Publish-Warning "No feature defined for $pkgname" }
        }
        # For each package, find the ones with this name and return the featureids.
        return $retval
    }

    [void] AddOEMPackage([string] $pkgpath, [string] $pkgname, [string[]] $featureid) {
        if ($this.IsPackagePresent($pkgname)) {
            Publish-Error "$pkgname already defined in FM file"
            return
        }
        $newpkg = $this.XmlDoc.CreateElement("PackageFile", [IoTFMXML]::xmlns)
        $nameattr = $this.XmlDoc.CreateAttribute("Name")
        $nameattr.Value = $pkgname
        $pathattr = $this.XmlDoc.CreateAttribute("Path")
        $pathattr.Value = $pkgpath
        $newpkg.Attributes.Append($pathattr)
        $newpkg.Attributes.Append($nameattr)

        if ([string]::IsNullOrWhiteSpace($featureid)) {
            #if feature id is null, use the pkg name as the feature id
            $feature = $pkgname.ToUpper()
            $feature = $feature.Replace("%OEM_NAME%.", "")
            $feature = $feature.Replace(".CAB", "")
            $feature = $feature.Replace(".", "_")
            $featureid = @($feature)
            Write-Verbose "$featureid"
        }

        if ($featureid[0] -ieq "Base") {
            $node = $this.XmlDoc.FeatureManifest.BasePackages
            Write-Verbose "Adding pkgname: $pkgname to Base"
            $node.AppendChild($newpkg)
        }
        else {
            $node = $this.XmlDoc.FeatureManifest.Features.OEM
            Write-Verbose "Adding pkgname: $pkgname"
            $fids = $this.XmlDoc.CreateElement("FeatureIDs", [IoTFMXML]::xmlns)
            foreach ($feature in $featureid ) {
                Write-Verbose "Adding FeatureID: $feature"
                #add feature id information
                $fid = $this.XmlDoc.CreateElement("FeatureID", [IoTFMXML]::xmlns)
                $fid.InnerXml = $feature
                $fids.AppendChild($fid)
            }
            $newpkg.AppendChild($fids)
            $node.AppendChild($newpkg)
        }
        $this.XmlDoc.Save($this.FileName)
    }

    [IoTDeviceLayout] GetDeviceLayout([string] $socid) {
        $dlpkgs = $this.XmlDoc.FeatureManifest.DeviceLayoutPackages
        if ($dlpkgs -eq $null) {
            Publish-Error "Devicelayouts not found in this fm file"
            return $null
        }
        $dlayouts = $dlpkgs.PackageFile
        $dlfile = "" ; $dlpath = ""
        foreach ($dl in $dlayouts) {
            if ($dl.SOC -ieq $socid) {
                $dlfile = $dl.Name
                $dlpath = $dl.Path
                break
            }
        }

        $dlxml = ""
        Write-Verbose "DeviceLayout:$dlfile"
        if ($dlpath -ieq "%PKGBLD_DIR%") {
            # the device layout file will be in the bsp src dir if its built locally
            $dlfile = $dlfile.Replace("%OEM_NAME%.", "")
            $dlfile = $dlfile.Replace(".cab", "")
            $dldir = (Get-ChildItem $env:BSPSRC_DIR, $env:COMMON_DIR -Filter $dlfile -Directory -Recurse) | foreach-object {$_.FullName}
            if ($dldir -eq $null) {
                Publish-Error "Device layout $dlfile not found"
                return $null
            }
            $dlxml = $dldir + "\DeviceLayout.xml"
        }
        else {
            # The device layout file will be in the prebuilt directory. So we need to unpack from the cab
            $dlpath = Expand-IoTPath $dlpath
            $dlcab = "$dlpath\$dlfile"
            if (!(Test-Path $dlcab)) { Publish-Error "Device layout $dlcab not found"; return $null }
            
            # Expand cab to get required binaries to a temp dir
            cmd /r "expand $dlcab $env:TMP -F:*" | Out-Null
            $dlxml = Get-ChildItem -Path $env:TMP -Recurse -Filter "DeviceLayout.xml"  | Foreach-Object {$_.FullName}
            if ($dlxml -eq $null) {
                Publish-Error "Devicelayout xml not found in $dlcab"
                return $null
            }
            #TODO: Check signature of the binaries
        }
        Write-Verbose "Device Layout xml : $dlxml"
        $dlobj = New-IoTDeviceLayout $dlxml
        Clear-Temp
        return $dlobj
    }
}
