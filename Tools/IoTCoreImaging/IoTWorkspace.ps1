<#
This contains Workspace related functions
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

function New-IoTWorkspaceXML {
    <#
    .SYNOPSIS
    Creates a new IoTWorkspaceXML object
    
    .DESCRIPTION
    Creates a new IoTWorkspaceXML object from the File input file. If the file is not present and Create switch is defined, a new IoTWorkspace xml is created with the default values.
    
    .PARAMETER File
    The IoTWorkspace xml file to open or create.
    
    .PARAMETER Create
    Switch parameter to indicate creation of new file. If the file is already present, it opens the existing file.
    
    .EXAMPLE
    $mywkspacexml = New-IoTWorkspaceXML C:\iot-adk-addonkit\IoTWorkspace.xml

    .EXAMPLE
    $mywkspacexml = New-IoTWorkspaceXML C:\iot-adk-addonkit\IoTWorkspace.xml -Create "Contoso"

    .NOTES
    None
    #>
    [CmdletBinding(DefaultParametersetName='None')]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String] $File,
        [Parameter(Position=1, ParameterSetName='ConstructionArgs',Mandatory=$false)][switch] $Create,
        [Parameter(Position=2, ParameterSetName='ConstructionArgs',Mandatory=$true)][string] $OemName
    )
    # We always have to pass this argument, but it's unneeded unless we're constructing a new XML.
    if (-not $Create) { $OemName = $null }
    return [IoTWorkspaceXML]::new($File, $Create, $OemName)
}

function New-IoTWorkspace {
    <#
    .SYNOPSIS
    Creates a new IoTWorkspace xml and the directory structure at the specified input directory.
    
    .DESCRIPTION
    Creates a new IoTWorkspace xml and the directory structure at the specified input directory..
    
    .PARAMETER DirName
    Mandatory parameter, specifying the directory for the workspace.
    
    .PARAMETER OemName
    Mandatory parameter, specifying the OEMName for the workspace.

    .PARAMETER Arch
    Mandatory parameter, specifying the architecture for the workspace. Additional archs can be added if required using Add-IoTEnvironment.

    .EXAMPLE
    New-IoTWorkspace "C:\MyIoTProject" Contoso arm

    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$DirName,
        [Parameter(Position=1, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$OemName,
        [Parameter(Position=2, Mandatory=$true)][String]$Arch
    )
    if (-not (Test-Path $DirName -PathType Container)) {
        # Create directory if doesnt exist. Used in the powershell / cmd scripts
        New-Item $DirName -ItemType Directory | Out-Null
    }

    $wkspacexml = "$DirName\IoTWorkspace.xml"
    # Create the workspace xml file and the directories
    $wsdoc = New-IoTWorkspaceXML $wkspacexml -Create $OemName
    $retval = $wsdoc.AddEnv($Arch)
    if (! $retval) { 
        Publish-Error "Error adding configuration"
        return
    }
    $arch = $wsdoc.GetCurrentEnv()
    # create the shortcut to launch the workspace with proper tools dir
    Write-CmdShortcut $DirName
    Write-Verbose "IoTWorkspace file : $wkspacexml"
    Publish-Success "New IoTWorkSpace available at $DirName for $arch"
    Open-IoTWorkspace $wkspacexml
    # Now in the new workspace context
    #Import required packages
    Import-IoTOEMPackage Registry.Version
    Import-IoTOEMPackage Custom.Cmd
    Import-IoTOEMPackage Provisioning.Auto
    Publish-Success "Workspace ready!"
}

function Write-CmdShortcut([string] $dir) {
    $CmdFile = "$dir\IoTCorePShell.cmd"
    Set-Content -Path $CmdFile -Value "@echo off"
    $cmdstring = "Start-Process 'powershell.exe' -ArgumentList '-noexit -ExecutionPolicy Unrestricted -Command \`". $Global:ToolsRoot\Tools\Launchshell.ps1\`" %~dp0\IoTWorkspace.xml' -Verb runAs"
    Add-Content -Path $CmdFile -Value "powershell -Command `"$cmdstring`""

    $CmdFile1 = "$dir\IoTCoreShell.cmd"
    Set-Content -Path $CmdFile1 -Value "@echo off"
    $cmdstring = "Start-Process 'cmd.exe' -ArgumentList '/k \`"$Global:ToolsRoot\Tools\CmdTools\LaunchTool.cmd\`" %~dp0\IoTWorkspace.xml' -Verb runAs"
    Add-Content -Path $CmdFile1 -Value "powershell -Command `"$cmdstring`""
}

function Open-IoTWorkspace {
    <#
    .SYNOPSIS
    Opens the IoTWorkspace xml at the specified input directory and sets up the environment with those settings.
    
    .DESCRIPTION
    Opens the IoTWorkspace xml and sets up the environment with those settings.
    
    .PARAMETER WsXML
    Mandatory parameter, specifying the IoTWorkspace.xml file or the directory containing IoTWorkspace.xml file.
    
    .EXAMPLE
    Open-IoTWorkspace C:\MyIoTProject\IoTWorkspace.xml

    .EXAMPLE
    Open-IoTWorkspace C:\MyIoTProject

    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
        [String]$WsXML
    )
    if (Test-Path $WsXML -PathType Leaf){
        $filename = Split-Path -Path $WsXML -Leaf
        if ($filename -ine "IoTWorkspace.xml"){
            Publish-Error "Invalid input file"
            return
        }
    }
    else{
        $WsXML = Join-Path -Path $WsXML -ChildPath "\IoTWorkspace.xml"
        #if its a directory check if it is workspace and open
        if (-not (Test-Path $WsXML -PathType Leaf)){
            Publish-Error "Invalid input directory"
            return
        }
    } 

    $IoTWsXml = Resolve-Path -Path $WsXML
    [System.Environment]::SetEnvironmentVariable("IOTWSXML", $IoTWsXml)
    Publish-Status "Opening workspace : $IoTWsXml"
    #No parameters below, so it opens the default arch specified in the workspace xml
    Set-IoTEnvironment
}

function Add-IoTEnvironment {
    <#
    .SYNOPSIS
    Adds a new architecture to the workspace
    
    .DESCRIPTION
    Adds new architecture to the workspace and creates the required template directories.
    
    .PARAMETER Arch
    Specifies the required architecture. Supported values are arm,arm64,x86 and x64.
    
    .EXAMPLE
    Add-IoTEnvironment arm

    .NOTES
    The alias for this is addenv
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
        [String]$Arch
    )
    $IoTWsXml = $env:IOTWSXML
    if (!$IoTWsXml) { 
        Publish-Error "IoTWorkspace not opened. Use Open-IoTWorkspace"
        return
    }
    $wsdoc = New-IoTWorkspaceXML $IoTWsXml
    $retval = $wsdoc.AddEnv($Arch)
    if (!$retval) {
        Publish-Error "Failed to add arch $Arch"
        return
    }
}

