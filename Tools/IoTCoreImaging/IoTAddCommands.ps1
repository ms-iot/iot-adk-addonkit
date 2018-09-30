<#
This contains various commands for imaging
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1
function Add-IoTAppxPackage {
    <#
    .SYNOPSIS
    Adds an Appx package directory to the workspace and generates the required wm.xml and customizations.xml files
    
    .DESCRIPTION
    This command creates an appx directory in the Source-arch\packages folder and generates the wm.xml and customisations.xml file by processing the input appx/appxbundle file. This also copies the appx files including the dependencies and the cert or the license file to the appx directory. In addition, this also adds an appx specific feature id (APPX_AppxName) in the OEMFM.xml file.
    
    .PARAMETER AppxFile
    Mandatory parameter, specifying the appx (or) appxbundle filename.
    
    .PARAMETER StartupType
    Mandatory parameter, specifying the appx startup type, fga for foreground app, bgt for background task and none for no startup specification. Default is none.
    
    .PARAMETER OutputName
    Optional parameter specifying the directory name (namespace.name format). Default is Appx.<appxname>.
    
    .PARAMETER SkipCert
    Optional switch parameter to skip processing of cert file .This copies the cert file to the directory but does not add the cert specification in the customizations.xml file.
    
    .EXAMPLE
    Add-IoTAppxPackage C:\MyApps\Sample1.Appx fga Appx.Sample 
    
    .NOTES
    See New-IoTCabPackage to build a cab file.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$AppxFile,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateSet("fga", "bgt", "none")]
        [String]$StartupType,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$OutputName,
        [Parameter(Position = 3, Mandatory = $false)]
        [Switch]$SkipCert
    )

    $appxpath = Split-Path $AppxFile -Parent
    $fileobj = Get-Item $AppxFile
    if (($fileobj.Extension -ine ".appx" ) -and ($fileobj.Extension -ine ".appxbundle" )) {
        Publish-Error "$AppxFile is not an appx/appxbundle" ; return
    }

    $appxinfo = & "$($PSScriptRoot)\..\GetAppxInfo.exe" $AppxFile
