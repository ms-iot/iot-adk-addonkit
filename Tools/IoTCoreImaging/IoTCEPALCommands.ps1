<#
Commands for working with CEPAL
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

function Import-IoTCEPAL {
    <#
    .SYNOPSIS
    Import a flat release directory and prepare for packaging into IoT Core

    .DESCRIPTION
    This command copies $FlatReleaseDirectory\CEPAL_PKG into the workspace and generates CEPALFMFileList.xml.

    .PARAMETER FlatReleaseDirectory
    The flat release directory where to source CEPAL.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [String]$FlatReleaseDirectory
    )

    $destinationDir = "$env:SRC_DIR\CEPAL"

    if (Test-Path $destinationDir -PathType Container) {
        Write-Verbose "Moving existing $destinationDir to $destinationDir.OLD"
        if (Test-Path "$destinationDir.OLD" -PathType Container) {
            Remove-Item "$destinationDir.OLD" -Recurse -Force
        }
        Rename-Item -Path $destinationDir -NewName "$destinationDir.OLD" -Force
    }

    # mkdir $destinationDir
    New-Item -ItemType Directory -Path $destinationDir | Out-Null

    $cepalPkgDir = "$FlatReleaseDirectory\CEPAL_PKG"

    Write-Verbose "Copying $cepalPkgDir to $destinationDir"

    # xcopy $cepalPkgDir $destinationDir /s
    Copy-Item "$cepalPkgDir\*" -Destination $destinationDir -Recurse

    # Create a FMList.xml for CEPAL
    $fmxml = New-IoTFMXML "$destinationDir\CEPALFM.xml"

    $arch = $env:ARCH
    if ($arch -ieq "x64") { $arch = "amd64" }

    $fmxml.CreateFMList(@("CEPAL"), $arch)
}

function Add-IoTCEPAL {
    <#
    .SYNOPSIS
    Chain CEPALFM.xml into the IoT Core packaging process for a specific product

    .DESCRIPTION
    Adds CEPALFM.xml into the Test and Retail OEMInput.xml files for product $Product.
    
    .PARAMETER Product
    A Name that uniquely identifies a product.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$Product
    )

    $productPath = "$env:SRC_DIR\Products\$Product"

    $testOemFile = New-IoTOemInputXml $productPath\TestOEMInput.xml
    $testOemFile.AddAdditionalFM("%BLD_DIR%\MergedFMs\CEPALFM.xml")

    $retailOemFile = New-IoTOemInputXml $productPath\RetailOEMInput.xml
    $retailOEMFile.AddAdditionalFM("%BLD_DIR%\MergedFMs\CEPALFM.xml")
}