function Set-IoTEnvironment {
    <#
    .SYNOPSIS
    Sets the environment variables as per requested architecture
    
    .DESCRIPTION
    Reads the IoTWorkspace xml file and configures all the environment variables as per the requested architecture. 
    This also exports the environment settings as SetEnvVars.cmd.
    
    .PARAMETER arch
    Specifies the required architecture. Supported values are arm,arm64,x86 and x64.
    
    .EXAMPLE
    Set-IoTEnvironment arm
    
    .NOTES
    The alias for this is setenv
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [String]$arch = "default"
    )
    $IoTWsXml = $env:IOTWSXML
    if (!$IoTWsXml) { 
        Publish-Error "IoTWorkspace not opened. Use Open-IoTWorkspace"
        return
    }
    $wkspaceobj = New-IoTWorkspaceXML $IoTWsXml
    $wkscfg = $wkspaceobj.GetConfig()
    #Establish the workspace root
    $iotwsroot = Split-Path -Path $IoTWsXml -Parent
    $IoTEnvVars = @("IOTWSXML")

    $IoTEnvVars += @("IOT_ADDON_VERSION", "TOOLS_DIR", "TEMPLATES_DIR", "SAMPLEWKS")
    [System.Environment]::SetEnvironmentVariable("IOT_ADDON_VERSION", "$($MyInvocation.MyCommand.Module.Version)")
    [System.Environment]::SetEnvironmentVariable("SAMPLEWKS", "$Global:ToolsRoot\Workspace")
    [System.Environment]::SetEnvironmentVariable("TOOLS_DIR", "$Global:ToolsRoot\Tools")
    [System.Environment]::SetEnvironmentVariable("TEMPLATES_DIR", "$env:TOOLS_DIR\Templates") 
    
    if ($arch -ieq "default") {
        $arch = $wkspaceobj.GetCurrentEnv()
        Write-Debug "Setting env : $arch"
    }
    else {
        $result = $wkspaceobj.SetCurrentEnv($arch)
        Write-Debug "Setting env : $arch $result"
        if (!$result) { return }
    }

    $OemName = $wkscfg.OemName
    if ([string]::IsNullOrWhiteSpace($OemName)) {
        Publish-Error "No OemName specified in the workspace. Using Contoso"
        $OemName = "Contoso"
    }

    $IoTEnvVars += @("OEM_NAME", "ARCH", "BSP_ARCH")
    [System.Environment]::SetEnvironmentVariable("OEM_NAME", $OemName)
    [System.Environment]::SetEnvironmentVariable("ARCH", $arch)
    [System.Environment]::SetEnvironmentVariable("BSP_ARCH", $arch.Replace("x64", "amd64"))

    $key = "Registry::HKLM\Software\Wow6432Node\Microsoft\Windows Kits\Installed Roots"
    $key2 = "HKLM\Software\Microsoft\Windows Kits\Installed Roots"
    $Win10KitsRoot = (Get-ItemProperty -Path $key).KitsRoot10
    if ([string]::IsNullOrWhiteSpace($Win10KitsRoot)) {
        $Win10KitsRoot = (Get-ItemProperty -Path $key2).KitsRoot10
        if ([string]::IsNullOrWhiteSpace($Win10KitsRoot)) {
            Publish-Error "ADK not found"
        }        
    }

    $Win10KitsRoot = $Win10KitsRoot.Substring(0, $Win10KitsRoot.Length - 1)

    $IoTEnvVars += @("KITSROOT", "ICDRoot", "PKG_CONFIG_XML", "WINPE_ROOT", "SIGN_OEM", "SIGN_WITH_TIMESTAMP", "SIGNTOOL_OEM_SIGN")
    [System.Environment]::SetEnvironmentVariable("KITSROOT", $Win10KitsRoot)

    $Win10KitsRootBinPath = "$Win10KitsRoot\Tools\bin\i386"
    $icdroot = "$Win10KitsRoot\Assessment and Deployment Kit\Imaging and Configuration Designer\x86"
    [System.Environment]::SetEnvironmentVariable("ICDRoot", $icdroot)
    [System.Environment]::SetEnvironmentVariable("PKG_CONFIG_XML", "$Win10KitsRootBinPath\pkggen.cfg.xml")
    [System.Environment]::SetEnvironmentVariable("WINPE_ROOT", "$Win10KitsRoot\Assessment and Deployment Kit\Windows Preinstallation Environment")
    [System.Environment]::SetEnvironmentVariable("SIGN_OEM", 1)
    [System.Environment]::SetEnvironmentVariable("SIGN_WITH_TIMESTAMP", 0)

    # $IoTEnvVars += @("WPDKCONTENTROOT") - Not added as this is not required anywhere else.
    [System.Environment]::SetEnvironmentVariable("WPDKCONTENTROOT", $Win10KitsRoot)

    #initialize the source related env vars
    $iotwsroot = Split-Path -Path $IoTWsXml -Parent
    $IoTEnvVars += @("IOTADK_ROOT", "IOTWKSPACE", "COMMON_DIR", "SRC_DIR", "PKGSRC_DIR", "BSPSRC_DIR", "PKGUPD_DIR")
    [System.Environment]::SetEnvironmentVariable("IOTADK_ROOT", $iotwsroot)  #to be deprecated
    [System.Environment]::SetEnvironmentVariable("IOTWKSPACE", $iotwsroot) 
    [System.Environment]::SetEnvironmentVariable("COMMON_DIR", "$iotwsroot\Common")
    [System.Environment]::SetEnvironmentVariable("SRC_DIR", "$iotwsroot\Source-$arch")
    [System.Environment]::SetEnvironmentVariable("PKGSRC_DIR", "$env:SRC_DIR\Packages")
    [System.Environment]::SetEnvironmentVariable("BSPSRC_DIR", "$env:SRC_DIR\BSP")
    [System.Environment]::SetEnvironmentVariable("PKGUPD_DIR", "$env:SRC_DIR\Updates")

    $IoTEnvVars += @("ADK_VERSION", "COREKIT_VER")
    $key = "Registry::HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.WindowsDeploymentTools.x86.10"
    if (Test-Path $key) {
        $adkver = (Get-ItemProperty -Path $key).Version
        $adkver = $adkver.Replace("10.1.", "10.0.")
        [System.Environment]::SetEnvironmentVariable("ADK_VERSION", $adkver)
        Publish-Status "ADK_VERSION :", $adkver
    }
    else { Publish-Error "ADK ver not found in registry" }

    #TODO: Should these early exit if problems are found?
    $key = "Registry::HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_$($arch)_Packages.x86.10"
    if (Test-Path $key) {
        $corekitver = (Get-ItemProperty -Path $key).Version
        $corekitver = $corekitver.Replace("10.1.", "10.0.")
        [System.Environment]::SetEnvironmentVariable("IOTCORE_VER", $corekitver)
        Publish-Status "IOTCORE_VER :", $corekitver
    }
    else { Publish-Error "IoT Core kit ver not found in registry" }
    
    $mspkgroot = $wkscfg.MSPkgRoot
    $mspkg = $mspkgroot + "\MSPackages"
    if ([string]::IsNullOrWhiteSpace($mspkgroot)) {
        $mspkgroot = $Win10KitsRoot
        $mspkg = $Win10KitsRoot + "\MSPackages"
    }
    $mspkgdir = $mspkg + "\Retail\" + $env:BSP_ARCH + "\fre"
    if (Test-Path $mspkgdir) {
        Publish-Success "Corekit found OK"
    }
    $IoTEnvVars += @("AKROOT", "MSPACKAGE", "MSPKG_DIR")
    [System.Environment]::SetEnvironmentVariable("AKROOT", $mspkgroot)
    [System.Environment]::SetEnvironmentVariable("MSPACKAGE", $mspkg)
    [System.Environment]::SetEnvironmentVariable("MSPKG_DIR", $mspkgdir)


    # Parse the BuildDir setting and initialise the build related env vars
    $blddir = $wkscfg.BuildDir
    if ([string]::IsNullOrWhiteSpace($blddir)) {
        $blddir = $iotwsroot + "\Build\" + $env:BSP_ARCH
    }
    else {
        $blddir = Expand-IoTPath($blddir)
    }
    $IoTEnvVars += @("BLD_DIR", "TMP", "PKGBLD_DIR", "PPKGBLD_DIR", "PKGLOG_DIR")
    [System.Environment]::SetEnvironmentVariable("BLD_DIR", $blddir)
    [System.Environment]::SetEnvironmentVariable("TMP", "$env:BLD_DIR\Temp")
    [System.Environment]::SetEnvironmentVariable("PKGBLD_DIR", "$env:BLD_DIR\pkgs")
    [System.Environment]::SetEnvironmentVariable("PPKGBLD_DIR", "$env:BLD_DIR\ppkgs")
    [System.Environment]::SetEnvironmentVariable("PKGLOG_DIR", "$env:BLD_DIR\pkgs\logs")
    New-DirIfNotExist $env:TMP

    #set the tools directory 
    $IoTEnvVars += @("Path", "SDK_VERSION", "DUCSIGNPARAM")
    if ($env:Path -notcontains $env:TOOLS_DIR) {
        [System.Environment]::SetEnvironmentVariable("Path", "$env:TOOLS_DIR;$Win10KitsRootBinPath;$icdroot;$Global:OrigPath")
    }

    #check if test certs are installed and if not, installoemcerts
    #Thumbprint                                Subject
    #----------                                -------
    #5D7630097BE5BDB731FC40CD4998B69914D82EAD  CN=Windows OEM Test Cert 2017 (TEST ONLY), O=Microsoft Partner, OU=Windows, L=Redmond, S=Washington, C=US
    $signcerts = Get-ChildItem -Path cert: -CodeSigningCert -Recurse | where-object {$_.Thumbprint -ieq "5D7630097BE5BDB731FC40CD4998B69914D82EAD"}
    # Install the certs if no signcerts found.
    if ($null -eq $signcerts) {
        InstallOemCerts
    }
    else { Publish-Success "Test certs installed" }

    [System.Environment]::SetEnvironmentVariable("SDK_VERSION", $wkscfg.WindowsSDKVersion)
    [System.Environment]::SetEnvironmentVariable("DUCSIGNPARAM", $wkscfg.EVSignToolParam)

    $bsppkgdir = $wkspaceobj.GetBSPPkgDir()
    if ([string]::IsNullOrWhiteSpace($bsppkgdir)) {
        $bsppkgdir = $env:PKGBLD_DIR
    }
    else { 
        $bsppkgdir = Expand-IoTPath $bsppkgdir
        if (($bsppkgdir -ine $env:PKGBLD_DIR) -and (!(Test-Path $bsppkgdir))) {
            Publish-Error "$bsppkgdir is not found. Setting it to default"
            $bsppkgdir = $env:PKGBLD_DIR
        }
    }
    $IoTEnvVars += @("BSPPKG_DIR", "BSP_VERSION", "SIGN_MODE")
    [System.Environment]::SetEnvironmentVariable("BSPPKG_DIR", $bsppkgdir)
    [System.Environment]::SetEnvironmentVariable("BSP_VERSION", $wkspaceobj.GetVersion())
    [System.Environment]::SetEnvironmentVariable("SIGN_MODE", "Test")

    if (($null-ne $host) -and ($null -ne $host.ui) -and ($null -ne $host.ui.RawUI) -and ($null -ne $host.ui.RawUI.WindowTitle)) {
        $host.ui.RawUI.WindowTitle = "IoTCorePShellv$env:IOT_ADDON_VERSION $env:BSP_VERSION $env:SIGN_MODE"
    }

    function Global:prompt { "IoTCorePShell $env:BSP_ARCH $env:BSP_VERSION $env:SIGN_MODE`nPS $pwd>" }
    Publish-Status "IOTWKSPACE  : $env:IOTWKSPACE"
    Publish-Status "OEM_NAME    : $env:OEM_NAME"
    Publish-Status "BSP_ARCH    : $env:BSP_ARCH"
    Publish-Status "BSP_VERSION : $env:BSP_VERSION"
    Publish-Status "BSPPKG_DIR  : $env:BSPPKG_DIR"
    Publish-Status "MSPKG_DIR   : $env:MSPKG_DIR"

    # Set the signature to defaults (blank parameters)
    Set-IoTSignature
    Set-Location $env:IOTWKSPACE
    # Export IoT specific env vars just added
    $CmdFile = "$iotwsroot\Build\SetEnvVars.cmd"
    Set-Content -Path $CmdFile -Value "REM Exporting Env vars from Powershell"
    Add-Content -Path $CmdFile -Value "echo Initializing Env variables"
    foreach ($envvar in $IoTEnvVars) {
        $value = [System.Environment]::GetEnvironmentVariable($envvar)
        Add-Content -Path $CmdFile -Value "set $envvar=$value"
    }
    Add-Content -Path $CmdFile -Value "set PROMPT=IoTCoreShell %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%`$_`$P`$G"
    Add-Content -Path $CmdFile -Value "TITLE IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%"
}

