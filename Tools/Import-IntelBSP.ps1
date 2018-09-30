<#
    .SYNOPSIS
    Function to import Intel BSP into your workspace and update the bsp files as required by the latest tools
    
    .DESCRIPTION
    Function to import Intel BSP into your workspace and update the bsp files as required by the latest tools
    
    .PARAMETER BSPName
    Mandatory parameter, name of the BSP to be imported
    
    .EXAMPLE
    Import-IntelBSP CHTx64
    
    .NOTES
    You will need to install the Intel BSP in your machine first before using this method. 
    #>
[CmdletBinding()]
Param
(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [String]$BSPName
)

if ($env:ARCH -ieq "arm") {
    Publish-Error "Incorrect architecture. setenv x86 or x64"
    return
}

$inteldir = "${env:ProgramFiles(x86)}\Intel IoT\Source-$($env:ARCH)\BSP"

$intelbsps = (Get-ChildItem -Path $inteldir -Directory)| ForEach-Object {$_.BaseName}
if (!$intelbsps) {
    Publish-Error  "No Intel BSPs installed."
    return
}

if ([string]::IsNullOrWhiteSpace($BSPName) -or ($intelbsps -notcontains $BSPName)) { 
    Publish-Error  "Specify a valid BSP Name"
    Publish-Status "Installed BSPs are  $($intelbsps -join ",")"
    return
}

$bspsrcdir = "$inteldir\$BSPName"
$bspdstdir = "$env:BSPSRC_DIR\$BSPName"
Publish-Status "Copying the BSP from Intel IoT dir..."
Copy-Item $bspsrcdir $env:BSPSRC_DIR\ -Recurse -Force
Publish-Status "Copy completed."
# Process all the inf files 
$inffiles = (Get-ChildItem -Path $bspdstdir -Filter *.inf -Recurse)| ForEach-Object {$_.FullName}
foreach ($inffile in $inffiles) {
    $inf = Split-Path -Path $inffile -Leaf
    $infdir = Split-Path -Path $inffile -Parent
    $infcompname = Split-Path -Path $infdir -Leaf
    $infnames = $infcompname.Split(".")
    Publish-Status "Processing $inf to create $infcompname.wm.xml"
    try {
        $wmwriter = New-IoTWMWriter $infdir $infnames[0] $infnames[1]
        $wmwriter.Start("Intel", "MainOS")
        $wmwriter.AddDriver($inf)
        $wmwriter.Finish()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
    Remove-ItemIfExist "$infdir\$infcompname.pkg.xml"
}
Publish-Status "Converting pkg.xml files"
$result = Convert-IoTPkg2Wm $bspdstdir

$bspname2 = $BSPName.Replace("x", "")
Publish-Status "Using shortname $bspname2"
Publish-Status "Updating the FM and OEMInput xml files"
(Get-Content $bspdstdir\Packages\$($BSPName)FM.XML) -replace "Intel.$bspname2.OEM", "%OEM_NAME%.$bspname2.OEM" -replace "Intel.$bspname2.Device", "%OEM_NAME%.$bspname2.Device" -replace "FeatureIdentifierPackage=`"true`"", "" | Out-File $bspdstdir\Packages\$($BSPName)FM.xml -Encoding utf8
(Get-Content $bspdstdir\OEMInputSamples\TestOEMInput.xml) -replace "%BSPSRC_DIR%\\$($BSPName)\\Packages", "%BLD_DIR%\MergedFMs" | Out-File $bspdstdir\OEMInputSamples\TestOEMInput.xml -Encoding utf8
(Get-Content $bspdstdir\OEMInputSamples\RetailOEMInput.xml) -replace "%BSPSRC_DIR%\\$($BSPName)\\Packages", "%BLD_DIR%\MergedFMs" | Out-File $bspdstdir\OEMInputSamples\RetailOEMInput.xml -Encoding utf8

if ($result) {
    Publish-Success "Import completed."
}