#   $appxinfo | Out-File "$($env:TEMP)\debugoutput.txt -Append -force

    $AppxVersion = "0"
    $AppxName = $fileobj.BaseName
    if ($AppxName.IndexOf("_") -ine -1) {
        $AppxName = $AppxName.SubString(0, $AppxName.IndexOf("_"))
    }

    $pkgfamname = $null
    $entry = "App"
    foreach ($line in $appxinfo) {
        $tags = $line.Split(":")
        if ($null -ine $tags) {
            $txt1 = $tags[0].Trim()
            $txt2 = $tags[1].Trim()
            switch ($txt1) {
                "File Name" { $AppxName = $txt2.SubString(0, $txt2.IndexOf("_")) ; break}
                "Version" { $AppxVersion = $txt2; break }
                "AppUserModelId" {
                    $text = $txt2.Split("!")
                    $pkgfamname = $text[0]
                    $entry = $text[1]
                    break 
                }
            }
        }
        # Exit if we found a name
        if ($null -ne $pkgfamname) { break }
    }

    Publish-Status "AppxName          : $AppxName"
    Publish-Status "AppxVersion       : $AppxVersion"
    Publish-Status "PackageFamilyName : $pkgfamname"

    if ([string]::IsNullOrWhiteSpace($OutputName)) {
        $OutputName = "Appx." + $AppxName
    }

    $pkgdir = "$env:PKGSRC_DIR\$OutputName"
    New-DirIfNotExist $pkgdir

    # Copy the appx file to target dir
    $newappx = $AppxName + $fileobj.Extension
    $newappxname = "$pkgdir\$newappx"
    Copy-Item $AppxFile $newappxname

    # Set the provisioning path/rank
    $PROV_PATH = "`$(runtime.windows)\Provisioning\Packages"
    $PROV_RANK = 0
    if ($env:PROV_PATH -ine $null) { $PROV_PATH = $env:PROV_PATH }
    if ($env:PROV_RANK -ine $null) { $PROV_RANK = $env:PROV_RANK }

    # Get the dependency list
    $deppath = $appxpath
    $depfiles = @()
    $cerfiles = @()
    $licenseid = ""
    $licensename = "$AppxName" + "_License.ms-windows-store-license"
    if (Test-Path "$appxpath\Dependencies\$env:ARCH") {
        $deppath = "$appxpath\Dependencies\$env:ARCH"
        $depfiles = Get-ChildItem $deppath -Filter *.appx -File
    }
    elseif (Test-Path "$appxpath\Dependencies") {
        $deppath = "$appxpath\Dependencies"
        $depfiles = Get-ChildItem $deppath -Filter *.appx -File
    }
    elseif (Test-Path "$appxpath\$env:ARCH") {
        $deppath = "$appxpath\$env:ARCH"
        $depfiles = Get-ChildItem $deppath -Filter *.appx -File
    }
    else {
        $deppath = $appxpath
        $fil = "Microsoft*.appx"
        $depfiles = Get-ChildItem $deppath -Filter $fil -File
    }

    Publish-Status "Dependencies      : $depfiles"
    $licensexml = Get-ChildItem $appxpath -Filter *License*.xml -File | foreach-object {$_.FullName}
    if ($null -ine $licensexml) {
        Copy-Item $licensexml $pkgdir\$licensename
        $liobj = [xml] (Get-Content $licensexml)
        $licenseid = $liobj.License.LicenseID
        Publish-Status "LicenseID      : $licenseid"
    }
    else {
        $cerfiles = Get-ChildItem $appxpath -Filter *.cer -File | foreach-object {$_.BaseName}
        foreach ($cer in $cerfiles) {
            Copy-Item $appxpath\$($cer).cer $pkgdir\$($cer).cer
        }
    }

    # Author the customizations.xml file
    $custxml = "$pkgdir\customizations.xml"
    $guid = $null
    if (Test-Path $custxml) {
        $olddoc = [xml] (Get-Content $custxml)
        $guid = $olddoc.WindowsCustomizations.PackageConfig.ID
        Publish-Status "Reusing guid : $guid"
        Remove-Item -Path $custxml
    }
    else { $guid = [System.Guid]::NewGuid().toString() }
    $provxml = New-IoTProvisioningXML "$custxml" -Create
    $pkgconfig = @{ 
        "ID"      = "$guid"
        "Name"    = "$($AppxName)Prov"
        "Version" = "$AppxVersion"
        "Rank"    = "$PROV_RANK"
    }
    $provxml.SetPackageConfig($pkgconfig)

    $provxml.AddPolicy("ApplicationManagement", "AllowAllTrustedApps", "Yes")

    # Check for certificate
    if (!$SkipCert -and ($null -ne $cerfiles )) {
        foreach ($cer in $cerfiles) {
            $provxml.AddRootCertificate("$appxpath\$($cer).cer")
        }
    }

    # Startup app settings
    if ($StartupType -ine "None") {
        $provxml.AddStartupSettings("$($pkgfamname)!$($entry)", $StartupType)
    }

    $depnames = @()
    # Copy with new name to destination directory
    foreach ($dep in $depfiles) {
        # Copy dep file to destination dir
        $newname = $dep.BaseName + $dep.Extension
        # protection if _ is not present in the name
        if ($newname.IndexOf("_") -ine -1) { $newname = $newname.SubString(0, $newname.IndexOf("_")) + ".appx" }
        $depnames += $newname
        $src = "$deppath\$dep"
        $dst = "$pkgdir\$newname"
        Copy-Item $src $dst
    }
    # Add the Appx section
    $provxml.AddUniversalAppInstall($pkgfamname, $newappx, $depnames, $licenseid, $licensename )

    try {
        $namespart = $OutputName.Split(".")
        $wmwriter = New-IoTWMWriter $pkgdir $namespart[0] $namespart[1]
        $wmwriter.Start($null)
        $wmwriter.AddFiles($PROV_PATH, "`$(BLDDIR)\ppkgs\" + $OutputName + ".ppkg", $OutputName + ".ppkg")
        $wmwriter.AddFiles($PROV_PATH, "`$(BLDDIR)\ppkgs\" + $OutputName + ".cat", $OutputName + ".cat")
        $wmwriter.Finish()
        Publish-Success "New Appx created at $pkgdir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }

    # Update the feature manifest with this package entry
    try {
        $fmxml = "$env:PKGSRC_DIR\OEMFM.xml"
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) # use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"
    }
}

function Add-IoTDriverPackage {
    <#
    .SYNOPSIS
    Adds a driver package directory to the workspace and generates the required wm.xml file.
    
    .DESCRIPTION
    This command creates a driver package directory in the Source-arch\packages folder and generates the wm.xml file and copies all files in the inf directory including the inf file. If BSPName is specified, then it creates the package directory in Source-arch\BSP\<BSPName>\Packages directory.
    In addition to that, it also adds a driver specific feature id (DRV_InfName) in the OEMFM.xml ( or in the BSPFM.xml if BSPName specified). 
    
    .PARAMETER InfFile
    Mandatory parameter, specifying the inf file.
    
    .PARAMETER OutputName
    Optional parameter specifying the directory name (namespace.name format). Default is Drivers.<InfName>.
    
    .PARAMETER BSPName
    Optional parameter specifying the BSP. 
    
    .EXAMPLE
    Add-IoTDriverPackage C:\Test\gpiodrv.inf Drivers.GPIO
    Creates Drivers.GPIO in Source-arch\packages folder.

    .EXAMPLE
    Add-IoTDriverPackage C:\Test\gpiodrv.inf Drivers.GPIO RPi2
    Creates Drivers.GPIO in Source-arch\BSP\RPi2\packages folder.
    
    .NOTES
    See New-IoTCabPackage to build a cab file.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$InfFile,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$OutputName,
        [Parameter(Position = 2, Mandatory = $false)]
        [String]$BSPName
    )

    $fileobj = Get-Item $InfFile
    if ($fileobj.Extension -ine ".inf" ) {
        Publish-Error "$InfFile is not an inf file"
        return
    }

    if ([string]::IsNullOrWhiteSpace($OutputName)) { 
        $OutputName = "Drivers." + $fileobj.BaseName 
    }
    
    $filedir = "$env:SRC_DIR\Packages\$OutputName"
    $fmxml = "$env:PKGSRC_DIR\OEMFM.xml"
    $bspdir = "$env:SRC_DIR\BSP\$BSPName"

    if (![string]::IsNullOrWhiteSpace($BSPName)) {
        if (Test-Path $bspdir -PathType Container ) {
            $filedir = "$bspdir\Packages\$OutputName"
            $fmxml = "$bspdir\Packages\$BSPName" + "FM.xml"
        }
        else { Publish-Warning "$BSPName BSP not found, so using packages dir." }
    }

    if (Test-Path -Path $filedir) {
        Publish-Error "$OutputName already exists"
        return
    }

    New-Item $filedir -type directory | Out-Null
    $srcdir = Split-Path -Path $InfFile
    Copy-Item -Path $srcdir\* -Destination $filedir\ -Exclude *.wm.xml -Recurse

    # Write the wm.xml file
    $namespace = $OutputName.Split('.')[0]
    $name = $OutputName.Split('.')[1]
    try {
        $wmwriter = New-IoTWMWriter $filedir $namespace $name
        $wmwriter.Start($null)
        $wmwriter.AddDriver($fileobj.Name)
        $wmwriter.Finish()
        Publish-Success "New Driver created at $filedir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }

    # Update the feature manifest with this package entry
    try {
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) #use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg";
    }
}