function Set-IoTCabVersion {
    <#
    .SYNOPSIS
    Sets the version to be used in the Cab package creation.
    
    .DESCRIPTION
    Sets the environment variable used for Cab package creation (Env:BSP_VERSION). Also updates the version in the IoTWorkspace xml file.
    
    .PARAMETER version
    Specifies the version value to be set. This version has to be a four part version number.
    
    .EXAMPLE
    Set-IoTCabVersion 10.0.1.0
    
    .NOTES
    The alias for this is setversion
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$version
    )    

    if ($null -ne $env:IoTWsXml) {
        #TODO: validate version
        $wkspace = New-IoTWorkspaceXML $env:IoTWsXml
        $wkspace.SetVersion($version)
        [System.Environment]::SetEnvironmentVariable("BSP_VERSION", $version)
        $CmdFile = "$env:IOTWKSPACE\Build\Version.cmd"
        Set-Content -Path $CmdFile -Value "set BSP_VERSION=$env:BSP_VERSION"
        Add-Content -Path $CmdFile -Value "set PROMPT=IoTCoreShell %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%`$_`$P`$G"
        Add-Content -Path $CmdFile -Value "TITLE IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%"
        if (($null-ne $host) -and ($null -ne $host.ui) -and ($null -ne $host.ui.RawUI) -and ($null -ne $host.ui.RawUI.WindowTitle)) {
            $host.ui.RawUI.WindowTitle = "IoTCorePSShellv$env:IOT_ADDON_VERSION $env:BSP_VERSION %SIGN_MODE%"
        }
    }
    else { Publish-Error "IoTWorkspace is not opened. Use Open-IoTWorkspace" }
}

function Write-IoTVersions {
    <#
    .SYNOPSIS
    Writes the relevant versions that are useful for debugging.
    
    .DESCRIPTION
    Writes the relevant versions that are useful for debugging.
    
    .EXAMPLE
    Write-IoTVersions
    
    .NOTES
    #>
    Publish-Status "ADK_VERSION : $env:ADK_VERSION"
    Publish-Status "IOTCORE_VER : $env:IOTCORE_VER"
    Publish-Status "BSP_VERSION : $env:BSP_VERSION"
    #Get Host Information
    $pOS = Get-CimInstance Win32_OperatingSystem

    Publish-Status "HostOS Info : $($pOS.Caption) - $($pOS.Version) - $($pOS.MUILanguages)"
}

