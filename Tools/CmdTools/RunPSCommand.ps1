<#
Module to invoke powershell commands from the command line.
#>

$SupportedCommands = @( 
    'New-IoTFIPPackage'
    'New-IoTFFUImage' 
    'New-IoTCabPackage' 
    'New-IoTProvisioningPackage' 
    'Test-IoTFeatures' 
    'Test-IoTPackages'
    'Import-IoTDUCConfig'
    'Export-IoTDUCCab'
    'Export-IoTDeviceModel'
    'Convert-IoTPkg2Wm'
    'Add-IoTAppxPackage'
    'Add-IoTBSP'
    'Add-IoTCommonPackage'
    'Add-IoTDriverPackage'
    'Add-IoTProvisioningPackage'
    'Add-IoTProduct'
    'Dismount-IoTFFUImage'
    'Export-IoTFFUAsWims' 
    'Get-IoTFFUDrives' 
    'Mount-IoTFFUImage' 
    'New-IoTFFUCIPolicy'
    'New-IoTRecoveryImage'
    'New-IoTWindowsImage'
    'Test-IoTCabSignature'
    'Test-IoTSignature'
    'Add-IoTSignature'
    'Redo-IoTCabSignature'
    'New-IoTWorkspace'
    'Open-IoTWorkspace' 
    'Import-IoTOEMPackage' 
    'Import-IoTProduct'
    'Import-IoTBSP'
    'Copy-IoTOEMPackage' 
    'Copy-IoTProduct'
    'Copy-IoTBSP'    
    'Redo-IoTWorkspace'
    'Set-IoTCabVersion'
    'Set-IoTEnvironment'
    'Add-IoTEnvironment'
    'Set-IoTSignature'
    'Set-IoTRetailSign'
    'Get-IoTProductFeatureIDs'
    'Get-IoTProductPackagesForFeature'
    'Import-IntelBSP'
    'Import-QCBSP'
    'Get-IoTWorkspaceProducts'
    'Get-IoTWorkspaceBSPs'
)
if ([string]::IsNullOrWhiteSpace($args[0])) { 
    Write-Host "Error - No Command specified" -ForegroundColor Red
    Write-Host "---------------------------"
    Write-Host "Supported Commands are "
    $SupportedCommands -join "`n"
    return
}

Write-Verbose "Loading IoTCoreImaging module.."
$IoTModuleRoot = "$PSScriptRoot\..\"
$IoTModuleRoot = Resolve-Path -Path $IoTModuleRoot
$env:PSModulePath = "$IoTModuleRoot;$env:PSModulePath"
Import-Module IoTCoreImaging.psd1 -Force
#$Commands = (Get-Module IoTCoreImaging).ExportedFunctions.Keys

if ($SupportedCommands.Contains($args[0])) {
    Write-Verbose "Processing $args"
    $command = $args -join " "
    Invoke-Expression -Command $command
    if ($?) { 
        Write-Verbose "$($args[0]) successful" 
    }
    else {
        Publish-Error "$($args[0]) failed"
    }
}
else { 
    Publish-Error "$($args[0]) is not supported" 
    Publish-Status "---------------------------"
    Publish-Status "Supported Commands are "
    $SupportedCommands -join "`n"
}