function Add-IoTCommonPackage {
    <#
    .SYNOPSIS
    Adds a common(generic) package directory to the workspace and generates the required wm.xml file.
    
    .DESCRIPTION
    This command creates a common (generic) package directory in the Common\packages folder and generates the wm.xml file. 
    In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml. 
 
    .PARAMETER OutputName
    Mandatory parameter specifying the directory name (namespace.name format). 
    
    .EXAMPLE
    Add-IoTCommonPackage Custom.Settings
    
    .NOTES
    See New-IoTCabPackage to build a cab file.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OutputName
    )

    $filedir = "$env:COMMON_DIR\Packages\$OutputName"
    if (Test-Path -Path $filedir) {
        Publish-Error "$OutputName already exists"
        return
    }
    New-Item $filedir -type directory | Out-Null

    # Write the wm.xml file
    $names = $OutputName.Split('.')
    try {
        $wmwriter = New-IoTWMWriter $filedir $names[0] $names[1]
        $wmwriter.Start($null)
        $regkeyvals = @(("StringValue", "REG_SZ", "Test string"), ("DWordValue", "REG_DWORD", "0x12AB34CD"))
        $wmwriter.AddRegKeys("`$(hklm.software)\`$(OEMNAME)\Test", $regkeyvals)
        $wmwriter.AddRegKeys("`$(hklm.software)\`$(OEMNAME)\EmptyKey", $null)
        $wmwriter.AddComment("<files> <file destinationDir=`"`$(runtime.bootDrive)\Myfolder`" source=`"Myfile.txt`" />  </files>")
        $wmwriter.Finish()
        Publish-Success "New package created at $filedir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }

    # Update the feature manifest with this package entry
    try {
        $fmxml = "$env:COMMON_DIR\Packages\OEMCOMMONFM.xml"
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) # use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg";
    }
}

function Add-IoTFilePackage {
    <#
    .SYNOPSIS
    Adds a file package directory to the workspace and generates the required wm.xml file.
    
    .DESCRIPTION
    This command creates a file package directory in the Common\packages folder and generates the wm.xml file. 
    In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml. 
 
    .PARAMETER OutputName
    Mandatory parameter specifying the directory name (namespace.name format). 

    .PARAMETER Files
    Mandatory parameter specifying the list of files to be added to the package (array of arrays). Each entry is an 3 element array containing destinationdir, source file and destination filename in that order. 
    
    .EXAMPLE
    Add-IoTFilePackage Files.Templates
    
    .NOTES
    See New-IoTCabPackage to build a cab file.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OutputName,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[][]]$Files
    )

    $filedir = "$env:COMMON_DIR\Packages\$OutputName"
    if (Test-Path -Path $filedir) {
        Publish-Error "$OutputName already exists"
        return
    }
    New-Item $filedir -type directory | Out-Null

    # Write the wm.xml file
    $names = $OutputName.Split('.')
    try {
        $wmwriter = New-IoTWMWriter $filedir $names[0] $names[1]
        $wmwriter.Start($null)
        if ($null -ine $Files) {
            foreach ($File in $Files) {
                if (Test-Path -Path $File[1] -PathType Leaf) {
                    Copy-Item -Path $File[1] -Destination $filedir -Force | Out-Null
                    $srcfile = Split-Path $File[1] -Leaf
                    $destfile = $File[2]
                    if ([string]::IsNullOrWhiteSpace($File[2])) { 
                        $destfile = $srcfile
                    }
                    $wmwriter.AddFiles($File[0],$srcfile,$destfile)
                }
                else {
                    Publish-Error "$($File[1]) not found" 
                }
            }
        }
        $wmwriter.Finish()
        Publish-Success "New package created at $filedir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
    # Update the feature manifest with this package entry
    try {
        $fmxml = "$env:COMMON_DIR\Packages\OEMCOMMONFM.xml"
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) # use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg";
    }
}

function Add-IoTRegistryPackage {
    <#
    .SYNOPSIS
    Adds a registry package directory to the workspace and generates the required wm.xml file.
    
    .DESCRIPTION
    This command creates a registry package directory in the Common\packages folder and generates the wm.xml file. 
    In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml. 
 
    .PARAMETER OutputName
    Mandatory parameter specifying the directory name (namespace.name format).

    .PARAMETER RegKeys
    Mandatory parameter specifying the reg keys to be specified (array of arrays). Each element should contain reg key, reg value , reg value type and reg value data in that order. For just the keys with no value, the remaining fields can be $null.
    
    .EXAMPLE
    Add-IoTRegistryPackage Registry.Settings
    
    .NOTES
    See New-IoTCabPackage to build a cab file.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OutputName,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[][]]$RegKeys
    )

    $filedir = "$env:COMMON_DIR\Packages\$OutputName"
    if (Test-Path -Path $filedir) {
        Publish-Error "$OutputName already exists"
        return
    }
    New-Item $filedir -type directory | Out-Null

    # Write the wm.xml file
    $names = $OutputName.Split('.')
    try {
        $wmwriter = New-IoTWMWriter $filedir $names[0] $names[1]
        $wmwriter.Start($null)
        if ($null -ine $RegKeys) {
            foreach ($RegKey in $RegKeys) {
                $wmwriter.AddRegKeyValue($RegKey[0],$RegKey[1],$RegKey[2],$RegKey[3])
            }
        }
        $wmwriter.Finish()
        Publish-Success "New package created at $filedir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }

    # Update the feature manifest with this package entry
    try {
        $fmxml = "$env:COMMON_DIR\Packages\OEMCOMMONFM.xml"
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) # use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg";
    }
}

function Add-IoTProvisioningPackage {
    <#
    .SYNOPSIS
    Adds a provisioning package directory to the workspace and generates the required wm.xml file, customizations.xml file and the icdproject file.
    
    .DESCRIPTION
    This command creates a provisioning package directory in the Common\packages folder and generates the wm.xml file,customizations.xml file and the icdproject file. 
    In addition to that, it also adds a feature id (OutputName) in the OEMCommonFM.xml. 
 
    .PARAMETER OutputName
    Mandatory parameter specifying the directory name (namespace.name format). 

    .PARAMETER PpkgFile
    Optional parameter specifying the ppkg file from the ICD output directory.(C:\Users\<user>\Documents\Windows Imaging and Configuration Designer (WICD)). 

    .EXAMPLE
    Add-IoTProvisioningPackage Custom.Settings
    Creates a provisioning package folder Custom.Settings. Launch ICD.exe and open the .icdproj.xml file in this folder to edit the provisioning settings.
    
    .EXAMPLE
    Add-IoTProvisioningPackage Custom.Settings "C:\Users\<user>\Documents\Windows Imaging and Configuration Designer (WICD)\DisableUpdate\DisableUpdate.ppkg"
    Creates a provisioning package folder Custom.Settings and copies the source files for the ppkg to this directory and renames it to CustomSettings.

    .NOTES
    See New-IoTProvisioningPackage to build a provisioning package.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$OutputName,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$PpkgFile
    )

    if (-not $OutputName.Contains(".")){
        $OutputName = "Prov.$Outputname"
    }
    $filedir = "$env:COMMON_DIR\Packages\$OutputName"
    if (Test-Path -Path $filedir) {
        Publish-Error "$OutputName already exists"
        return
    }
    if ((-not [string]::IsNullOrEmpty($PpkgFile)) -and (-not (Test-Path -Path $PpkgFile) )){
        Publish-Error "$PpkgFile not found"
        return
    }
    New-Item $filedir -type directory | Out-Null
    # Set the provisioning path/rank
    $PROV_PATH = "`$(runtime.windows)\Provisioning\Packages"
    $PROV_RANK = 0
    if ($env:PROV_PATH -ine $null) { $PROV_PATH = $env:PROV_PATH }
    if ($env:PROV_RANK -ine $null) { $PROV_RANK = $env:PROV_RANK }

    # Write the wm.xml file
    $names = $OutputName.Split('.')
    $ProvName = $OutputName.Replace(".","")
    try {
        $wmwriter = New-IoTWMWriter $filedir $names[0] $names[1]
        $wmwriter.Start($null)
        $wmwriter.AddFiles($PROV_PATH, "`$(BLDDIR)\ppkgs\" + $OutputName + ".ppkg", $OutputName + ".ppkg")
        $wmwriter.AddFiles($PROV_PATH, "`$(BLDDIR)\ppkgs\" + $OutputName + ".cat", $OutputName + ".cat")
        $wmwriter.Finish()
        Publish-Success "New package created at $filedir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
    $custxml = "$filedir\customizations.xml"
    if (-not [string]::IsNullOrEmpty($PpkgFile)){
        $srcpath = Split-Path -Path $PpkgFile -Parent
        Copy-Item "$srcpath\customizations.xml" $custxml
        $provxml = New-IoTProvisioningXML "$custxml"
        $pkgconfig = @{ 
            "Name"    = "$ProvName"
        }
    }
    else {
        # create customisations.xml file
        $provxml = New-IoTProvisioningXML "$custxml" -Create
        $pkgconfig = @{ 
            "Name"    = "$ProvName"
            "Rank"    = "$PROV_RANK"
        }
        $provxml.AddPolicy("ApplicationManagement", "AllowAllTrustedApps", "Yes")
    }
    $provxml.SetPackageConfig($pkgconfig)    
    $provxml.CreateICDProject()
    # Update the feature manifest with this package entry
    try {
        $fmxml = "$env:COMMON_DIR\Packages\OEMCOMMONFM.xml"
        $pkgname = "%OEM_NAME%." + $OutputName + ".cab"
        $fm = New-IoTFMXML $fmxml
        $fm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $null) # use default feature id
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg";
    }
}

function Add-IoTProduct {
    <#
    .SYNOPSIS
    Generates a new product directory under Source-arch\Products\.
    
    .DESCRIPTION
    Generates a new product directory under Source-arch\Products\ based on the OEMInputSamples specified in the BSP directory Source-arch\BSP\<BSPName>\OEMInputSamples
    
    .PARAMETER ProductName
    Mandatory parameter, specify the product name.
    
    .PARAMETER BSPName
    Mandatory paramter, specify the BSP used in the product.
    
    .PARAMETER OemName
    Mandatory parameter, specify the OEM name for the SMBIOS.
    
    .PARAMETER FamilyName
    Mandatory parameter, specify the Family name for the SMBIOS.

    .PARAMETER SkuNumber
    Mandatory parameter, specify the SkuNumber for the SMBIOS.

    .PARAMETER BaseboardManufacturer
    Mandatory parameter, specify the BaseboardManufacturer for the SMBIOS.

    .PARAMETER BaseboardProduct
    Mandatory parameter, specify the BaseboardProduct for the SMBIOS.

    .PARAMETER PkgDir
    Optional parameter, specify the BSP package path for the build configurations.

    .EXAMPLE
    Add-IoTProduct SampleA RPi2 OEMName ProdFamily ProdSKU1 Fabrikam RPiCustom2

    .NOTES
    See BuildFFU for creating FFU image for a given product.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$ProductName,
        [Parameter(Position=1, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$BSPName,
        [Parameter(Position=2, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$OemName,
        [Parameter(Position=3, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$FamilyName,
        [Parameter(Position=4, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$SkuNumber,
        [Parameter(Position=5, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$BaseboardManufacturer,
        [Parameter(Position=6, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$BaseboardProduct,
        [Parameter(Position=7, Mandatory=$false)][String]$PkgDir = $null
    )
    $bspdir = "$env:BSPSRC_DIR\$BSPName"
    $proddir = "$env:SRC_DIR\Products\$ProductName"
    if (Test-Path -Path $proddir) {
        Publish-Error "$ProductName already exist"
        return
    }
    if (!(Test-Path -Path $bspdir)) {
        Publish-Error "$BSPName is not found"
        return
    }

    # Create the product directory
    Publish-Status "Creating $ProductName Product with BSP $BSPName"
    New-Item $proddir -type directory | Out-Null
    New-Item $proddir\Prov -type directory | Out-Null
    Copy-Item $bspdir\OEMInputSamples\* $proddir
    Copy-Item $env:TEMPLATES_DIR\oemcustomization.cmd $proddir\

    $provxml = New-IoTProvisioningXML "$proddir\prov\customizations.xml" -Create
    $pkgconfig = @{ "Name" = "$($ProductName)Prov" }
    $provxml.SetPackageConfig($pkgconfig)
    $provxml.AddPolicy("ApplicationManagement", "AllowAppStoreAutoUpdate", "Allowed")
    $provxml.CreateICDProject()
    $prodconfigxml = "$proddir\$($ProductName)Settings.xml"
    $settingsxml = New-IoTProductSettingsXML $prodconfigxml -Create  $OemName $FamilyName $SkuNumber $BaseboardManufacturer $BaseboardProduct $PkgDir
    $settings = @{
        "Name" = "$ProductName"
        "Arch" = "$env:BSP_ARCH"
        "BSP"  = "$BSPName"
    }
    $settingsxml.SetSettings($settings)
    Publish-Status "Product Config file : $($settingsxml.FileName)"

    $hookfile = "$bspdir\tools\AddIoTProduct-Hook.ps1"
    if (Test-Path $hookfile ) {
        #TODO check the impact of dot sourcing.
        . $hookfile $proddir $BSPName
    }
    Export-IoTDeviceModel $ProductName
}

function Add-IoTBSP {
    <#
    .SYNOPSIS
    Generates a BSP directory under Source-arch\BSP\ using a BSP directory template.
    
    .DESCRIPTION
    Generates a BSP directory under Source-arch\BSP\ using a BSP directory template.
    
    .PARAMETER BSPName
    Mandatory paramter, specifying the BSP name.
    
    .EXAMPLE
    Add-IoTBSP MyRPi
    
    .NOTES
    See Add-IoTProduct for creating new product directory.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$BSPName
    )
    $bspdir = "$env:BSPSRC_DIR\$BSPName"
    $templatedir = "$env:TEMPLATES_DIR\BSP"
    if (Test-Path -Path $bspdir) {
        Publish-Error "$BSPName already exists"
        return
    }

    Publish-Status "Creating $BSPName BSP..."
    New-Item $bspdir -type directory | Out-Null
    New-Item $bspdir\Packages -type directory | Out-Null
    New-Item $bspdir\OEMInputSamples -type directory | Out-Null
    New-Item $bspdir\WinPEExt -type directory | Out-Null
    (Get-Content $templatedir\RetailOEMInputTemplate.xml) -replace "{BSP}", $BSPName -replace "{arch}", $env:BSP_ARCH | Out-File $bspdir\OEMInputSamples\RetailOEMInput.xml -Encoding utf8
    (Get-Content $templatedir\TestOEMInputTemplate.xml) -replace "{BSP}", $BSPName -replace "{arch}", $env:BSP_ARCH | Out-File $bspdir\OEMInputSamples\TestOEMInput.xml -Encoding utf8
    $bspfmxml = "$bspdir\Packages\$($BSPName)FM.xml"
    (Get-Content $templatedir\BSPFMTemplate.xml) -replace "{BSP}", $BSPName -replace "{arch}", $env:BSP_ARCH | Out-File $bspfmxml -Encoding utf8
    $bspfmxml = "$bspdir\Packages\$($BSPName)FMFileList.xml"
    $archcaps = $env:BSP_ARCH
    $archcaps = $archcaps.ToUpper()
    (Get-Content $templatedir\BSPFMFileListTemplate.xml) -replace "{BSP}", $BSPName -replace "{ARCH}", $archcaps | Out-File $bspfmxml -Encoding utf8
    Copy-Item $templatedir\WinPEExtReadme.txt $bspdir\
    Publish-Status "Importing OEM packages used in the BSP.."
    Import-IoTOEMPackage Device.SystemInformation
    Import-IoTOEMPackage DeviceLayout.GPT4GB
    Publish-Success "New BSP created at $bspdir"
}

function Add-IoTSecurityPackages {
    <#
    .SYNOPSIS
    Creates the security packages based on the settings in workspace configuration.

    .DESCRIPTION
    Creates the security packages such as DeviceGuard, SecureBoot and BitLocker based on the security settings specified in the workspace configuration xml file.

    .PARAMETER Test
    Switch parameter , if defined includes test certificates in the security packages.

    .EXAMPLE
    Add-IoTSecurityPackages -Test

    .NOTES
    For validating the device guard policy, you can as well scan the built ffu using New-IoTFFUCIPolicy and compare the policy files.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [Switch]$Test
    )

    Add-IoTDeviceGuard $Test
    Add-IoTSecureBoot $Test
    Add-IoTBitLocker
    return
}

function Add-IoTDeviceGuard {
    <#
    .SYNOPSIS
    Generates the device guard package (Security.DeviceGuard) contents based on the workspace specifications.

    .DESCRIPTION
    Generates the device guard package (Security.DeviceGuard) contents based on the workspace specifications. If Test is specified, then it includes test certificates from the specification and generates Security.DeviceGuardTest package. You will need to import the required certificates into the workspace before using this command. For Device Guard, Update certificate is mandatory.

    .PARAMETER Test
    Switch parameter, to include test certificates in the device guard package.

    .EXAMPLE
    Add-IoTDeviceGuard -Test

    .NOTES
    For validating the device guard policy, you can as well scan the built ffu using New-IoTFFUCIPolicy and compare the policy files.
    See Import-IoTCertificate before using this function.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [Switch]$Test
    )    

    if ($null -eq $env:IoTWsXml) {
        Publish-Error "IoTWorkspace is not opened. Use Open-IoTWorkspace" 
    }
    $wkspace = New-IoTWorkspaceXML $env:IoTWsXml
    $settingsdoc = $wkspace.XmlDoc
    $sipolicynode = $settingsdoc.IoTWorkspace.Security.SIPolicy
    if ($null -eq $sipolicynode) { 
        Publish-Error "Security settings are not defined in the workspace"
        return $false 
    }
    $retval = $true

    Publish-Status "Generating Device Guard ..."
    if ($Test) {
        $pkgname = "DeviceGuardTest"
    } else { $pkgname = "DeviceGuard" }
    
    $secdir = "$env:COMMON_DIR\Packages\Security.$pkgname"
    $tmpdir = "$env:TMP\security"
    if (!(Test-Path $secdir)){
        #Import the package from the sample workspace
        Import-IoTOEMPackage "Security.$pkgname"
    }
    New-DirIfNotExist $tmpdir
    $initialPolicy = "$env:TEMPLATES_DIR\SIPolicy_template.xml"
    Publish-Status "Using Initial Policy: $initialPolicy ..."

    # Policy filenames
    $auditPolicy = "$secdir\AuditPolicy.xml"
    $auditPolicyBin = "$tmpdir\AuditPolicy.bin"
    $auditPolicyP7b = "$secdir\SIPolicyAudit.p7b"
    $enforcedPolicy = "$secdir\EnforcedPolicy.xml"
    $enforcedPolicyBin = "$tmpdir\enforcedPolicy.bin"
    $enforcedPolicyP7b = "$secdir\SIPolicyEnforce.p7b"
    $certdir = "$env:IOTWKSPACE\Certs"
    Copy-Item -Path $initialPolicy -Destination $auditPolicy -Force

    # First add the microsoft 
    $ConfigFile = "$PSScriptRoot\IoTEnvSettings.xml"
    [xml] $Config = Get-Content -Path $ConfigFile
    $cfgnode = $Config.IoTEnvironment.Security.SIPolicy
    Push-Location -path $PSScriptRoot\Certs
    Publish-Status "---Adding Microsoft Certs---"
    # Add 'user' certs
    $userCerts =@()
    $userCerts += ($cfgnode.User.Retail.Cert | Get-Item).FullName
    if ($Test) {
        $userCerts += ($cfgnode.User.Test.Cert | Get-Item).FullName
    }
    foreach ($cert in $userCerts) {
        Publish-Status "UserCert : $cert"
        Add-SignerRule -CertificatePath $cert -FilePath $auditPolicy -user
    }

    # Add 'kernel' certs
    $kernelCerts = @()
    $kernelCerts += ($cfgnode.Kernel.Retail.Cert | Get-Item).FullName
    if ($Test) {
        $kernelCerts += ($cfgnode.Kernel.Test.Cert | Get-Item).FullName
    }

    foreach ($cert in $kernelCerts) {
        Publish-Status "KernelCert : $cert"
        Add-SignerRule -CertificatePath $cert -FilePath $auditPolicy -kernel
    }
    Pop-Location
    # Add OEM Certificates
    Publish-Status "---Adding OEM Certs---"
    Push-Location -path $certdir

    # Add 'update' certs
    $certs = $sipolicynode.Update.Cert
    if ($null -eq $certs) {
        Publish-Error "Update Certificate not found. Required for signing the policy."
        Pop-Location
        return $false
    }
    $updateCerts = ( $certs | Get-Item).FullName
    foreach ($cert in $updateCerts) {
        Add-SignerRule -CertificatePath $cert -FilePath $auditPolicy -update
    }

    # Add 'user' certs
    $userCerts =@()
    $certs = $sipolicynode.User.Retail.Cert
    if ($certs) {
        $userCerts += ( $certs | Get-Item).FullName
    }
    if ($Test) {
        $certs = $sipolicynode.User.Test.Cert
        if ($certs){
            $userCerts += ( $certs | Get-Item).FullName
        }
    }
    if ($userCerts) {
        foreach ($cert in $userCerts) {
            Publish-Status "UserCert : $cert"
            Add-SignerRule -CertificatePath $cert -FilePath $auditPolicy -user
        }
    }
    else {
        Publish-Warning "SiPolicy : No User certs specified in workspace"
    }

    # Add 'kernel' certs
    $kernelCerts = @()
    $certs = $sipolicynode.Kernel.Retail.Cert
    if ($certs){
        $kernelCerts += ( $certs | Get-Item).FullName
    }
    if ($Test) {
        $certs = $sipolicynode.Kernel.Test.Cert
        if ($certs){
            $kernelCerts += ( $certs | Get-Item).FullName
        }
    }

    if($kernelCerts){
        foreach ($cert in $kernelCerts) {
            Publish-Status "KernelCert : $cert"
            Add-SignerRule -CertificatePath $cert -FilePath $auditPolicy -kernel
        }
    }
    else {
        Publish-Warning "SiPolicy : No kernel certs specified in workspace"
    }
    
    ConvertFrom-CIPolicy -XmlFilePath $auditPolicy -BinaryFilePath $auditPolicyBin
    #$SignTool = (get-item -path "$env:KITSROOT\bin\$env:SDK_VERSION\x86\signtool.exe").FullName
    #& $SignTool sign -v /f $updatePfx /p7 $tmpdir /p7co 1.3.6.1.4.1.311.79.1 /fd sha256 $auditPolicyBin
    
    # Use the first update cert to sign
    $signcertfile = ($sipolicynode.Update.Cert | Select-Object -first 1 | Get-Item ).FullName
    # Use sha1 thumbprint to identify the cert for signing. Cert must be available in CurrentUser store (from smartcard or local machine)
    $signcerttp = (Get-PfxCertificate -FilePath $signcertfile).Thumbprint

    signtool sign -v /s my /sha1 $signcerttp /p7 $tmpdir /p7co 1.3.6.1.4.1.311.79.1 /fd sha256 $auditPolicyBin

    Copy-Item -Path "$auditPolicyBin.p7" -Destination $auditPolicyP7b
    Copy-Item -Path $auditPolicy -Destination $enforcedPolicy -Force

    # Disable Audit Mode
    Set-RuleOption -FilePath $enforcedPolicy -Option 3 -Delete

    # Disable Unsigned System Integrity Policy
    Set-RuleOption -FilePath $enforcedPolicy -Option 6 -Delete

    # Disable Advanced Boot Options Menu
    Set-RuleOption -FilePath $enforcedPolicy -Option 9 -Delete

    ConvertFrom-CIPolicy -XmlFilePath $enforcedPolicy -BinaryFilePath $enforcedPolicyBin
    #& $SignTool sign -v /f $updatePfx /p7 $tmpdir /p7co 1.3.6.1.4.1.311.79.1 /fd sha256 $enforcedPolicyBin
    signtool sign -v /s my /sha1 $signcerttp /p7 $tmpdir /p7co 1.3.6.1.4.1.311.79.1 /fd sha256 $enforcedPolicyBin
    Copy-Item -Path "$enforcedPolicyBin.p7" -Destination $enforcedPolicyP7b -Force

    try {
        $wmwriter = New-IoTWMWriter $secdir Security $pkgname -Force
        $wmwriter.Start("EFIESP")
        $wmwriter.AddFiles("`$(runtime.bootDrive)\efi\microsoft\boot", "SIPolicyEnforce.p7b", "SIPolicy.p7b")
        $wmwriter.Finish()
        Publish-Success "New Security.$pkgname created at $secdir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"
        $retval = $false
    }
    Pop-Location
    return $retval
}

function Add-IoTSecureBoot {
    <#
    .SYNOPSIS
    Generates the secure boot package (Security.SecureBoot) contents based on the workspace specifications. If Test is specified, then it includes test certificates from the specification.

    .DESCRIPTION
    Generates the secure boot package (Security.SecureBoot) contents based on the workspace specifications. If Test is specified, then it includes test certificates from the specification and generates Security.SecureBootTest package. You will need to import the required certificates into the workspace before using this command. For Secure Boot, PlatformKey and KeyExchangeKey certificates are mandatory.

    .PARAMETER Test
    Switch parameter, to include test certificates in the secure boot package. 

    .EXAMPLE
    Add-IoTSecureBoot -Test

    .NOTES
    See Import-IoTCertificate before using this function.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [Switch]$Test
    ) 

    if ($null -eq $env:IoTWsXml) {
        Publish-Error "IoTWorkspace is not opened. Use Open-IoTWorkspace" 
    }
    $wkspace = New-IoTWorkspaceXML $env:IoTWsXml
    $settingsdoc = $wkspace.XmlDoc
    $securebootnode = $settingsdoc.IoTWorkspace.Security.SecureBoot
    if ($null -eq $securebootnode) {
        Publish-Error "Security settings are not defined in the workspace"
        return
    }

    Publish-Status "Generating SecureBoot ..."
    if ($Test) {
        $pkgname = "SecureBootTest"
    } else { $pkgname = "SecureBoot" }

    $secdir = "$env:COMMON_DIR\Packages\Security.$pkgname"
    $tmpdir = "$env:TMP\security"
    if (!(Test-Path $secdir)){
        #Import the package from the sample workspace
        Import-IoTOEMPackage "Security.$pkgname"
    }
    New-DirIfNotExist $tmpdir
    #$SignTool = (get-item -path "$env:KITSROOT\bin\$env:SDK_VERSION\x86\signtool.exe").FullName
    # First add the microsoft 
    $ConfigFile = "$PSScriptRoot\IoTEnvSettings.xml"
    [xml] $Config = Get-Content -Path $ConfigFile
    $cfgnode = $Config.IoTEnvironment.Security.SecureBoot
    Push-Location -path $PSScriptRoot\Certs
    Publish-Status "---Adding Microsoft Certs---"
    $kekcert = @()
    $kekcert += ($cfgnode.KeyExchangeKey.Cert | Get-Item ).FullName
    $db = @()
    $db = ($cfgnode.Database.Retail.Cert | Get-Item ).FullName
    if ($Test) {
        $db += ($cfgnode.Database.Test.Cert | Get-Item ).FullName
    }
    Publish-Status "MS KEK"
    $kekcert
    Publish-Status "MS Database"
    $db
    Pop-Location
    $certdir = "$env:IOTWKSPACE\Certs"
    Push-Location -path $certdir
    Publish-Status "---Adding OEM Certs---"
    # Resolve the various cert to full path
    $pkcert = $securebootnode.PlatformKey.Cert
    $keksigncert = $securebootnode.KeyExchangeKey.Cert
    if ($pkcert -and $keksigncert){
        $pkcert = (Get-Item $securebootnode.PlatformKey.Cert).FullName
        $pksigncerttp = (Get-PfxCertificate -FilePath $pkcert).Thumbprint
        $keksigncert = ($securebootnode.KeyExchangeKey.Cert | Select-Object -first 1 | Get-Item ).FullName
        $keksigncerttp = (Get-PfxCertificate -FilePath $keksigncert).Thumbprint
    }
    else{
        Publish-Error "PlatformKey/KeyExchangeKey not specified in workspace"
        Pop-Location
        return $false
    }

    $kekcert += ($securebootnode.KeyExchangeKey.Cert | Get-Item ).FullName
    $cert = $securebootnode.Database.Retail.Cert
    if ($cert){
        $db += ( $cert | Get-Item ).FullName
    }
    else {
        Publish-Warning "Secureboot Database: No Retail certs specified in workspace"
    }

    if ($Test) {
        $cert = $securebootnode.Database.Test.Cert
        if ($cert) {
            $db += ( $cert | Get-Item ).FullName
        }
        else {
            Publish-Warning "Secureboot Database: No Test certs specified in workspace"
        }
    }

    Publish-Status "DB list : "
    $db
    Import-Module secureboot
    # Get current time in format "yyyy-MM-ddTHH':'mm':'ss'Z'"
    $time = (Get-date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    # DB
    $objectFromFormat = (Format-SecureBootUEFI -Name db -SignatureOwner 77fa9abd-0359-4d32-bd60-28f4e78f784b -FormatWithCert -CertificateFilePath $db -SignableFilePath "$tmpdir\db.bin" -Time $time -AppendWrite: $false)
    #& $SignTool sign /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /u "1.3.6.1.4.1.311.79.2.1" /f "$kekpfx" "$tmpdir\db.bin"
    signtool sign -v /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /u "1.3.6.1.4.1.311.79.2.1" /sha1 $keksigncerttp "$tmpdir\db.bin"
    $objectFromFormat | Set-SecureBootUEFI -SignedFilePath "$tmpdir\db.bin.p7" -OutputFilePath "$secdir\SetVariable_db.bin" | Out-Null
    Publish-Status "Key Exchange Keys : "
    $kekcert
    # KEK
    $objectFromFormat = (Format-SecureBootUEFI -Name KEK -SignatureOwner 00000000-0000-0000-0000-000000000000 -FormatWithCert -CertificateFilePath $kekcert -SignableFilePath "$tmpdir\kek.bin" -Time $time -AppendWrite: $false)
    # & $SignTool sign /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /f "$pkpfx" "$tmpdir\kek.bin"
    signtool sign -v /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /sha1 $pksigncerttp "$tmpdir\kek.bin"
    $objectFromFormat | Set-SecureBootUEFI -SignedFilePath "$tmpdir\kek.bin.p7" -OutputFilePath "$secdir\SetVariable_kek.bin" | Out-Null

    # PK
    $objectFromFormat = (Format-SecureBootUEFI -Name PK -SignatureOwner 55555555-5555-5555-5555-555555555555 -FormatWithCert -CertificateFilePath $pkcert -SignableFilePath "$tmpdir\pk.bin" -Time $time -AppendWrite: $false)
    # & $SignTool sign /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /f "$pkpfx" "$tmpdir\pk.bin"
    signtool sign -v /fd sha256 /p7 $tmpdir /p7co 1.2.840.113549.1.7.1 /p7ce DetachedSignedData /a /sha1 $pksigncerttp "$tmpdir\pk.bin"
    $objectFromFormat | Set-SecureBootUEFI -SignedFilePath "$tmpdir\pk.bin.p7" -OutputFilePath "$secdir\SetVariable_pk.bin" | Out-Null

    try {
        $wmwriter = New-IoTWMWriter $secdir Security $pkgname -Force
        $wmwriter.Start("MainOS")
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "SetVariable_db.bin", $null)
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "SetVariable_kek.bin", $null)
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "SetVariable_pk.bin", $null)
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "setup.secureboot.cmd", $null)
        $wmwriter.Finish()
        Publish-Success "New Security.$pkgname created at $secdir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"
    }
    Pop-Location
}

function Add-IoTBitLocker {
    <#
    .SYNOPSIS
    Generates the Bitlocker package (Security.BitLocker) contents based on the workspace specifications.

    .DESCRIPTION
    Generates the Bitlocker package (Security.BitLocker) contents based on the workspace specifications. You will need to import the required certificates into the workspace before using this command. For Bitlocker, DataRecoveryAgent certificate is mandatory.

    .EXAMPLE
    Add-IoTBitLocker

    .NOTES
    See Import-IoTCertificate before using this function.
    #>
     
    if ($null -eq $env:IoTWsXml) {
        Publish-Error "IoTWorkspace is not opened. Use Open-IoTWorkspace" 
    }
    $wkspace = New-IoTWorkspaceXML $env:IoTWsXml
    $settingsdoc = $wkspace.XmlDoc
    $bitlockernode = $settingsdoc.IoTWorkspace.Security.BitLocker
    if ($null -eq $bitlockernode) {
        Publish-Error "Security settings are not defined in the workspace"
        return
    }

    $certdir = "$env:IOTWKSPACE\Certs"
    Push-Location -path $certdir

    $dracer = $bitlockernode.DataRecoveryAgent.Cert
    if(-not $dracer){
        Publish-Error "DataRecovery Certificate not defined in workspace"
        Pop-Location
        return $false
    }
    $dra = Get-Item -Path $dracer
    $thumbprint = (Get-PfxCertificate -FilePath $dra).Thumbprint

    Publish-Status "Generating Bitlocker ..."
    $secdir = "$env:COMMON_DIR\Packages\Security.BitLocker"
    if (!(Test-Path $secdir)){
        #Import the package from the sample workspace
        Import-IoTOEMPackage Security.BitLocker
    }

    # Convert the certificate into registry format.
    # Import the cert into a cert store.  Get blob from registry.  Delete the cert from cert store.
    [string]$blob = ""
    try {
        Import-Certificate -FilePath $dra -CertStoreLocation Cert:\LocalMachine\My
        $intblob = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\SystemCertificates\My\Certificates\$thumbprint).Blob

        # convert 'intblob' from array to 'int' to a continuous string of hex values
        $blob = (($intblob | foreach-object {$_.ToString("x2") }) -join '')
    }
    finally {
        Remove-Item -Path Cert:\LocalMachine\My\$thumbprint
    }

    try {
        $wmwriter = New-IoTWMWriter $secdir Security BitLocker -Force
        $wmwriter.Start("MainOS")
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "DETask.xml", $null)
        $wmwriter.AddFiles("`$(runtime.bootDrive)\IoTSec", "setup.bitlocker.cmd", $null)
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\SystemCertificates\FVE", $null)
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\SystemCertificates\FVE\Certificates", $null)
        $regkeyvals = , ("Blob", "REG_BINARY", $blob)
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\SystemCertificates\FVE\Certificates\$thumbprint", $regkeyvals)
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\SystemCertificates\FVE\CRLs", $null)
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\SystemCertificates\FVE\CTLs", $null)
        $regkeyvals2 = @(("OSManageDRA", "REG_DWORD", "00000001"),
            ("FDVManageDRA", "REG_DWORD", "00000001"),
            ("RDVManageDRA", "REG_DWORD", "00000001"),
            ("IdentificationField", "REG_DWORD", "00000001"),
            ("IdentificationFieldString", "REG_SZ", "BitLocker"),
            ("SecondaryIdentificationField", "REG_SZ", "BitLocker"),
            ("SelfSignedCertificates", "REG_DWORD", "00000001"),
            ("RDVDeviceBinding", "REG_DWORD", "00000001"),
            ("OSEnablePrebootInputProtectorsOnSlates", "REG_DWORD", "00000001"))
        $wmwriter.AddRegKeys("`$(hklm.software)\Policies\Microsoft\FVE", $regkeyvals2)
        $wmwriter.Finish()
        Publish-Success "New Security.BitLocker created at $secdir"
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"
    }
    Pop-Location
}