function Set-IoTRetailSign {
    <#
    .SYNOPSIS
    Sets the signing certificate to the retail cert or test cert.
    
    .DESCRIPTION
    Sets the environment variable used for code signing to the retail certificate (specified in Workspace xml as RetailSignToolParam when the mode parameter is on. When its off, it sets to the test certificate.
    
    .PARAMETER Mode
    On/Off, specifies if retail certificate to be set or not.
    
    .EXAMPLE
    Set-IoTRetailSign On
    
    .NOTES
    The alias for this is retailsign
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateSet("On", "Off")]
        [String]$Mode
    )    

    if ($null -ne $env:IoTWsXml) {
        $wkspace = New-IoTWorkspaceXML $env:IoTWsXml
        $config = $wkspace.GetConfig()
        $signtoolparam = ""
        if ($Mode -ieq "On") {
            $signtoolparam = $config.RetailSignToolParam
            if ([string]::IsNullOrWhiteSpace($signtoolparam)) {
                Publish-Error "RetailSignToolParam is not specified. Retail mode is not on."
            }
        }
        Set-IoTSignature $signtoolparam
        $CmdFile = "$env:IOTWKSPACE\Build\SetPrompt.cmd"
        Set-Content -Path $CmdFile -Value "set SIGN_MODE=$env:SIGN_MODE"
        Add-Content -Path $CmdFile -Value "set PROMPT=IoTCoreShell %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%`$_`$P`$G"
        Add-Content -Path $CmdFile -Value "TITLE IoTCoreShellv%IOT_ADDON_VERSION% %BSP_ARCH% %BSP_VERSION% %SIGN_MODE%"
        if (($null-ne $host) -and ($null -ne $host.ui) -and ($null -ne $host.ui.RawUI) -and ($null -ne $host.ui.RawUI.WindowTitle)) {
            $host.ui.RawUI.WindowTitle = "IoTCorePSShellv$env:IOT_ADDON_VERSION $env:BSP_VERSION $env:SIGN_MODE"
        }
    }
    else { Publish-Error "IoTWorkspace is not opened. Use Open-IoTWorkspace" }
}

function Set-IoTSignature {
    <#
    .SYNOPSIS
    Sets the signing related env vars with the cert information provided.
    
    .DESCRIPTION
    Sets the signing related env vars with the cert information provided.
    
    .PARAMETER SignParam
    The parameters of the sign tool to select the certificate to sign. 
   
    .EXAMPLE
    Set-IoTSignature "/a /s my /i `"Windows OEM Intermediate 2017 (TEST ONLY)`" /n `"Windows OEM Test Cert 2017 (TEST ONLY)`" /fd SHA256"
    
    .NOTES
    See Code signing requirements for more details.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [String]$SignParam
    )
    # Check for valid parameters
    if ([string]::IsNullOrWhiteSpace($signparam)) {
        Write-Debug "Setsignature : Using default test certs"
        [System.Environment]::SetEnvironmentVariable("SIGN_WITH_TIMESTAMP", 0)
        #TODO : Remove this hardcoding and read from xml file
        [System.Environment]::SetEnvironmentVariable("SIGNTOOL_OEM_SIGN", "/a /s my /i `"Windows OEM Intermediate 2017 (TEST ONLY)`" /n `"Windows OEM Test Cert 2017 (TEST ONLY)`" /fd SHA256")
        [System.Environment]::SetEnvironmentVariable("SIGN_MODE", "Test")
    }
    else {
        #TODO : Check if the cert is installed on the machine. If not error out.
        [System.Environment]::SetEnvironmentVariable("SIGN_WITH_TIMESTAMP", 1)
        [System.Environment]::SetEnvironmentVariable("SIGNTOOL_OEM_SIGN", $signparam)
        [System.Environment]::SetEnvironmentVariable("SIGN_MODE", "Retail")
    }
}

function Copy-IoTOEMPackage {
    <#
    .SYNOPSIS
    Copies an OEM package to the destination workspace from a source workspace.
    
    .DESCRIPTION
    Copies an OEM package to the destination workspace from a source workspace and updates the corresponding FM file with the feature id. 
 
    .PARAMETER Source
    Mandatory parameter specifying the source workspace directory.
    
    .PARAMETER Destination
    Mandatory parameter specifying the destination workspace directory.

    .PARAMETER PkgName
    Mandatory parameter, specifying the package name, typically of namespace.name format. Wild cards supported.

 
    .EXAMPLE
    Copy-IoTOEMPackage $env:SAMPLEWKS $env:IOTWKSPACE Appx.MyApp
    Copies the Appx.MyApp package from $env:SAMPLEWKS to current workspace.
    
    .EXAMPLE    
    Copy-IoTOEMPackage $env:SAMPLEWKS C:\DestWkspace *
    Copies all packages from $env:SAMPLEWKS to DestWkspace
    
    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_\IoTWorkspace.xml -PathType Leaf })]
        [String]$Source,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( { Test-Path $_\IoTWorkspace.xml -PathType Leaf })]
        [String]$Destination,
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PkgName
    )
    $copydone = $false
    $filter = $PkgName
    $commondir = "$Source\Common\Packages"
    $commonprod = "$Source\Common\ProdPackages"
    $commonfm = New-IoTFMXML "$commondir\OEMCommonFM.xml"
    $destcommonfm = New-IoTFMXML "$Destination\Common\Packages\OEMCommonFM.xml"
    $sourcedir = "$Source\Source-$($env:arch)\Packages"
    $sourcefm = New-IoTFMXML "$sourcedir\OEMFM.xml"
    $destoemfm = New-IoTFMXML "$Destination\Source-$($env:arch)\Packages\OEMFM.xml"
    $pkgs = (Get-ChildItem -Path $commondir, $sourcedir, $commonprod -Directory -Filter $filter ) | ForEach-Object {$_.FullName}
    if (!$pkgs) {
        Publish-Error "No packages found matching $PkgName"
        return
    }
    foreach ($pkg in $pkgs) {
        $destpkg = $pkg.Replace($Source, $Destination)
        if (Test-Path $destpkg) {
            Publish-Warning "$destpkg already exist."
        }
        else {
            Write-Debug "Copying $pkg"
            Copy-Item -Path $pkg -Destination $destpkg -Recurse | Out-Null
            $copydone = $true
            $pkgname = Split-Path -Path $pkg -Leaf
            $pkgname = "%OEM_NAME%.$pkgname.cab"
            if ($pkg.Contains("\Common\") ) {
                $srcfm = $commonfm
                $dstfm = $destcommonfm
            }
            else {
                $srcfm = $sourcefm
                $dstfm = $destoemfm
            }
            $fids = $srcfm.GetFeatureForPackage($pkgname)
            Write-Debug "Adding $($fids -join ",") for $pkgname"
            if ($fids) {
                $dstfm.AddOEMPackage("%PKGBLD_DIR%", $pkgname, $fids)
            }
            else { Write-Verbose "$pkgname is not added to feature manifest"}
        }  
    }
    Publish-Success "Package copy completed" 
}

function Import-IoTOEMPackage {
    <#
    .SYNOPSIS
    Imports an OEM package in to the current workspace from a source workspace.
    
    .DESCRIPTION
    Imports an OEM package in to the current workspace from a source workspace and updates the corresponding FM file with the feature id. 
 
    .PARAMETER PkgName
    Mandatory parameter, specifying the package name, typically of namespace.name format. Wild cards supported.

    .PARAMETER SourceWkspace
    Optional parameter specifying the source workspace directory.
    
    .EXAMPLE
    Import-IoTOEMPackage Appx.MyApp C:\MyWorkspace
    Imports Appx.MyApp package from C:\MyWorkspace

    .EXAMPLE    
    Import-IoTOEMPackage *
    Imports all the packages in the sample workspace that comes along with tooling. ($env:SAMPLEWKS)
    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PkgName,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$SourceWkspace
    )

    if (([String]::IsNullOrWhiteSpace($SourceWkspace)) -or
        ((Test-Path $SourceWkspace\IoTWorkspace.xml -PathType Leaf) -eq $false))
    {
        if ([String]::IsNullOrWhiteSpace($env:SAMPLEWKS))
        {
            Publish-Error "`$env:SAMPLEWKS is missing"
            return
        }
        $SourceWkspace = $env:SAMPLEWKS
    }

    if ([String]::IsNullOrWhiteSpace($env:IOTWKSPACE))
    {
        Publish-Error "`$env:IOTWKSPACE is missing"
        return
    }

    Copy-IoTOEMPackage $SourceWkspace $env:IOTWKSPACE $PkgName
}

