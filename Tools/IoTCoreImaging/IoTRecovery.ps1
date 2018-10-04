<#
This Module contains the recovery functionality related methods
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

function New-IoTWindowsImage {
    <#
    .SYNOPSIS
    Builds a WinPE image with relevant drivers and recovery files
    .DESCRIPTION
    This function copies the arch specific winpe.wim and adds bsp specific drivers and recovery files and stores them as a product specific winpe.wim file
    .OUTPUTS
    None, function doesnt return anything. Generates product specific wimpe.wim in the build New-IoTProduct.
    .EXAMPLE
    New-IoTWindowsImage ProductA Test
    .EXAMPLE
    New-IoTWindowsImage -product ProductA -config Test
    .LINK
    https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery
    #>
    [CmdletBinding()]
    param(
        [string]
        # Specify the product name
        $product,
        [string]
        # Specify the config to load ( retail/test )
        $config
    )

    $iotprod = $null
    try {
        $iotprod = New-IoTProduct $product $config
    }
    catch {
        Publish-Error $_.Exception.Message
        return $false
    }

    $bsp = $iotprod.BspName
    $bspdir = "$env:BSPSRC_DIR\$bsp"
    if (!(Test-Path $bspdir)) {
        Publish-Error "$bsp not found"
        return $false
    }
    $fmfile = "$bspdir\Packages\$bsp" + "FM.xml"
    if (!(Test-Path $fmfile)) {
        Publish-Error "$fmfile file not found"
        return $false
    }
    $ffudir = Split-Path -Path $iotprod.FFUName -Parent
    $winpefiles = "$ffudir\recovery"
    $winpeextdrv = "$bspdir\WinPEExt\Drivers"
    $winpeextfiles = "$bspdir\WinPEExt\recovery"
    $mountdir = "$ffudir\mount"

    # If directory exists, delete the files if present
    New-DirIfNotExist $winpefiles -force
    New-DirIfNotExist $mountdir

    Write-Debug "Get device layout and validate"
    # Get device layout object
    $devlayout = $iotprod.GetDeviceLayout()
    if ($devlayout -eq $null) {
        Publish-Error "GetDeviceLayout failed"
        return $false
    }
    if (!$devlayout.ValidateDeviceLayout()) {
        Publish-Error "Device Layout validation failed"
        return $false
    }
    $devlayout.ParseDeviceLayout()
    $devlayout.GenerateRecoveryScripts($winpefiles)

    # Copy the base winPE
    Publish-Status "Copying WinPE"
    $WinPE = "$env:WINPE_ROOT\$env:BSP_ARCH\en-us\winpe.wim"
    if (Test-Path $WinPE){
        Copy-Item $WinPE -Destination $ffudir
    }
    else {
        Publish-Error "WinPE Wim not found. Install ADK WinPE Addons"
        return $false
    }

    Publish-Status "Mounting WinPE"
    try {
        $result = Mount-WindowsImage -ImagePath $ffudir\winpe.wim -Index 1 -Path $mountdir
    }
    catch {
        Publish-Error "Mount-WindowsImage failed"
        return $false
    }

    # Check and add drivers
    if (Test-Path $winpeextdrv ) {
        $inffiles = (Get-ChildItem -Path $winpeextdrv -Filter "*.inf" -Recurse) | foreach-object {$_.FullName}
        if ($inffiles -ine $null) {
            Publish-Status "Adding drivers"
            $name = Split-Path $inf -Leaf
            foreach ($inf in $inffiles) {
                Write-Verbose "  Adding $name"
                dism /image:$mountdir /add-driver /driver:$inf
            }
        }
        else { Write-Verbose "No drivers found" }
    }
    else { Publish-Status "Driver folder not present. No drivers added" }

    # Copy required files into winpe mount dir
    Publish-Status "Copying files into WinPE"
    Copy-Item "$env:TEMPLATES_DIR\recovery\*" -Destination "$mountdir\windows\system32\"
    Copy-Item "$winpefiles\*" -Destination "$mountdir\windows\system32\"
    if (Test-Path $winpeextfiles) {
        Copy-Item "$winpeextfiles\*" -Destination "$mountdir\windows\system32\"
    }

    Publish-Status "Saving and unmounting WinPE"
    $result = Dismount-WindowsImage -Path $mountdir -Save
    Remove-Item $mountdir -Recurse
    Publish-Success "WinPE is available at $ffudir"
    return $true
}

