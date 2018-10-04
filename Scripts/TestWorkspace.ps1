param([string] $workspacedir)

if([string]::IsNullOrWhiteSpace($workspacedir)) { $workspacedir ="$env:USERPROFILE\TestWkspace" }
if (Test-Path $workspacedir) {
    Remove-Item -Path $workspacedir -Recurse -Force | Out-Null
}
Write-Host "Creating workspace at $workspacedir"
new-ws $workspacedir Contoso arm

# import packages from the sample workspace (same as the tools dir path currently)
importpkg *
importbsp RPi2
importproduct RPiRecovery

# Import required certificates
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-PK.cer PlatformKey
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-UEFISB.cer KeyExchangeKey
# DataRecoveryAgent mandatory for Bitlocker
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-DRA.cer DataRecoveryAgent
# Update mandatory for Device Guard
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-PAUTH.cer Update
Import-IoTCertificate $env:SAMPLEWKS\Certs\OEM-UMCI.cer User
Add-IoTSecurityPackages -Test
# generate the retail versions (excluding Test certs)
Add-IoTSecureBoot
Add-IoTDeviceGuard

$product = "RPiRecovery"
$config = "Test"

#Cleanup all build directories
$result = buildpkg Clean
#build all packages
$result = buildpkg all
if (!$result) { 
    Publish-Error "New-IoTCabPackage failed"
    return
}
#check feature ids
$gfids = gpfids
if ($gfids.Count -eq 0) { 
    Publish-Error "Get-IoTProductFeatureIDs failed"
    return
}

buildimage $product $config

createwinpe $product $config

buildrecovery $product $config

verifyrecovery $product $config

$prod = New-IoTProduct $product $config
$ffufile = $prod.FFUName
Mount-IoTFFUImage $ffufile
New-IoTFFUCIPolicy
Dismount-IoTFFUImage