function Copy-IoTBSP {
    <#
    .SYNOPSIS
    Copies a BSP folder to the destination workspace from a source workspace or a source bsp directory.
    
    .DESCRIPTION
    Copies a BSP folder to the destination workspace from a source workspace. 
 
    .PARAMETER Source
    Mandatory parameter specifying the source workspace or a source bsp directory.
    
    .PARAMETER Destination
    Mandatory parameter specifying the destination workspace directory.

    .PARAMETER BSPName
    Mandatory parameter, specifying the BSP name, wildcards supported.
  
    .EXAMPLE
    Copy-IoTBSP C:\MyWorkspace $env:IOTWKSPACE RPi
    Copies RPi BSP from C:\MyWorkspace to current workspace
   
    .EXAMPLE
    Copy-IoTBSP C:\MyBspDir C:\MyWorkspace MyBSP
    Copies MyBSP from C:\MyBspDir to C:\MyWorkspace
    
    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Source,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( { Test-Path $_\IoTWorkspace.xml -PathType Leaf })]
        [String]$Destination,        
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$BSPName
    )

    if ($Source.EndsWith(".zip")) {
        $tempdir = "$env:IOTWKSPACE\BSPDIR"
        # Clean out the temporary folder silently
        Remove-Item -Recurse -ErrorAction SilentlyContinue -Force $tempdir

        Add-Type -Assembly System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($Source)
        Write-Host "Extracting BSP zip into the temporary directory $tempdir"
        [System.IO.Compression.ZipFileExtensions]::ExtractToDirectory($zip, "$tempdir")
        $zip.Dispose()
        $fmfiles = (Get-ChildItem -Path "$tempdir" -Filter *FM.xml -Recurse) | foreach-object {$_.FullName}
        if (!$fmfiles){
            Publish-Error "No FM files found in $Source." 
            return
        }
        #if more than one fm file, picking up first. 
        #TODO relook as this logic again
        if ($fmfiles.Count -gt 1){
            $fmfilepath  = Split-Path -Path $fmfiles[0] -Parent
        }
        else {
            $fmfilepath = Split-Path -Path $fmfiles -Parent
        }
        $bspdir = Split-Path -Path $fmfilepath -Parent
        $srcdir = Split-Path -Path $bspdir -Parent
    } 
    elseif (Test-Path $Source\IoTWorkspace.xml -PathType Leaf){
        $srcdir = "$Source\Source-$($env:arch)\BSP"
    }
    else {
        $srcdir = "$Source"
    }
    # Validate if the bsp is present in the dir
    $destdir = "$Destination\Source-$($env:arch)\BSP"
    $copydone = $false
    $bsps = (Get-ChildItem -Path $srcdir -Directory -Filter $BSPName ) | foreach-object { $_.Name }
    if (!$bsps) { 
        Publish-Error "No Bsp matching $BSPName found in $Source" 
        return
    }
    foreach ($bsp in $bsps) {
        Publish-Status "Processing $srcdir\$bsp"
        if (Test-Path -Path $destdir\$bsp -PathType Container) {
            Publish-Warning "$bsp already exists" 
            continue       
        }
        # validate if the folder is a BSP folder
        $fmfiles = (Get-ChildItem -Path "$srcdir\$bsp" -Filter *FM.xml -Recurse) | foreach-object {$_.FullName}
        if (!$fmfiles){
            Publish-Error "No FM files found. $srcdir\$bsp is not a valid BSP directory"
            continue
        }
        if (!(Test-Path "$srcdir\$bsp\OEMInputSamples\TestOEMInput.xml")){
            Publish-Error "$srcdir\$bsp\OEMInputSamples\TestOEMInput.xml not found. $srcdir\$bsp is not a valid BSP directory"
            continue
        }
        if (!(Test-Path "$srcdir\$bsp\Packages\$($bsp)FMFileList.xml")){
            Publish-Error "$($bsp)FMFileList.xml not found. $srcdir\$bsp is not a valid BSP directory"
            continue
        }
        $xmldoc = [xml] (Get-Content -Path "$srcdir\$bsp\Packages\$($bsp)FMFileList.xml")
        $arch = $xmldoc.FMCollectionManifest.FMs.FM.CPUType
        if($env:BSP_ARCH -ne $arch){
            Publish-Error "Incorrect BSP arch. Found $arch, expected $env:BSP_ARCH"
            continue
        }

        Write-Verbose "Copying $bsp"
        Copy-Item -Path $srcdir\$bsp -Destination $destdir\ -Recurse -Force | Out-Null
        # Convert pkg xmls to wm xml
        Write-Verbose "Converting pkg.xml files"
        $copydone = Convert-IoTPkg2Wm $destdir\$bsp
        # get rid of the FeatureIdentifierPackage flag in the FM file
        $fmfiles = (Get-ChildItem -Path "$destdir\$bsp" -Filter *FM.xml -Recurse) | foreach-object {$_.FullName}
        if (!$fmfiles){
            # should not occur if the copy succeeded.
            Publish-Error "BSP copy failed" 
            continue
        }
        # replace the absolute path of the bspFM files to the mergedfm directory , also fixing any naming inconsistencies 
        foreach($fmfile in $fmfiles){
            Write-Verbose "Updating $fmfile.." 
            (Get-Content $fmfile) -replace "FeatureIdentifierPackage=`"true`"", "" | Out-File $fmfile -Encoding utf8
            #TODO Get rid of the System Information cab as SMBIOS will fill those values.
            #Get all package names in the directory
            $list = Get-ChildItem -Path $destdir\$bsp -Recurse -Include *.xml | Select-String "legacyName"
            $pkgnames = $list | ForEach-Object { $_.Line.Replace("`$(OEMNAME)","%OEM_NAME%").Split('"')[1] + ".cab"}
            $fmxml = New-IoTFMXML $fmfile
            $definedpkgs = $fmxml.GetPackageNames()
            foreach($definedpkg in $definedpkgs){
                if (-not $pkgnames.contains($definedpkg)) { 
                    $subcomponentname = $definedpkg.Split(".")[2]
                    foreach($pkgname in $pkgnames) {
                        if ($pkgname.contains($subcomponentname)){
                            $pkgname= $pkgname.Replace(".cab","")
                            $definedpkg = $definedpkg.Replace(".cab","") 
                            Publish-Warning "  Replacing $definedpkg with $pkgname"
                            (Get-Content $fmfile) -replace $definedpkg, $pkgname | Out-File $fmfile -Encoding utf8
                        }
                    }
                }
            }
        }

        $oeminputs = (Get-ChildItem -Path "$destdir\$bsp" -Filter *OEMInput.xml -Recurse) | foreach-object {$_.FullName}
        if (!$oeminputs){
            # should not occur if the copy succeeded.
            Publish-Error "BSP copy failed" 
            continue
        }
        # replace the absolute path of the bspFM files to the mergedfm directory
        foreach($oeminput in $oeminputs){
            Write-Verbose "Updating $oeminput.." 
            (Get-Content $oeminput) -replace "%BSPSRC_DIR%\\$($BSPName)\\Packages", "%BLD_DIR%\MergedFMs" | Out-File $oeminput -Encoding utf8
        }
        $copydone = $true
    }
    if ($Source.EndsWith(".zip")) {
        # Clean out the temporary folder silently
        Remove-Item -Recurse -ErrorAction SilentlyContinue -Force $tempdir
    }
    if ($copydone){
        Publish-Success "BSP copy completed"
    }
}

