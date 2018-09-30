<#
This hook is invoked from Add-IoTProduct in IoTNewCommands.psm1
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
$smbioscfg = "$ProductDir\SMBIOS.cfg"
$prodname = Split-Path $ProductDir -Leaf
$settingsxml = [xml] (Get-Content "$ProductDir\$($prodname)Settings.xml")
$smbios = $settingsxml.IoTProductSettings.SMBIOS

(Get-Content $env:BSPSRC_DIR\QCDB410C\OEMInputSamples\SMBIOS.cfg) -replace '{Product}', $smbios.ProductName -replace '{OEMNAME}', $smbios.Manufacturer -replace '{SKU}', $smbios.SKUNumber -replace '{Family}', $smbios.Family -replace '{BbProd}', $smbios.BaseboardProduct | Out-File $smbioscfg -Encoding utf8