function New-IoTRecoveryImage {
    <#
    .SYNOPSIS
    Creates recovery ffu from a regular ffu
    .DESCRIPTION
    This function mounts the regular ffu, extracts the required wim files and populates the MMOS (recovery )`
    partition with the required files and saves the resultant ffu as Flash_Recovery.ffu
    .OUTPUTS
    None, function doesnt return anything. Generates the wim files and ffu file.
    .EXAMPLE
    New-IoTRecoveryImage ProductA Test
    .EXAMPLE
    New-IoTRecoveryImage ProductA Test Import C:\wimfiles
    .EXAMPLE
    New-IoTRecoveryImage -product ProductA -config Test -wimmode Import -wimdir C:\wimfiles
    .LINK
    https://docs.microsoft.com/windows-hardware/service/iot/recovery-mechanism
    #>
    [CmdletBinding()]
    param(
        # Product name
        [string] $product,
        # Config to load ( retail/test )
        [string] $config,
        # Optional, the mode Import/Export 
        [string] $wimmode,
        # The directory for the wim files. Mandatory when wimmode is specified. 
        [string] $wimdir
    )

    $iotprod = $null
    $ffufile = $null
    try {
        $iotprod = New-IoTProduct $product $config
        $ffufile = $iotprod.FFUName
        if (!(Test-Path $ffufile)) {
            Publish-Error "$ffufile not found"
            return
        }
    }
    catch {
        Publish-Error $_.Exception.Message
        return
    }

    $ffudir = Split-Path -Path $ffufile -Parent

    # If not exist winpe, create winpe
    $winpewim = "$ffudir\winpe.wim"
    if (!(Test-Path $winpewim)) { 
        $retval = New-IoTWindowsImage $product $config 
        if (!$retval) {
            Publish-Error "WinPE creation failed."
            return
        }
    }

    # Mount the ffu
    $retval = Mount-IoTFFUImage $ffufile
    $DriveLetters = Get-IoTFFUDrives

    # Extract wims
    $mmosdir = $DriveLetters.MMOS
    Publish-Status "MMOS Drive: $mmosdir"

    # Copy contents to MMOS
    if ($wimmode -ieq "Import") {
        if (Test-Path $wimdir) { 
            Publish-Status "Copying wim files from $wimdir"
            Copy-Item "$wimdir\efiesp.wim" -Destination $mmosdir
            Copy-Item "$wimdir\mainos.wim" -Destination $mmosdir
            Copy-Item "$wimdir\data.wim" -Destination $mmosdir
            Copy-Item "$wimdir\RecoveryImageVersion.txt" -Destination $mmosdir
        }
        else { Publish-Error "$wimdir not found." }
    }
    else {
        $retval = Export-IoTFFUAsWims
        # Write the version info to a file
        Set-Content -Path "$ffudir\RecoveryImageVersion.txt" -Value "$env:BSP_VERSION"

        # Copy the files to the MMOS partition
        Publish-Status "Copying wim files from $ffudir"
        Set-Location $ffudir
        Copy-Item .\efiesp.wim -Destination $mmosdir
        Copy-Item .\mainos.wim -Destination $mmosdir
        Copy-Item .\data.wim -Destination $mmosdir
        Copy-Item .\RecoveryImageVersion.txt -Destination $mmosdir
        if ($wimmode -ieq "Export") {
            Publish-Status "Exporting wim files to $wimdir"
            New-DirIfNotExist $wimdir
            Copy-Item .\efiesp.wim -Destination $wimdir
            Copy-Item .\mainos.wim -Destination $wimdir
            Copy-Item .\data.wim -Destination $wimdir
            Copy-Item .\RecoveryImageVersion.txt -Destination $wimdir
        }
    }

    # Copy WinPE wim
    Copy-Item "$winpewim" -Destination $mmosdir
    Copy-Item "$env:TEMPLATES_DIR\startrecovery.cmd" -Destination $mmosdir

    #TODO: Add plugin support

    # Dismount and save as Recovery FFU
    $retval = Dismount-IoTFFUImage "Flash_Recovery.ffu"
    Set-Location $env:IOTWKSPACE
    Publish-Success "Recovery FFU is available at $ffudir\Flash_Recovery.ffu"
}

function Test-IoTRecoveryImage {
    <#
    .SYNOPSIS
    Validates if the recovery wim files are proper in the recovery ffu
    .DESCRIPTION
    This function mounts the recovery ffu, uses the wim files in the recovery partition and performs the recovery process on the mounted partitions to validate if the wim files are proper.
    .OUTPUTS
    Returns an boolean value
    .EXAMPLE
    Test-IoTRecoveryImage ProductA Test
    .EXAMPLE
    Test-IoTRecoveryImage ProductA Test 
    .EXAMPLE
    Test-IoTRecoveryImage -product ProductA -config Test 
    .LINK
    https://docs.microsoft.com/windows/iot-core/build-your-image/addrecovery
    #>
    [CmdletBinding()]
    param(
        # Product name
        [string] $product,
        # Config to load ( retail/test )
        [string] $config
    )

    $iotprod = $null
    try {
        $iotprod = New-IoTProduct $product $config
    }
    catch {
        Publish-Error $_.Exception.Message
        return
    }
    $ffufile = $iotprod.FFUName
    $ffudir = Split-Path -Path $ffufile -Parent
    $recoveryffu = "$ffudir\Flash_Recovery.ffu" 
    if (!(Test-Path $recoveryffu)) {
        Publish-Error "$recoveryffu not found"
        return
    }

    # Mount the ffu
    $retval = Mount-IoTFFUImage $recoveryffu
    $DriveLetters = Get-IoTFFUDrives

    # Extract wims from the MMOS partition
    $mmosdir = $DriveLetters.MMOS
    Publish-Status "MMOS Drive: $mmosdir"
    $extractdir = "$ffudir\extract"
    New-DirIfNotExist $extractdir -force

    Publish-Status "Copying wim files from $wimdir"
    Copy-Item "$mmosdir\efiesp.wim" -Destination $extractdir
    Copy-Item "$mmosdir\mainos.wim" -Destination $extractdir
    Copy-Item "$mmosdir\data.wim" -Destination $extractdir
    Copy-Item "$mmosdir\RecoveryImageVersion.txt" -Destination $extractdir

    Publish-Status "Applying $extractdir\efiesp.wim to $($DriveLetters.EFIESP)"
    Expand-WindowsImage -ImagePath "$extractdir\efiesp.wim" -ApplyPath $DriveLetters.EFIESP -Index 1
    if ($?) {
        Publish-Success "EFIESP.wim Verification Success"
    }
    else { Publish-Error "EFIESP.wim Verification failed" }

    Publish-Status "Applying $extractdir\mainos.wim to $($DriveLetters.MainOS)"
    Expand-WindowsImage -ImagePath "$extractdir\mainos.wim" -ApplyPath $DriveLetters.MainOS -Index 1
    if ($?) {
        Publish-Success "MainOS.wim Verification Success"
    }
    else { Publish-Error "MainOS.wim Verification failed" }

    Publish-Status "Applying $extractdir\data.wim to $($DriveLetters.Data)"
    Expand-WindowsImage -ImagePath "$extractdir\data.wim" -ApplyPath $DriveLetters.Data -Index 1
    if ($?) {
        Publish-Success "Data.wim Verification Success"
    }
    else { Publish-Error "Data.wim Verification failed" }

    # Dismount and save as Recovery FFU
    $retval = Dismount-IoTFFUImage
    Set-Location $env:IOTWKSPACE
}