function Import-IoTBSP {
    <#
    .SYNOPSIS
    Imports a BSP folder in to the current workspace from a source workspace or a source bsp directory or a source zip file.
    
    .DESCRIPTION
    Imports a BSP folder in to the current workspace from a source workspace or a source bsp directory or a source zip file. 

    .PARAMETER BSPName
    Mandatory parameter, specifying the BSP to import, wildcard supported.
    
    .PARAMETER Source
    Optional parameter specifying the source workspace or source bsp directory or a source zip file. Default is $env:SAMPLEWKS
    
    .EXAMPLE
    Import-IoTBSP RPi2 C:\MyWorkspace
    Imports RPi2 bsp from C:\MyWorkspace

    .EXAMPLE
    Import-IoTBSP  *
    Imports all bsps from $env:SAMPLEWKS
    
    .EXAMPLE
    Import-IoTBSP MyBSP C:\MyBSPFolder 
    Imports MyBSP from C:\MyBSPFolder

    .EXAMPLE
    Import-IoTBSP BYTx64 C:\Downloads\BYT_Win10_IOT_Core_MR1_BSP_337014-003.zip 
    Imports BYTx64 from C:\Downloads\BYT_Win10_IOT_Core_MR1_BSP_337014-003.zip file

    .EXAMPLE
    Import-IoTBSP RPi2 C:\RPi_BSP.zip 
    Imports RPi2 from C:\RPi_BSP.zip

    .EXAMPLE
    Import-IoTBSP Sabre_iMX6Q_1GB C:\Temp\NXPBSP.zip
    Imports Sabre_iMX6Q_1GB from C:\Temp\NXPBSP.zip

    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$BSPName,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$Source
    )

    if ([String]::IsNullOrWhiteSpace($Source))
    {
        if ([String]::IsNullOrWhiteSpace($env:SAMPLEWKS))
        {
            Publish-Error "`$env:SAMPLEWKS is missing"
            return
        }
        $Source = $env:SAMPLEWKS
    }

    if ([String]::IsNullOrWhiteSpace($env:IOTWKSPACE))
    {
        Publish-Error "`$env:IOTWKSPACE is missing"
        return
    }

    Copy-IoTBSP $Source $env:IOTWKSPACE $BSPName
}

function Copy-IoTProduct {
    <#
    .SYNOPSIS
    Copies a product folder to the destination workspace from a source workspace.
    
    .DESCRIPTION
    Copies a product folder to the destination workspace from a source workspace. 
 
    .PARAMETER Source
    Mandatory parameter specifying the source workspace directory.
    
    .PARAMETER Destination
    Mandatory parameter specifying the destination workspace directory.

    .PARAMETER ProductName
    Mandatory parameter, specifying the Product, supports wild cards

    .EXAMPLE
    Copy-IoTProduct $env:SAMPLEWKS $env:IOTWKSPACE SampleA
    Copies SampleA from SampleWkspace to current workspace

    .EXAMPLE
    Copy-IoTProduct $env:SAMPLEWKS $env:IOTWKSPACE *
    Copies all products from SampleWkspace to current workspace

    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_\IoTWorkspace.xml -PathType Leaf })]
        [String]$Source,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateScript( { Test-Path $_\IoTWorkspace.xml -PathType Leaf })]
        [String]$Destination,        
        [Parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ProductName
    )
    $srcdir = "$Source\Source-$($env:arch)\Products"
    $destdir = "$Destination\Source-$($env:arch)\Products"
    $copydone = $false
    $products = (Get-ChildItem -Path $srcdir -Directory -Filter $ProductName ) | foreach-object { $_.Name }
    if (!$products) { 
        Publish-Error "No matching product found for $ProductName in $Source" 
        return
    }
    foreach ($product in $products) {
        if (Test-Path -Path $destdir\$product -PathType Container) {
            Publish-Warning "$product already exists"        
        }
        else {
            Write-Debug "Copying $product"
            Copy-Item -Path $srcdir\$product -Destination $destdir\ -Recurse | Out-Null
            $copydone = $true
        }
    }
    if ($copydone) { Write-Verbose "Product copy completed" }
}


function Import-IoTProduct {
    <#
    .SYNOPSIS
    Imports a product folder in to the current workspace from a source workspace.
    
    .DESCRIPTION
    Imports a product folder in to the current workspace from a source workspace.
 
    .PARAMETER ProductName
    Mandatory parameter, specifying the Product, wildcards supported.

    .PARAMETER SourceWkspace
    Optional parameter specifying the source workspace directory. Default is $env:SAMPLEWKS
     
    .EXAMPLE
    Import-IoTProduct SampleA C:\MyWorkspace
    Imports SampleA product from C:\MyWorkspace

    .EXAMPLE
    Import-IoTProduct *
    Imports all products from $env:SAMPLEWKS

    .NOTES
    See Add-IoT* and Import-IoT* methods.
    #>
    [CmdletBinding()]
    Param
    (

        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ProductName,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$SourceWkspace
    )

    if (([String]::IsNullOrWhiteSpace($SourceWkspace)) -or
        ((Test-Path $SourceWkspace\IoTWorkspace.xml -PathType Leaf) -eq $false))
    {
        if ([String]::IsNullOrWhiteSpace($env:SAMPLEWKS))
        {
            Publish-Error "`$env:SAMPLEWKS is missing"
            return
        }
        $SourceWkspace = $env:SAMPLEWKS
    }

    if ([String]::IsNullOrWhiteSpace($env:IOTWKSPACE))
    {
        Publish-Error "`$env:IOTWKSPACE is missing"
        return
    }

    Copy-IoTProduct $SourceWkspace $env:IOTWKSPACE $ProductName
}

