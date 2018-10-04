<#
Script to update the version number of the module
#>

$RootDir = "$PSScriptRoot\..\"
$RootDir = Resolve-Path -Path $RootDir
$bldtime = Get-Date -Format "yyMMdd-HHmm"
$frags = $bldtime.Split("-")
$ModuleVer = "6.0.$($frags[0]).$($frags[1])"
Write-Host "Setting version to $ModuleVer"
# Update the Module version 
Update-ModuleManifest -Path "$RootDir\Tools\IoTCoreImaging\IoTCoreImaging.psd1" -ModuleVersion "$ModuleVer"
