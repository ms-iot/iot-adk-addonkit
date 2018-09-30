<#
IoTProvisioningXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTProvisioningXML {
    [string] $FileName
    [xml] $XmlDoc
    static [string] $xmlns = "urn:schemas-microsoft-com:windows-provisioning"
    static [string[]] $ConfigKeys = @( 'ID', 'Name', 'Version', 'OwnerType', 'Rank')
    #constructor
    IoTProvisioningXML([string]$provxml, [Boolean]$Create) {
        $fileexist = Test-Path $provxml -PathType Leaf
        if (!$Create -and !$fileexist ) {throw "$provxml file not found" }
        $this.FileName = $provxml
        if ($Create) {  
            if (!$fileexist ) {
                Publish-Status "Creating $provxml..." 
                $this.CreateProvXML()
            }
            else { Publish-Warning "$provxml already exists, opening existing file" }
        }
        $this.XmlDoc = [xml]( Get-Content -Path $provxml)
    }

    hidden [void] CreateProvXML() {
        $guid = [System.Guid]::NewGuid().toString()
        $ProvWriter = New-Object System.Xml.XmlTextWriter($this.Filename, [System.Text.Encoding]::UTF8)
        $ProvWriter.Formatting = "Indented"
        $ProvWriter.Indentation = 4
        $ProvWriter.WriteStartDocument()
        $ProvWriter.WriteStartElement("WindowsCustomizations")
        $ProvWriter.WriteStartElement("PackageConfig")
        $ProvWriter.WriteAttributeString("xmlns", "urn:schemas-Microsoft-com:Windows-ICD-Package-Config.v1.0")
        $ProvWriter.WriteElementString("ID", "{$guid}" )
        $ProvWriter.WriteElementString("Name", "NewProv")
        $ProvWriter.WriteElementString("Version", "1.0")
        $ProvWriter.WriteElementString("OwnerType", "OEM")
        $ProvWriter.WriteElementString("Rank", "0")
        $ProvWriter.WriteEndElement() # PackageConfig element
        $ProvWriter.WriteStartElement("Settings")
        $ProvWriter.WriteAttributeString("xmlns", [IoTProvisioningXML]::xmlns )
        $ProvWriter.WriteStartElement("Customizations")
        $ProvWriter.WriteStartElement("Common")
        $ProvWriter.WriteComment("Common settings here")

        $ProvWriter.WriteEndElement() # Common element
        $ProvWriter.WriteEndElement() # Customizations element
        $ProvWriter.WriteEndElement() # Settings element
        $ProvWriter.WriteEndElement() # WindowsCustomizations element
        $ProvWriter.WriteEndDocument()
        $ProvWriter.Flush()
        $ProvWriter.Close()
    }

    [void] CreateICDProject() {
        $provdir = Split-Path -Path $this.Filename -Parent
        $config = $this.GetPackageConfig()
        $icdproj = "$provdir\$($config.Name).icdproj.xml"
        Remove-ItemIfExist $icdproj

        $ProvWriter = New-Object System.Xml.XmlTextWriter($icdproj, [System.Text.Encoding]::UTF8)
        $ProvWriter.Formatting = "Indented"
        $ProvWriter.Indentation = 4
        $ProvWriter.WriteStartDocument()
        $ProvWriter.WriteStartElement("ICDProject")
        $ProvWriter.WriteAttributeString("Name", $config.Name)
        $ProvWriter.WriteAttributeString("Description", "")
        $ProvWriter.WriteAttributeString("Version", $env:ADK_VERSION)
        $ProvWriter.WriteAttributeString("Id", $config.ID)
        $ProvWriter.WriteAttributeString("TemplateName", "Provisioning package")
        $ProvWriter.WriteAttributeString("TemplateType", "ProvisioningPackage")
        $ProvWriter.WriteStartElement("TargetEditions")
        $ProvWriter.WriteStartElement("Sku")
        $ProvWriter.WriteElementString("StoreType", "File")
        $ProvWriter.WriteElementString("Name", "Windows 10 IoT Core")
        $ProvWriter.WriteElementString("SourcePath", "Microsoft-IoTUAP-Provisioning.dat")
        $ProvWriter.WriteElementString("Edition", "Athens")
        $ProvWriter.WriteElementString("Version", "10")
        $ProvWriter.WriteElementString("Description", "Selecting this option will display settings that are specific to the Windows 10 IoT Core edition as well as settings that are common to all Windows editions.")
        $ProvWriter.WriteEndElement() # Sku element
        $ProvWriter.WriteEndElement() # TargetEditions element
        $ProvWriter.WriteEndElement() # ICDProject element
        $ProvWriter.WriteEndDocument()
        $ProvWriter.Flush()
        $ProvWriter.Close()
    }    

    [hashtable] GetPackageConfig() {
        $retval = @{}
        foreach ($key in [IoTProvisioningXML]::ConfigKeys) {
            Write-Debug "Reading $key"
            $node = $this.XmlDoc.WindowsCustomizations.PackageConfig.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetPackageConfig([hashtable] $config) {
        foreach ($key in $config.Keys) {
            if ([IoTProvisioningXML]::ConfigKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $this.XmlDoc.WindowsCustomizations.PackageConfig.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.XmlDoc.Save($this.FileName)
    }

    [void] SetVersion([string] $version) {
        $this.XmlDoc.WindowsCustomizations.PackageConfig.Version = $version
        $this.XmlDoc.Save($this.FileName)
    }

    [void] IncrementVersion() {
        $version = $this.XmlDoc.WindowsCustomizations.PackageConfig.Version
        $verparts = $version.Split(".")
        if ($verparts.Count -gt 0) {
            $verlast = $verparts.Count - 1
            if ($verlast) {
                [Int32]$rev = [convert]::ToInt32($verparts[$verlast], 10) + 1
                $verparts[$verlast] = $rev.ToString()
                $version = [system.String]::Join(".", $verparts)
            }
            $this.XmlDoc.WindowsCustomizations.PackageConfig.Version = $version
            $this.XmlDoc.Save($this.FileName)
        }
        else
        {
            Publish-Error "Incorrect version format : $version"
        }
    }

    [void] AddPolicy([string]$group, [string] $name, [string] $value) {
        # No validation of the inputs here. Expect this to be correct.
        # get the node with the policy name ( expecting only one so select first to get rid of array)
        $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName($name)  | Select-Object -First 1
        if ($node) {
            Write-Debug "Found $name, with old value $($node.InnerText), updating to $value"
            # the policy node already exists, just update the value.
            $node.InnerText = $value
            $this.XmlDoc.Save($this.FileName)
            return
        }
        # node not existing. So create the element
        $policyelement = $this.XmlDoc.CreateElement($name, [IoTProvisioningXML]::xmlns)
        $policyelement.InnerText = $value
        # Check for the group node
        $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName($group)  | Select-Object -First 1
        if ($node) {
            Write-Debug "Found $group, adding $name"
            $node.AppendChild($policyelement)
            $this.XmlDoc.Save($this.FileName)
            return
        }
        #group node not existing, so create the element
        $policygroup = $this.XmlDoc.CreateElement($group, [IoTProvisioningXML]::xmlns)
        $policygroup.AppendChild($policyelement)
        #check for the policies node 
        $node = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common.Policies
        if ($node) {
            Write-Debug "Found Policies, adding $group\$name"
            $node.AppendChild($policygroup)
            $this.XmlDoc.Save($this.FileName)
            return  
        }
        #policies node not existing, so create the element
        $policiesnode = $this.XmlDoc.CreateElement("Policies", [IoTProvisioningXML]::xmlns)
        $policiesnode.AppendChild($policygroup)
        $commonnode = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common
        Write-Debug "Not found Policies, adding Policies\$group\$name"
        $commonnode.AppendChild($policiesnode)
        $this.XmlDoc.Save($this.FileName)
    }

    [void] AddStartupSettings([string]$AppName, [string]$AppType ) {

        $commonnode = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common
        if ($AppType -ieq "fga") {
            $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName("StartupApp")  | Select-Object -First 1
            if ($node) {
                Publish-Error "StartupApp is already defined"
                return
            }
            $default = $this.XmlDoc.CreateElement("Default", [IoTProvisioningXML]::xmlns)
            $default.InnerText = $AppName
            $startup = $this.XmlDoc.CreateElement("StartupApp", [IoTProvisioningXML]::xmlns)
            $startup.AppendChild($default)
            $commonnode.AppendChild($startup)
        }
        else {
            $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName("Add")  | Where-Object { $_.PackageName -ieq $AppName }
            if ($node) {
                Publish-Error "$AppName is already defined as a background task"
                return
            }
            $PkgName = $this.XmlDoc.CreateAttribute("PackageName")
            $PkgName.Value = $AppName
            $addnode = $this.XmlDoc.CreateElement("Add", [IoTProvisioningXML]::xmlns)
            $addnode.Attributes.Append($PkgName)
            $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName("ToAdd")  | Select-Object -First 1
            if ($node) {
                $node.AppendChild($addnode)
                $this.XmlDoc.Save($this.FileName)
            }
            else {
                $toaddnode = $this.XmlDoc.CreateElement("ToAdd", [IoTProvisioningXML]::xmlns)
                $toaddnode.AppendChild($addnode)
                $bgtnode = $this.XmlDoc.CreateElement("StartupBackgroundTasks", [IoTProvisioningXML]::xmlns)
                $bgtnode.AppendChild($toaddnode)
                $commonnode.AppendChild($bgtnode)
            }
        }
        $this.XmlDoc.Save($this.FileName)
    }
    
    [void] AddUniversalAppInstall([string]$FamilyName, [string]$AppName, [string[]]$Dependency, [string]$LicenseId, [string]$Licensefile ) {
        $node = $this.XmlDoc.WindowsCustomizations.Settings.GetElementsByTagName("UniversalAppInstall")  | Select-Object -First 1
        if ($node) {
            Publish-Error "UniversalAppInstall is already defined, multiple appx in one ppkg is currently not supported"
            return
        }
        $DAFnode = $this.XmlDoc.CreateElement("DependencyAppxFiles", [IoTProvisioningXML]::xmlns)
        foreach ($dep in $Dependency) {
            $depname = $this.XmlDoc.CreateAttribute("Name")
            $depname.Value = $dep.Replace(".appx", "")
            $depnode = $this.XmlDoc.CreateElement("Dependency", [IoTProvisioningXML]::xmlns)
            $depnode.InnerText = $dep
            $depnode.Attributes.Append($depname)
            $DAFnode.AppendChild($depnode)
        }
        $AFnode = $this.XmlDoc.CreateElement("ApplicationFile", [IoTProvisioningXML]::xmlns)
        $AFnode.InnerText = $AppName
        $PFNattr = $this.XmlDoc.CreateAttribute("PackageFamilyName")
        $PFNattr.Value = $FamilyName
        $Nameattr = $this.XmlDoc.CreateAttribute("Name")
        $Nameattr.Value = $AppName.Replace(".appxbundle", "")
        $Nameattr.Value = $AppName.Replace(".appx", "")        
        $Anode = $this.XmlDoc.CreateElement("Application", [IoTProvisioningXML]::xmlns)
        $Anode.Attributes.Append($PFNattr)
        $Anode.Attributes.Append($Nameattr)
        $Anode.AppendChild($AFnode)
        $Anode.AppendChild($DAFnode)
        $UCAnode = $this.XmlDoc.CreateElement("UserContextApp", [IoTProvisioningXML]::xmlns)
        $UCAnode.AppendChild($Anode)
        $UAInode = $this.XmlDoc.CreateElement("UniversalAppInstall", [IoTProvisioningXML]::xmlns)
        $UAInode.AppendChild($UCAnode)

        if (!([string]::IsNullOrWhiteSpace($LicenseId))) {
            $LPIattr = $this.XmlDoc.CreateAttribute("LicenseProductId")
            $LPIattr.Value = $LicenseId
            $Nameattr = $this.XmlDoc.CreateAttribute("Name")
            $Nameattr.Value = $LicenseId       
            $LInode = $this.XmlDoc.CreateElement("LicenseInstall", [IoTProvisioningXML]::xmlns)
            $LInode.InnerText = $Licensefile
            $LInode.Attributes.Append($LPIattr)
            $LInode.Attributes.Append($Nameattr)
            $UCALnode = $this.XmlDoc.CreateElement("UserContextAppLicense", [IoTProvisioningXML]::xmlns)
            $UCALnode.AppendChild($LInode)
            $UAInode.AppendChild($UCALnode)
        }
        $common = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common
        $common.AppendChild($UAInode)
        $this.XmlDoc.Save($this.FileName)
    }

    [void] AddRootCertificate([string] $certfile) {
        if (!(Test-Path $certfile)) {
            Publish-Error " $certfile not found"
            return
        }

        # Get the cert details - Thumbprint and Certname
        $certname = Split-Path $certfile -Leaf

        # X509Certificate2 object that will represent the certificate
        $certobj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

        # Imports the certificate from file to x509Certificate object
        $certobj.Import($certfile)
        Publish-Status "Processing $certname with thumbprint $($certobj.Thumbprint)"

        # Check if rootcerts are present and if so does it contain this thumbprint
        $rootcertlist = $this.XmlDoc.GetElementsByTagName("RootCertificate") | Where-Object { $_.CertificateName -eq $certobj.Thumbprint }
        if ($null -ine $rootcertlist) {
            Publish-Error "Cert already present"
            return
        }

        # Cert is not present, so prepare to add the cert
        $newnode = $this.XmlDoc.CreateElement("RootCertificate", [IoTProvisioningXML]::xmlns)

        # Add the CertificateName attribute
        $certnameattr = $this.XmlDoc.CreateAttribute("CertificateName")
        $certnameattr.Value = $certobj.Thumbprint
        $newnode.Attributes.Append($certnameattr)

        # Add the name attribute
        $nameattr = $this.XmlDoc.CreateAttribute("Name")
        $nameattr.Value = $certname
        $newnode.Attributes.Append($nameattr)

        # Add the CertificatePath Element
        $cerpath = $this.XmlDoc.CreateElement("CertificatePath", [IoTProvisioningXML]::xmlns)
        $cerpath.InnerText = $certname
        $newnode.AppendChild($cerpath)

        # New node is ready. Check if Certificates\Rootcertificates node are present.
        $commonnode = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common
        $node = $commonnode.Certificates.RootCertificates
        if ($node) {
            # RootCertificates node is present, so add the newnode to it.
            $node.AppendChild($newnode)
        }
        else {
            $rootelement = $this.XmlDoc.CreateElement("RootCertificates", [IoTProvisioningXML]::xmlns)
            $rootelement.AppendChild($newnode)
            $certnode = $commonnode.Certificates
            if ($certnode) { 
                # Certificates node is present, so add the rootelement to it.
                $certnode.AppendChild($rootelement) 
            }
            else {
                $certelement = $this.XmlDoc.CreateElement("Certificates", [IoTProvisioningXML]::xmlns)
                $certelement.AppendChild($rootelement)
                $commonnode.AppendChild($certelement)
            }
        }
        # Finally, copy the cert to the provxml directory
        $provpath = Split-Path $this.FileName -Parent
        Copy-Item -Path $certfile -Destination $provpath | Out-Null
        $this.IncrementVersion() # this function saves the xml file
    }

    [void] RemoveRootCertificate([string] $certname) {
        # Check if cert is present in the xml
        $certnode = $this.XmlDoc.GetElementsByTagName("RootCertificate") | Where-Object { $_.Name -eq $certname }
        if ($null -ine $certnode) {
            $parentnode = $certnode.ParentNode
            $oldnode = $parentnode.RemoveChild($certnode)
            Publish-Status "$certname removed"

            if (!$parentnode.ChildNodes.Count) {
                # Only one cert in the prov xml, then remove the redundant RootCertificates node
                Publish-Status "Removing parent nodes"
                $gpnode = $parentnode.ParentNode
                $oldnode = $gpnode.RemoveChild($parentnode)
                if (!$gpnode.ChildNodes.Count) {
                    $oldnode = $gpnode.ParentNode.RemoveChild($gpnode)
                }
            }
            $this.IncrementVersion() # this one saves the xml file
            $provpath = Split-Path $this.FileName -Parent
            Remove-Item -Path "$provpath\$certname" | Out-Null
        }
        else { Publish-Error "$certname not found" }
    }

    [void] AddTrustedProvCertificate([string] $certfile) {
        if (!(Test-Path $certfile)) {
            Publish-Error " $certfile not found"
            return
        }

        # Get the cert details - Thumbprint and Certname
        $certname = Split-Path $certfile -Leaf

        # X509Certificate2 object that will represent the certificate
        $certobj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2

        # Imports the certificate from file to x509Certificate object
        $certobj.Import($certfile)
        Publish-Status "Processing $certname with thumbprint $($certobj.Thumbprint)"

        # Check if rootcerts are present and if so does it contain this thumbprint
        $rootcertlist = $this.XmlDoc.GetElementsByTagName("Certificate") | Where-Object { $_.CertificateHash -eq $certobj.Thumbprint }
        if ($null -ine $rootcertlist) {
            Publish-Error "Cert already present"
            return
        }

        # Cert is not present, so prepare to add the cert
        $newnode = $this.XmlDoc.CreateElement("Certificate", [IoTProvisioningXML]::xmlns)

        # Add the CertificateHash attribute
        $certnameattr = $this.XmlDoc.CreateAttribute("CertificateHash")
        $certnameattr.Value = $certobj.Thumbprint
        $newnode.Attributes.Append($certnameattr)

        # Add the name attribute
        $nameattr = $this.XmlDoc.CreateAttribute("Name")
        $nameattr.Value = $certname
        $newnode.Attributes.Append($nameattr)

        # Add the TrustedProvisioner Element
        $cerpath = $this.XmlDoc.CreateElement("TrustedProvisioner", [IoTProvisioningXML]::xmlns)
        $cerpath.InnerText = $certname
        $newnode.AppendChild($cerpath)

        # New node is ready. Check if Certificates\TrustedProvisioners node are present.
        $commonnode = $this.XmlDoc.WindowsCustomizations.Settings.Customizations.Common
        $node = $commonnode.Certificates.TrustedProvisioners
        if ($node) {
            # TrustedProvisioners node is present, so add the newnode to it.
            $node.AppendChild($newnode)
        }
        else {
            $rootelement = $this.XmlDoc.CreateElement("TrustedProvisioners", [IoTProvisioningXML]::xmlns)
            $rootelement.AppendChild($newnode)
            $certnode = $commonnode.Certificates
            if ($certnode) { 
                # Certificates node is present, so add the rootelement to it.
                $certnode.AppendChild($rootelement) 
            }
            else {
                $certelement = $this.XmlDoc.CreateElement("Certificates", [IoTProvisioningXML]::xmlns)
                $certelement.AppendChild($rootelement)
                $commonnode.AppendChild($certelement)
            }
        }
        # Finally, copy the cert to the provxml directory
        $provpath = Split-Path $this.FileName -Parent
        Copy-Item -Path $certfile -Destination $provpath | Out-Null
        $this.IncrementVersion() # this function saves the xml file
    }

    [void] RemoveTrustedProvCertificate([string] $certname) {
        # Check if cert is present in the xml
        $certnode = $this.XmlDoc.GetElementsByTagName("Certificate") | Where-Object { $_.Name -eq $certname }
        if ($null -ine $certnode) {
            $parentnode = $certnode.ParentNode
            $oldnode = $parentnode.RemoveChild($certnode)
            Publish-Status "$certname removed"

            if (!$parentnode.ChildNodes.Count) {
                # Only one cert in the prov xml, then remove the redundant TrustedProvisioners node
                Publish-Status "Removing parent nodes"
                $gpnode = $parentnode.ParentNode
                $oldnode = $gpnode.RemoveChild($parentnode)
                if (!$gpnode.ChildNodes.Count) {
                    # remove the redundant Certificates node
                    $oldnode = $gpnode.ParentNode.RemoveChild($gpnode)
                }
            }
            $this.IncrementVersion() # this one saves the xml file
            $provpath = Split-Path $this.FileName -Parent
            Remove-Item -Path "$provpath\$certname" | Out-Null
        }
        else { Publish-Error "$certname not found" }
    }


}
