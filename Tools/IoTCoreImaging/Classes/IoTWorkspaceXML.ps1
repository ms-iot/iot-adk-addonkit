<#
This contains IoTWorkspaceXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTWorkspaceXML {
    [string] $FileName
    [xml] $XmlDoc
    static [string[]] $ConfigKeys = @( 'OemName', 'BuildDir', 'MSPkgRoot', 'eWDK_ISO', 'WindowsSDKVersion', 'EVSignToolParam', 'RetailSignToolParam') 
    static [string[]] $EnvArchs = @("arm", "x64", "x86", "arm64")
    static [string[]] $EnvConfigKeys = @("BSPVersion", "BSPPkgDir")
    # Constructor
    IoTWorkspaceXML([string]$wsxml, [Boolean]$Create, [string]$oemName) {
        $fileexist = Test-Path $wsxml -PathType Leaf
        if (!$Create -and !$fileexist ) { throw "$wsxml file not found" }
        $this.FileName = $wsxml
        if ($Create) {
            if (!$fileexist) {
                $this.CreateWSXML($oemName)
            }
            else { Publish-Warning "$wsxml already exists, opening existing file" }
        }
        $this.XmlDoc = [xml]( Get-Content -Path $wsxml)
    }

    hidden [void] CreateWSXML([string]$oemName) {
        #TODO Replace this long fn with copy from a template file.
        # Create the directory 
        $DirName = Split-Path -Path $this.FileName -Parent
        New-DirIfNotExist $DirName
        Write-Verbose "Creating $($this.FileName)..."

        # Write IoTWorkspace xml
        $xmlwriter = New-Object System.Xml.XmlTextWriter($this.FileName, [System.Text.Encoding]::UTF8)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 4
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("IoTWorkspace")
        $xmlwriter.WriteComment("Current active configuration")
        $xmlwriter.WriteElementString("CurrentEnv", "undefined")

        # Write the Config settings
        $xmlwriter.WriteStartElement("Config")
        $xmlwriter.WriteElementString("OemName", $oemName)
        $xmlwriter.WriteComment("Default build output directory")
        $xmlwriter.WriteElementString("BuildDir", "%IOTWKSPACE%\Build\%BSP_ARCH%")
        $xmlwriter.WriteComment("IoT Core kit package location, default is Windows10KitsRoot")
        $xmlwriter.WriteElementString("MSPkgRoot", "")
        $xmlwriter.WriteElementString("eWDK_ISO", "")
        $xmlwriter.WriteElementString("WindowsSDKVersion", "10.0.16299.0")
        $xmlwriter.WriteComment("Specify the ev signing certificate details, Format given below ")
        $xmlwriter.WriteComment("/s my /i `"Issuer`" /n `"Subject`" /fd SHA256")
        $xmlwriter.WriteElementString("EVSignToolParam", "")
        $xmlwriter.WriteComment("Specify the retail signing certificate details, Format given below ")
        $xmlwriter.WriteComment("/s my /i `"Issuer`" /n `"Subject`" /ac `"C:\CrossCertRoot.cer`" /fd SHA256")
        $xmlwriter.WriteElementString("RetailSignToolParam", "")
        $xmlwriter.WriteEndElement() # Config element
       
        $xmlwriter.WriteStartElement("Security")
        $xmlwriter.WriteStartElement("SecureBoot")
        $xmlwriter.WriteElementString("PlatformKey", "")
        $xmlwriter.WriteElementString("KeyExchangeKey", "")
        $xmlwriter.WriteStartElement("Database")
        $xmlwriter.WriteElementString("Test", "")
        $xmlwriter.WriteElementString("Retail", "")
        $xmlwriter.WriteEndElement() # Database element
        $xmlwriter.WriteEndElement() # SecureBoot element

        $xmlwriter.WriteStartElement("BitLocker")
        $xmlwriter.WriteElementString("DataRecoveryAgent", "")
        $xmlwriter.WriteEndElement() # BitLocker element
       
        $xmlwriter.WriteStartElement("SIPolicy")
        $xmlwriter.WriteElementString("Update", "")
        $xmlwriter.WriteStartElement("User")
        $xmlwriter.WriteElementString("Test", "")
        $xmlwriter.WriteElementString("Retail", "")
        $xmlwriter.WriteEndElement() # User element
        $xmlwriter.WriteStartElement("Kernel")
        $xmlwriter.WriteElementString("Test", "")
        $xmlwriter.WriteElementString("Retail", "")
        $xmlwriter.WriteEndElement() # Kernel element                
        $xmlwriter.WriteEndElement() # SIPolicy element
        $xmlwriter.WriteEndElement() # Security element
        $xmlwriter.WriteEndElement() # IoTWorkspace element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()

        # Create the Common directories as well
        $commondir = "$DirName\Common\Packages"
        New-DirIfNotExist $commondir

        # Create the cert directories as well
        $certdir = "$DirName\Certs"
        New-DirIfNotExist $certdir

        # Create the OEMCommonFM.xml file
        $oemcommonfm = "$DirName\Common\Packages\OEMCommonFM.xml"
        if (Test-Path $oemcommonfm) {
            Write-Verbose "OEMCommonFM already exists"
        }
        else {
            $fmxml = New-IoTFMXML $oemcommonfm  -Create
            Write-Verbose "OEMCommonFM.xml : $($fmxml.Filename)"
        }
    }

    [Boolean] AddEnv([string] $Arch) {
        if ([IoTWorkspaceXML]::EnvArchs -notcontains $Arch) {
            throw "Invalid architecture $Arch"
        }

        # make sure we dont have this entry already
        $existingarchs = $this.XmlDoc.IoTWorkspace.Env | ForEach-Object {$_.Name}
        if (($existingarchs) -and ( $existingarchs -contains $Arch)) { 
            Publish-Error "$Arch already defined"
            return $false
        }
        $newenv = $this.XmlDoc.CreateElement("Env")
        $nameattr = $this.XmlDoc.CreateAttribute("Name")
        $nameattr.Value = $Arch
        $newenv.Attributes.Append($nameattr)
        $bspver = $this.XmlDoc.CreateElement("BSPVersion")
        $bspver.InnerText = "10.0.0.0"
        $newenv.AppendChild($bspver)
        $bspdir = $this.XmlDoc.CreateElement("BSPPkgDir")
        $bspdir.InnerText = "%PKGBLD_DIR%"                      # TODO: Does this even need to be an argument?
        $newenv.AppendChild($bspdir)
        $this.XmlDoc.IoTWorkspace.AppendChild($newenv)
        $currentarch = $this.GetCurrentEnv()
        if ($currentarch -ieq "undefined") {
            $this.XmlDoc.IoTWorkspace.CurrentEnv = $Arch
        }
        $this.Save()

        # Create the directories
        $iotwsroot = Split-Path -Path $this.FileName -Parent
        $iotsrcroot = "$iotwsroot\Source-$($arch)"

        # Check if dir is already present, if so skip this.
        if (Test-Path $iotsrcroot) {
            Publish-Warning "$iotsrcroot already exists."
            return $true
        }
        New-Item -Path "$iotwsroot\Source-$($arch)\Packages" -ItemType Directory | Out-Null
        $fmxml = New-IoTFMXML "$iotwsroot\Source-$($arch)\Packages\OEMFM.xml" -Create
        Write-Verbose "OEMFM.xml : $($fmxml.Filename)"
        $archi = $Arch
        if ($archi -ieq "x64") { $archi = "amd64" }
        $fmxml.CreateFMList(@("OEM", "OEMCOMMON"), $archi)
        New-Item -Path "$iotwsroot\Source-$($arch)\Products" -ItemType Directory | Out-Null
        New-Item -Path "$iotwsroot\Source-$($arch)\BSP" -ItemType Directory | Out-Null
        return $true
    }

    [string] GetCurrentEnv() {
        return $this.XmlDoc.IoTWorkspace.CurrentEnv
    }

    [Boolean] SetCurrentEnv([string] $arch) {
        $retval = $false
        $supportedarchs = $this.XmlDoc.IoTWorkspace.Env | ForEach-Object {$_.Name}
        if ($supportedarchs -notcontains $arch) { 
            Publish-Error "$arch is not supported"
        }
        else {
            $this.XmlDoc.IoTWorkspace.CurrentEnv = $arch
            $retval = $true
            $this.Save()
        }
        return $retval
    }

    [void] Save() {
        $this.XmlDoc.Save($this.FileName)
    }

    [string] GetVersion() {
        $arch = $this.XmlDoc.IoTWorkspace.CurrentEnv
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        return $envnode.BSPVersion
    }

    [void] SetVersion([string] $version) {
        $arch = $this.XmlDoc.IoTWorkspace.CurrentEnv
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        #TODO Validate version format
        $envnode.BSPVersion = $version
        $this.Save()
    }

    [string] GetBSPPkgDir() {
        $arch = $this.XmlDoc.IoTWorkspace.CurrentEnv
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        return $envnode.BSPPkgDir
    }

    [void] SetBSPPkgDir([string] $bsppkgdir) {
        $arch = $this.XmlDoc.IoTWorkspace.CurrentEnv
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        #TODO Validate version format
        $envnode.BSPPkgDir = $bsppkgdir
        $this.Save()
    }

    [hashtable] GetEnvConfig([string] $arch) {
        $retval = @{}
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        if (!$envnode) {
            Publish-Error "$arch not supported"
            return $retval
        }
        foreach ($key in [IoTWorkspaceXML]::EnvConfigKeys) {
            Write-Debug "Reading $key"
            $node = $envnode.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetEnvConfig([string]$arch, [hashtable] $config) {
        $envnode = $this.XmlDoc.IoTWorkspace.Env | Where-Object {$_.Name -ieq $arch}
        if (!$envnode) {
            Publish-Error "$arch not supported"
        }
        foreach ($key in $config.Keys) {
            if ([IoTWorkspaceXML]::EnvConfigKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $envnode.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.Save()
    }    

    [hashtable] GetConfig() {
        $retval = @{}
        foreach ($key in [IoTWorkspaceXML]::ConfigKeys) {
            Write-Debug "Reading $key"
            $node = $this.XmlDoc.IoTWorkspace.Config.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "value : $($node.InnerText)"
            $retval.Add($key, $node.InnerText)
        }
        return $retval
    }

    [void] SetConfig([hashtable] $config) {
        foreach ($key in $config.Keys) {
            if ([IoTWorkspaceXML]::ConfigKeys -notcontains $key) { 
                Publish-Error "Unsupported key : $key"
                continue
            }
            Write-Debug "Processing $key"
            $node = $this.XmlDoc.IoTWorkspace.Config.GetElementsByTagName($key) | Select-Object -First 1
            Write-Debug "Old value : $($node.InnerText)"
            $node.InnerText = $config[$key]
            Write-Debug "New value : $($node.InnerText)"
        }
        $this.Save()
    }

    [Boolean] AddCertificate([string] $certfile, [string]$certnode, [Boolean]$istest) {

        if (-not (Test-Path $certfile -Filter *.cer )) {
            Publish-Error "$certfile not found"
            return $false
        }

        #Copy the cert to the cert dir
        $DirName = Split-Path -Path $this.FileName -Parent
        $srcpath = Split-Path -Path $certfile -Parent
        if ($srcpath -ne $DirName){
            Copy-Item -Path $certfile -Destination $DirName\Certs\
        }
        $node = $this.XmlDoc.GetElementsByTagName("$certnode")
        if ($null -eq $node){
            Publish-Error "Unsupported CertNode : $certnode."
            return $false
        }
        $cername = Split-Path -Path $certfile -Leaf
        $nodesTestRetail = @("Database","User","Kernel")
        if ($nodesTestRetail.Contains($certnode)){
            if ($istest){
                $node = $node.GetElementsByTagName("Test")
            }
            else {
                $node = $node.GetElementsByTagName("Retail")
            }
        }
        $certnode = $node.GetElementsByTagName("Cert") |  Where-Object { ($_.InnerText) -ieq $cername }
        if ($certnode) {
            Publish-Error "Cert already defined"
            return $false
        }
        $newcert = $this.XmlDoc.CreateElement("Cert","")
        $newcert.InnerText = $cername
        $node.AppendChild($newcert)
        Write-Debug "$newcert added"
        $this.Save()
        return $true
    }    
}