function Redo-IoTWorkspace {
    <#
    .SYNOPSIS
    Updates an old iot-adk-addonkit folder with required xml files to make it a proper workspace.
    
    .DESCRIPTION
    Updates an old iot-adk-addonkit folder to a proper workspace.
    - creates the IoTWorkspace.xml parsing the setoem.cmd / versioninfo.txt files.
    - prompts to gather SMBIOS information for every product.
    - fixes the wm.xml using ppkg files to point to correct path and also include the .cat files
    - deletes old Custom.Cmd and Provisioning.Auto pkgs and copies the new versions to ProdPackages folder
    - regenerates all driver packages to the new wm.xml

    
    .PARAMETER Dir
    Mandatory parameter for the old iot-adk-addonkit location
    
    .EXAMPLE
    Redo-IoTWorkspace C:\iot-adk-addonkit
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)][ValidateNotNullOrEmpty()][String]$DirName
    )
    if (-not (Test-Path $DirName -PathType Container)) {
        throw "$DirName is not an existing directory"
    }

    # Create IoTWorkspace.xml
    Publish-Status "Creating workspace xml"
    $setoemcmd = "$DirName\Tools\setOEM.cmd" 
    if (!(Test-Path $setoemcmd)) {
        Publish-Error "setOEM.cmd file not found. $DirName is not an iot-adk-addonkit folder"
        return
    }
    Remove-ItemIfExist $DirName\IoTWorkspace.xml

    $bsppkgdir = "%PKGBLD_DIR%"
    $setoemfile = Get-Content -Path $setoemcmd
    foreach ($line in $setoemfile) {
        $line = $line.Replace("set ", "")
        $values = $line.Split("=")
        if ($values[0] -ieq "OEM_NAME") {
            $OemName = $values[1]
        }
        elseif ($values[0] -ieq "BSPPKG_DIR") {
            $bsppkgdir = $values[1]
        }
    }
    $retailsign = "Undefined"
    $setsigfile = Get-Content -Path "$DirName\Tools\setsignature.cmd"
    foreach ($line in $setsigfile) {
        $line = $line.Replace("set ", "")
        $values = $line.Split("=")
        if ($values[0] -ieq "SIGNTOOL_OEM_SIGN") {
            $retailsign = $values[1]
        }
    }
    # Files to delete
    $todeletedir = "$DirName\ToDelete"
    New-DirIfNotExist $todeletedir
    # move old code to the todelete folder
    Move-Item -Path "$DirName\Tools" -Destination $todeletedir -Force
    Move-Item -Path "$DirName\Templates" -Destination $todeletedir -Force
    Move-Item -Path "$DirName\*.cmd" -Destination $todeletedir -Force

    $wsdoc = New-IoTWorkspaceXML $DirName\IoTWorkspace.xml -Create $OemName
    $supportedarchs = @()
    foreach ($arch in [IoTWorkspaceXML]::EnvArchs) {
        Publish-Status "Looking into $arch folders"
        $verinfo = "$DirName\Source-$arch\Packages\versioninfo.txt"
        if (Test-Path $verinfo) {
            $version = Get-Content -Path $verinfo
            $supportedarchs += $arch
            $result = $wsdoc.AddEnv($arch)
            $cfg = $wsdoc.GetEnvConfig($arch)
            $cfg.BSPVersion = [string]$version
            $cfg.BSPPkgDir = $bsppkgdir
            $wsdoc.SetEnvConfig($arch, $cfg)
            if ($result) {
                Remove-Item $verinfo
            }
        }
    }
    if ($retailsign -ne "Undefined"){
        $config = @{
            "RetailSignToolParam" = "$retailsign"
        }
        $wsdoc.SetConfig($config)
    }
    Write-CmdShortcut $DirName

    # Delete old custom.cmd and Provisioning .auto and copy new ones
    if (Test-Path $env:COMMON_DIR\ProdPackages ) {
        Copy-Item -Path "$env:COMMON_DIR\ProdPackages" -Destination "$DirName\Common\" -Recurse -Force | Out-Null
        Remove-ItemIfExist "$DirName\Common\Packages\Custom.Cmd"
        Remove-ItemIfExist "$DirName\Common\Packages\Provisioning.Auto"
    }

    # Process all products
    Publish-Status "Processing Products with temporary SMBIOS values"
    foreach ($arch in $supportedarchs) {
        # Create the ProductConfig xml file for each existing product
        $productsdir = "$DirName\Source-$arch\Products"
        $products = Get-ChildItem $productsdir -Directory
        foreach ($prod in $products) {
            Write-Verbose "  Processing $prod"
            $proddir = "$productsdir\$prod"
            $prodpkgdir = "$proddir\Packages"
            $CUSdir = "$proddir\CUSConfig"
            if (Test-Path $CUSdir) {
                New-DirIfNotExist $prodpkgdir
                Move-Item $CUSdir -Destination $prodpkgdir\ -Force | Out-Null
            }
            $prodconfigxml = "$productsdir\$prod\$($prod)Settings.xml"
            $settingsxml = New-IoTProductSettingsXML $prodconfigxml -Create $OemName Family SKU BBMfg BBProd $bsppkgdir
            $settings = @{
                "Name" = "$prod"
                "Arch" = "$arch"
            }
            $settingsxml.SetSettings($settings)
            $smbioscfg = "$productsdir\$prod\SMBIOS.CFG"
            if (Test-Path $smbioscfg) {
                $smbios = Get-SMBIOSData $smbioscfg
                $settingsxml.SetSMBIOS($smbios)
            }
         }
    }
    
    # Process the ppkg files
    Publish-Status "Processing provisioning packages"
    $custfiles = (Get-ChildItem -Path "$DirName" -Filter customizations.xml -Recurse ) | ForEach-Object {$_.FullName}
    foreach ($custfile in $custfiles) {
        Write-Verbose " Processing $custfile"
        $pkgdir = Split-Path -Path $custfile -Parent
        $OutputName = Split-Path -Path $pkgdir -Leaf
        if ($OutputName -ieq "Templates") { 
            continue 
        } elseif ($OutputName -ieq "prov") {
            Write-Verbose "   Creating ICD project file"
            $provxml = New-IoTProvisioningXML $custfile
            $provxml.CreateICDProject()
            continue
        }
        Remove-ItemIfExist "$pkgdir\$OutputName.pkg.xml"
        $wmxml = "$pkgdir\$OutputName.wm.xml"
        $provpath = "`$(runtime.windows)\Provisioning\Packages"
        if (Test-Path $wmxml) {
            $xml = [xml] (Get-Content $wmxml)
            $provpath = $xml.identity.files.file.destinationDir
            Write-Verbose "Using provpath :$provpath"
            Remove-Item $wmxml
        }
        $namespart = $OutputName.Split(".")
        $wmwriter = New-IoTWMWriter $pkgdir $namespart[0] $namespart[1]
        $wmwriter.Start($null)
        $wmwriter.AddFiles($provpath, "`$(BLDDIR)\ppkgs\" + $OutputName + ".ppkg", $OutputName + ".ppkg")
        $wmwriter.AddFiles($provpath, "`$(BLDDIR)\ppkgs\" + $OutputName + ".cat", $OutputName + ".cat")
        $wmwriter.Finish()
    }

    # process all driver files
    Publish-Status "Processing driver packages"
    $drvfiles = (Get-ChildItem -Path "$DirName" -Filter *.inf -Recurse ) | ForEach-Object {$_.FullName}
    foreach ($drvfile in $drvfiles) {
        if ($drvfile.Contains("WinPEExt")) { continue }
        Write-Verbose " Recreating wm.xml for $drvfile"
        $filename = Split-Path -Path $drvfile -Leaf
        $pkgdir = Split-Path -Path $drvfile -Parent
        $OutputName = Split-Path -Path $pkgdir -Leaf
        $namespart = @()
        if ($OutputName.Contains(".")) {
            $namespart = $OutputName.Split(".")
            Remove-ItemIfExist "$pkgdir\$OutputName.pkg.xml"
            Remove-ItemIfExist "$pkgdir\$OutputName.wm.xml"
        }
        else {
            $namespart += "Drivers"
            $namespart += $OutputName
            Remove-ItemIfExist "$pkgdir\Drivers.$OutputName.pkg.xml"
            Remove-ItemIfExist "$pkgdir\Drivers.$OutputName.wm.xml" 
        }

        $wmwriter = New-IoTWMWriter $pkgdir $namespart[0] $namespart[1]
        $wmwriter.Start($null)
        $wmwriter.AddDriver($filename)
        $wmwriter.Finish()
    }
    # Warn about Recovery.WinPE in the bsp folder and the bspfm file

    # process all driver files
    Publish-Status "Converting pkg xml to wm xml"
    Convert-IoTPkg2Wm $DirName 
}

function Get-SMBIOSData ( [ValidateNotNullOrEmpty()][string] $file ) {
    $smbios = @{}
    Publish-Status "Parsing $file to get SMBIOS information"
    $doc = Get-Content $file
    foreach ($line in $doc) {
        $parts = $line.Split(",")
        if ($parts[0] -eq "01") {
            switch ($parts[1]) {
                '04' {
                    $Manufacturer = $parts[3] -replace '"', ""
                    $smbios.Add("Manufacturer", $Manufacturer)
                    Publish-Status "Manufacturer : $Manufacturer"
                    break
                }
                '05' {
                    $ProductName = $parts[3] -replace '"', ""
                    $smbios.Add("ProductName",$ProductName)
                    Publish-Status "Product Name : $ProductName"
                    break
                }
                '19' {
                    $SKUNumber = $parts[3] -replace '"', ""
                    $smbios.Add("SKUNumber", $SKUNumber)
                    Publish-Status "SKU Number   : $SKUNumber"
                    break
                }
                '1A' {
                    $Family = $parts[3] -replace '"', ""
                    $smbios.Add("Family", $Family)
                    Publish-Status "Family       : $Family"
                    break
                }
            }
        }
    }
    $smbios
}

function Get-IoTWorkspaceProducts {
    <#
    .SYNOPSIS
    Returns the list of product names in the workspace.

    .DESCRIPTION
    Returns the list of product names in the specified workspace or from the $env:SAMPLEWKS.
    The workspace's architecture is used to determine which architecture to search.

    .PARAMETER SourceWkspace
    Optional parameter, specifies the workspace to search. Default is from the $env:SAMPLEWKS.

    .EXAMPLE
    Get-IoTWorkspaceProducts
    Returns the products from the default workspace.

    .EXAMPLE
    Get-IoTWorkspaceProducts C:\IoTWorkSpaces\Workspace
    Returns the products from the specified workspace

    .NOTES
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [String]$SourceWkspace
    )
    $retval = @()

    if (([String]::IsNullOrWhiteSpace($SourceWkspace)) -or
        ((Test-Path $SourceWkspace\IoTWorkspace.xml -PathType Leaf) -eq $false))
    {
        if ([String]::IsNullOrWhiteSpace($env:SAMPLEWKS))
        {
            Publish-Error "`$env:SAMPLEWKS is missing"
            return $retval
        }
        $SourceWkspace = $env:SAMPLEWKS
    }

    if ([String]::IsNullOrWhiteSpace($env:arch))
    {
        Publish-Error "`$env:ARCH is missing"
        return $retval
    }

    $srcdir = "$SourceWkspace\Source-$($env:arch)\Products"
    $products = (Get-ChildItem -Path $srcdir -Directory) | foreach-object { $_.Name }
    if (!$products) { 
        Publish-Error "No products found in $srcdir"
        return $retval
    }

    $retval += $products
    return $retval
}

