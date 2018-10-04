<#
Root Module including all the required modules
#>

# Check for admin privilege first before proceeding...
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Publish-Error "!!! Run this in Administrator mode !!!"
    return
}

#Set tool version
if (($host -ne $null) -and ($host.ui -ne $null) -and ($host.ui.RawUI -ne $null) -and ($host.ui.RawUI.WindowTitle -ne $null)) {
     $host.ui.RawUI.WindowTitle = "IoTCorePShell"
}
$toolsroot = [string] $PSScriptRoot
$Global:ToolsRoot = $toolsroot.Replace("\Tools\IoTCoreImaging", "")
$Global:OrigPath = $env:Path
Write-Debug "Orig Path : $($Global:OrigPath)"

# dot source all the classes here. The order is important to ensure the dependency 

. $PSScriptRoot\Classes\IoTDeviceLayout.ps1
. $PSScriptRoot\Classes\IoTWMWriter.ps1
. $PSScriptRoot\Classes\IoTProvisioningXML.ps1
. $PSScriptRoot\Classes\IoTFMXML.ps1
. $PSScriptRoot\Classes\IoTOemInputXML.ps1
. $PSScriptRoot\Classes\IoTProductSettingsXML.ps1
. $PSScriptRoot\Classes\IoTProduct.ps1
. $PSScriptRoot\Classes\IoTWorkspaceXML.ps1
. $PSScriptRoot\Classes\IoTWMXML.ps1
. $PSScriptRoot\Classes\IoTFFU.ps1

# dot source all the powershell scripts for the functions 
. $PSScriptRoot\IoTBuildCommands.ps1
. $PSScriptRoot\IoTTestCommands.ps1
. $PSScriptRoot\IoTAddCommands.ps1
. $PSScriptRoot\IoTRecovery.ps1
. $PSScriptRoot\IoTSecurity.ps1
. $PSScriptRoot\IoTWorkspace.ps1
. $PSScriptRoot\IoTClassExports.ps1

############ IoTBuildCommands Exports ##############
New-Alias -Name 'buildfm' -Value 'New-IoTFIPPackage'
New-Alias -Name 'buildimage' -Value 'New-IoTFFUImage'
New-Alias -Name 'buildpkg' -Value 'New-IoTCabPackage'
New-Alias -Name 'buildppkg' -Value 'New-IoTProvisioningPackage'
New-Alias -Name 'convertpkg' -Value 'Convert-IoTPkg2Wm'
New-Alias -Name 'tfids' -Value 'Test-IoTFeatures'
New-Alias -Name 'tpkgs' -Value 'Test-IoTPackages'
New-Alias -Name 'importcfg' -Value 'Import-IoTDUCConfig'
New-Alias -Name 'exportpkgs' -Value 'Export-IoTDUCCab'
New-Alias -Name 'exportidm' -Value 'Export-IoTDeviceModel'
############ IoTAddCommands Exports ##############
New-Alias -Name 'newappxpkg' -Value 'Add-IoTAppxPackage'
New-Alias -Name 'newbsp' -Value 'Add-IoTBSP'
New-Alias -Name 'newcommonpkg' -Value 'Add-IoTCommonPackage'
New-Alias -Name 'newdrvpkg' -Value 'Add-IoTDriverPackage'
New-Alias -Name 'newprovpkg' -Value 'Add-IoTProvisioningPackage'
New-Alias -Name 'newproduct' -Value 'Add-IoTProduct'
############ IoTClassExports Exports ##############
New-Alias -Name 'gpfidpkgs' -Value 'Get-IoTProductPackagesForFeature'
New-Alias -Name 'gpfids' -Value 'Get-IoTProductFeatureIDs'

New-Alias -Name 'ffud' -Value 'Dismount-IoTFFUImage'
New-Alias -Name 'ffue' -Value 'Export-IoTFFUAsWims'
New-Alias -Name 'ffugd' -Value 'Get-IoTFFUDrives'
New-Alias -Name 'ffum' -Value 'Mount-IoTFFUImage'
New-Alias -Name 'ffus' -Value 'New-IoTFFUCIPolicy'
New-Alias -Name 'addfid' -Value 'Add-IoTProductFeature'
New-Alias -Name 'removefid' -Value 'Remove-IoTProductFeature'
############ IoTRecovery Exports ##############
New-Alias -Name 'buildrecovery' -Value 'New-IoTRecoveryImage'
New-Alias -Name 'createwinpe' -Value 'New-IoTWindowsImage'
New-Alias -Name 'verifyrecovery' -Value 'Test-IoTRecoveryImage'
############ IoTTestCommands Exports ##############
New-Alias -Name 'checkcab' -Value 'Test-IoTCabSignature'
New-Alias -Name 'checksign' -Value 'Test-IoTSignature'
New-Alias -Name 'signbinaries' -Value 'Add-IoTSignature'
New-Alias -Name 're-signcabs' -Value 'Redo-IoTCabSignature' 
############ IoTWorkspace Exports ##############
New-Alias -Name 'new-ws' -Value 'New-IoTWorkspace'
New-Alias -Name 'open-ws' -Value 'Open-IoTWorkspace'
New-Alias -Name 'importpkg' -Value 'Import-IoTOEMPackage'
New-Alias -Name 'importproduct' -Value 'Import-IoTProduct'
New-Alias -Name 'importbsp' -Value 'Import-IoTBSP'
New-Alias -Name 'copypkg' -Value 'Copy-IoTOEMPackage'
New-Alias -Name 'copyproduct' -Value 'Copy-IoTProduct'
New-Alias -Name 'copybsp' -Value 'Copy-IoTBSP'
New-Alias -Name 'migrate' -Value 'Redo-IoTWorkspace'
New-Alias -Name 'setversion' -Value 'Set-IoTCabVersion'
New-Alias -Name 'setenv' -Value 'Set-IoTEnvironment'
New-Alias -Name 'addenv' -Value 'Add-IoTEnvironment'
New-Alias -Name 'setsignature' -Value 'Set-IoTSignature'
New-Alias -Name 'retailsign' -Value 'Set-IoTRetailSign'
New-Alias -Name 'gwsproducts' -Value 'Get-IoTWorkspaceProducts'
New-Alias -Name 'gwsbsps' -Value 'Get-IoTWorkspaceBSPs'
