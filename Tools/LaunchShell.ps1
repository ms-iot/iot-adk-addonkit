param(
    [string] $IoTWsXML,
    [switch] $Force
)
if ([string]::IsNullOrWhiteSpace($IoTWsXML)) { 
    $IoTWsXML = "$PSScriptRoot\..\Workspace\IoTWorkspace.xml"
    $IoTWsXML = Resolve-Path -Path $IoTWsXML
}

# Load environment
if (($env:PSModulePath).Contains($PSScriptRoot)) {
    if ($Force) {
        Write-Host "Force loading IoTCoreImaging module" -ForegroundColor Cyan
        Import-Module IoTCoreImaging.psd1 -Force
    }
    else {
        Write-Host "IoTCoreImaging module already loaded" -ForegroundColor Cyan    
    }
}
else { 
    Write-Host "Loading IoTCoreImaging module.." -ForegroundColor Cyan
    $env:PSModulePath = "$PSScriptRoot;$env:PSModulePath"
    Import-Module IoTCoreImaging.psd1 -Force
}
Open-IoTWorkspace $IoTWsXML