function Get-IoTWorkspaceBSPs {
    <#
    .SYNOPSIS
    Returns the list of BSP names in the workspace.

    .DESCRIPTION
    Returns the list of BSP names in the specified workspace or from the $env:SAMPLEWKS.
    The workspace's architecture is used to determine which architecture to search.

    .PARAMETER SourceWkspace
    Optional parameter, specifies the workspace to search. Default is from the $env:SAMPLEWKS.

    .EXAMPLE
    Get-IoTWorkspaceBSPs
    Returns the BSPs from the default workspace.

    .EXAMPLE
    Get-IoTWorkspaceBSPs C:\IoTWorkSpaces\Workspace
    Returns the BSPs from the specified workspace

    .NOTES
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $false)]
        [String]$SourceWkspace
    )
    $retval = @()

    if (([String]::IsNullOrWhiteSpace($SourceWkspace)) -or
        ((Test-Path $SourceWkspace\IoTWorkspace.xml -PathType Leaf) -eq $false))
    {
        if ([String]::IsNullOrWhiteSpace($env:SAMPLEWKS))
        {
            Publish-Error "`$env:SAMPLEWKS is missing"
            return $retval
        }
        $SourceWkspace = $env:SAMPLEWKS
    }

    if ([String]::IsNullOrWhiteSpace($env:arch))
    {
        Publish-Error "`$env:ARCH is missing"
        return $retval
    }

    $srcdir = "$SourceWkspace\Source-$($env:arch)\BSP"
    $BSPs = (Get-ChildItem -Path $srcdir -Directory) | foreach-object { $_.Name }
    if (!$BSPs) {
        Publish-Error "No BSPs found in $srcdir"
        return $retval
    }

    $retval += $BSPs
    return $retval
}

function Import-QCBSP {
    <#
    .SYNOPSIS
    Import QC BSP into your workspace and update the bsp files as required by the latest tools.

    .DESCRIPTION
    Import QC BSP into your workspace and update the bsp files as required by the latest tools.

    .PARAMETER BSPZipFile
    Mandatory parameter, BSP Zip file from QC.

    .PARAMETER BSPPkgDir
    Mandatory parameter, Location where to extract the required BSP cab files.

    .PARAMETER ImportBSP
    Optional switch parameter, to import the QCDB410C BSP.

    .EXAMPLE
    Import-QCBSP C:\Temp\db410c_bsp.zip C:\QCBSP -ImportBSP

    .NOTES
    You will need to download the QC BSP from the QC website first before using this method
    #>
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$BSPZipFile,
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$BSPPkgDir,
        [Parameter(Position = 2, Mandatory = $false)]
        [Switch]$ImportBSP
    )

    if ($env:ARCH -ine "arm") {
        Write-Error "Incorrect architecture. setenv arm"
        return
    }
    if ($ImportBSP){
        Import-IoTBSP QCDB410C
    }
    $qcfmxml = "$env:BSPSRC_DIR\QCDB410C\Packages\QCDB410CFM.xml"

    New-DirIfNotExist $BSPPkgDir -Force

    $fmobj = New-IoTFMXML $qcfmxml
    $pkglist = $fmobj.GetPackageNames()
    #skipping parsing QCDB410CTestFM.xml. Just one entry hardcoded here.
    $pkglist += "Qualcomm.QC8916.UEFI.cab" 

    $exceptionlist = @(
        'Qualcomm.QC8916.OEMDevicePlatform.cab'
        'Qualcomm.QC8916.qcMagAKM8963.cab'
        'Qualcomm.QC8916.qcAlsPrxAPDS9900.cab'
        'Qualcomm.QC8916.qcAlsCalibrationMTP.cab'
        'Qualcomm.QC8916.qcTouchScreenRegsitry1080p.cab'
    )

    #Expand-Archive -Path $BSPZipFile -DestinationPath $BSPPkgDir
    Add-Type -Assembly System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($BSPZipFile)
    $zip.Entries | Where-Object {$_.Name -like '*.cab'} | ForEach-Object {
        $filename = Split-Path -Path $_ -Leaf
        if ($pkglist -contains $filename) {
            if ($exceptionlist -contains $filename) {
                Write-Debug "---> Exception $filename"
                $filepath = Split-Path -Path $_ -Parent
                $dirname = Split-Path -Path $filepath -Leaf
                if ($filename -ieq "Qualcomm.QC8916.OEMDevicePlatform.cab") {
                    if (($dirname -ieq "SBC") -and (!($filepath.Contains("8916")))) {
                        Write-Host "Extracting $_"
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$BSPPkgDir\$filename", $true)
                    }
                    else { Write-Debug "Skipping $_" }
                }
                else {
                    #For other exception files, take content from MTP directory
                    if ($dirname -ieq "MTP") {
                        Write-Host "Extracting $_"
                        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$BSPPkgDir\$filename", $true)
                    }
                    else { Write-Debug "Skipping $filepath" }
                }
            }
            else {
                Write-Host "Extracting $_"
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$BSPPkgDir\$filename", $true)
            }
        }
    }

    Publish-Success "BSP import completed"

    $zip.Dispose()
}
