<#
This hook is invoked from New-FFUImage in IoTBuildCommands.psm1
#>
param(
    [string] $ProductDir,
    [string] $BSP
)

#Assert that you are building QCDB410c based image
if ($BSP -ine "QCDB410C") {
    Publish-Error "Incorrect BSP Hook invoked. Expected QCDB410C, called with $BSP"
    return
}
$productname = Split-Path -Path $ProductDir -Leaf
$smbioscfg = "$ProductDir\SMBIOS.cfg"
if (Test-Path $smbioscfg) {
    Publish-Status "Using custom SMBIOS settings"
    Copy-Item "$env:BSPSRC_DIR\QCDB410C\tools\Custom.SMBIOS.xml" "$env:PKGBLD_DIR\Custom.SMBIOS.wm.xml" -Force | Out-Null
    
    New-IoTCabPackage $env:PKGBLD_DIR\Custom.SMBIOS.wm.xml $productname
} 
else {
    Publish-Warning "Using default SMBIOS settings"
}
