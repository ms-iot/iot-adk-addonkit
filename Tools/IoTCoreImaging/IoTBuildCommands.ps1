﻿<#
Build Commands definition
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

function New-IoTCabPackage {
    <#
    .SYNOPSIS
    Creates a Cab package file for the specified wm.xml file or the wm.xml files in the specified directory.

    .DESCRIPTION
    This command runs the pkggen.exe with the appropriate parameters to generate a .cab file from the given wm.xml file,  or the wm.xml files present in the directory. It also supports special keywords to build all packages in the workspace(All) and to delete all previously built packages (Clean)

    .PARAMETER PkgFile
    Accepts the following inputs
    - All     : Special keyword, builds all packages in CommonDir and Source-arch dirs
    - Clean   : Special keyword, deletes all cab files from the build directory
    - .wm.xml : Fully qualified file path for the .wm.xml file (even outside the workspace)
    - pkgname : Directory name that is present under CommonDir or Source-arch dir within the workspace
    - fulldir : Fully qualified directory path (even outside the workspace)

    .PARAMETER Product
    Optional parameter specifying the product directory to be used for fetching product specific contents.

    .INPUTS
    None

    .OUTPUTS
    System.Boolean
    Returns $true if the cab file is successfully created.

    .EXAMPLE
    $result = New-IoTCabPackage All
    Builds all packages.

    .EXAMPLE
    $result = New-IoTCabPackage Clean
    Cleans up the build directory and deletes all .cab files.

    .EXAMPLE
    $result = New-IoTCabPackage C:\Sample\abc.wm.xml
    Builds abc.wm.xml file.

    .EXAMPLE
    $result = New-IoTCabPackage Registry.Version
    Builds wm.xml files in the directory Registry.Version

    .EXAMPLE
    $result = New-IoTCabPackage C:\Sample
    Builds wm.xml files in the directory C:\Sample

    .EXAMPLE
    $result = New-IoTCabPackage C:\Sample SampleA
    Builds wm.xml files in the directory COMMON_DIR\ProdPackages with the Product parameter SampleA.

    .LINK
    [New-IoTProvisioningPackage](New-IoTProvisioningPackage.md)

    .LINK
    [New-IoTFFUImage](New-IoTFFUImage.md)

    .NOTES
    The generated cab files are available in build directory $env:PKGBLD_DIR
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$PkgFile,

        [Parameter(Position = 1, Mandatory = $false)]
        [String] $Product = $null
    )
    New-DirIfNotExist $env:PKGLOG_DIR
    if ([string]::IsNullOrWhiteSpace($Product)) {
        $Product = "Default"
    }
    $filestoprocess = @()
    # Process special keywords first
    if ($PkgFile -ieq "All") {
        # Process All keyword - Get all wm.xml files in three directories PKGSRC_DIR,BSPSRC_DIR, COMMON_DIR, and the CEPAL dir
        $filename = Get-ChildItem -Path "$env:COMMON_DIR\Packages", $env:PKGSRC_DIR, $env:BSPSRC_DIR, "$env:SRC_DIR\CEPAL" -File -Filter *.wm.xml -Recurse | Foreach-Object { $_.FullName }
        if (!$filename) {
            Publish-Error "No .wm.xml files found in the workspace."
            return $false
        }
        $filestoprocess += $filename
    }
    elseif ($PkgFile -ieq "Clean") {
        # Process Clean keyword - Delete all generated cab files.
        if (Test-Path -Path "$env:BLD_DIR\ppkgs") {
            Remove-Item -Path "$env:BLD_DIR\ppkgs" -Recurse | Out-Null
        }
        if (Test-Path -Path "$env:PKGBLD_DIR") {
            Remove-Item -Path "$env:PKGBLD_DIR" -Recurse | Out-Null
            Publish-Success "Package build directory cleaned."
        }
        else { Publish-Warning "Nothing to clean." }
        return $true
    }
    elseif (Test-Path $PkgFile -PathType Leaf) {
        #the input is a file. Check if its wm.xml file and proceed
        if (!($PkgFile.Contains(".wm.xml"))) {
            Publish-Error "Only .wm.xml files supported."
            return $false
        }
        $filestoprocess += $PkgFile
    }
    elseif (Test-Path $PkgFile -PathType Container) {
        # input is a fully qualified directory - Get all wm.xml files in the directory
        $filename = Get-ChildItem -Path $PkgFile -File -Filter *.wm.xml -Recurse | Foreach-Object { $_.FullName }
        if (!$filename) {
            Publish-Error "No .wm.xml files found in $PkgFile."
            return $false
        }
        $filestoprocess += $filename
    }
    else {
        # input is not a fully qualified directory. Check for the directory in the workspace
        $filedir = Get-ChildItem -Path $env:SRC_DIR, $env:COMMON_DIR -Directory -Filter $PkgFile -Recurse | Foreach-Object { $_.FullName }
        if (!$filedir) {
            Publish-Error "$PkgFile not found in the workspace."
            return $false
        }
        $filename = Get-ChildItem -Path $filedir -File -Filter *.wm.xml -Recurse | Foreach-Object { $_.FullName }
        if (!$filename) {
            Publish-Error "No wm xml files found in $filedir"
            return $false
        }
        $filestoprocess += $filename
    }

    # If we got here we have a valid filename array or filename
    $bldtime = Get-Date -Format "yyyyMMdd-HHmm"
    $pkgvar = "_RELEASEDIR=.\;PROD=$Product;PRJDIR=$env:SRC_DIR;COMDIR=$env:COMMON_DIR;BSPVER=$env:BSP_VERSION;BSPARCH=$env:BSP_ARCH;OEMNAME=$env:OEM_NAME;BUILDTIME=$bldtime;BLDDIR=$env:BLD_DIR"
    $retval = $true
    try {
        foreach ($file in $filestoprocess) {
            $filedir = Split-Path -Path $file -Parent
            $name = Split-Path -Path $file -Leaf
            Publish-Status "Processing $name"
            $name = $name.Replace(".wm.xml", "") # get rid of the .wm.xml
            Set-Location $filedir

            # If customizations.xml file exists, build the provpackage
            if (Test-Path -Path $filedir\customizations.xml) {
                $ppkgname = "$env:BLD_DIR\ppkgs\$name" + ".ppkg"
                $retval = New-IoTProvisioningPackage $filedir\customizations.xml $ppkgname
            }
            if ($retval) {
                if ($VerbosePreference -ieq "Continue") {
                    pkggen "$file" /output:"$env:PKGBLD_DIR" /version:$env:BSP_VERSION /build:fre /cpu:$env:BSP_ARCH /variables:$pkgvar /onecore /universalbsp
                }
                else {
                    pkggen "$file" /output:"$env:PKGBLD_DIR" /version:$env:BSP_VERSION /build:fre /cpu:$env:BSP_ARCH /variables:$pkgvar /onecore /universalbsp | Out-File "$env:PKGLOG_DIR\$name.log" -Encoding utf8
                }
                if (!($?)) {
                    Publish-Error "$file pkggen failed"
                    $retval = $false
                }

            }
            if (!$retval) { break }
        }
    }
    finally {
        Set-Location $env:IOTWKSPACE
        Clear-Temp
    }
    return $retval
}

function Convert-IoTPkg2Wm {
    <#
    .SYNOPSIS
    Converts the existing pkg.xml files to wm.xml files.

    .DESCRIPTION
    Converts the existing pkg.xml files to wm.xml files with same name and at the same location and deletes the old pkg.xml files

    .PARAMETER Path
    Mandatory parameter specifying the path for the pkg.xml files

    .EXAMPLE
    $result = Convert-IoTPkg2Wm C:\MyDir

    .NOTES
    Since the pkg.xml files are deleted, recommend to take a backup before proceeding with this function.
    .LINK
    [New-IoTCabPackage](New-IoTCabPackage.md)
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )

    if (-not (Test-Path $Path -PathType Container) ) {
        Publish-Error "Invalid input. Please specify valid directory"
        return $false
    }
    # input is a fully qualified directory - Get all pkg.xml files in the directory
    $filestoprocess = Get-ChildItem -Path $Path -File -Filter *.pkg.xml -Recurse | Foreach-Object { $_.FullName }
    if (!$filestoprocess) {
        Publish-Status "No .pkg.xml files found in $Path."
        return $true
    }
    # If we got here we have a valid filename array or filename
    $bldtime = Get-Date -Format "yyyyMMdd-HHmm"
    $pkgvar = "_RELEASEDIR=.\;PROD=$Product;PRJDIR=$env:SRC_DIR;COMDIR=$env:COMMON_DIR;BSPVER=$env:BSP_VERSION;BSPARCH=$env:BSP_ARCH;OEMNAME=$env:OEM_NAME;BUILDTIME=$bldtime;BLDDIR=$env:BLD_DIR"
    $retval = $true
    foreach ($file in $filestoprocess) {
        $name = Split-Path -Path $file -Leaf
        Write-Verbose "Processing $name"
        $wmname = $file.Replace(".pkg.xml", ".wm.xml")
        if ($VerbosePreference -ieq "Continue") {
            pkggen "$file" /convert:pkg2wm /output:"$wmname" /useLegacyName:true /foroempkg:true /variables:$pkgvar
        }
        else {
            pkggen "$file" /convert:pkg2wm /output:"$wmname" /useLegacyName:true /foroempkg:true /variables:$pkgvar | Out-Null
        }
        if (!($?)) {
            Publish-Error "$file pkggen failed"
            $retval = $false
        }
        if (!$retval) { break }
        Remove-Item $file
    }
    Clear-Temp
    return $retval
}

function New-IoTProvisioningPackage {
    <#
    .SYNOPSIS
    Creates a .ppkg file from the customizations.xml input file. Returns a boolean indicating success or failure.

    .DESCRIPTION
    This command invokes icd.exe command line to process the provided settings.xml file and generates the ppkg.

    .PARAMETER File
    Input settings/customizations.xml file

    .PARAMETER Output
    Output file name, with full path. If path is not included, it creates the ppkg in the same dir as the input xml file.

    .INPUTS
    None

    .OUTPUTS
    System.Boolean
    True if the cab file is successfully created.

    .EXAMPLE
    $result = New-IoTProvisioningPackage C:\Sample\Customizations.xml C:\Build\Myfile.ppkg

    .NOTES
    Install ADK with Windows Customization Designer tool to use this functionality.

    .LINK
    [Add-IoTProvisioningPackage](Add-IoTProvisioningPackage.md)

    .LINK
    [Add a provisioning package to an image](https://docs.microsoft.com/windows-hardware/manufacture/iot/add-a-provisioning-package-to-an-image)

    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        # Provisioning settings file (customizations.xml)
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$File,
        #output file, with full path
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Output
    )
    $retval = $true

    if (!(Test-Path $File)) {
        Publish-Error "$File not found."
        return $false
    }
    $outfile = Split-Path -Path $Output -Leaf
    Write-Verbose "Creating $outfile"

    $storefile = "$env:KITSROOT\Assessment and Deployment Kit\Imaging and Configuration Designer\x86\Microsoft-IoTUAP-Provisioning.dat"
    $filedir = Split-Path -Path $File

    Push-Location $filedir
    if ($VerbosePreference -ieq "Continue") {
        cmd /r "icd /Build-ProvisioningPackage /CustomizationXML:$File /PackagePath:$Output /StoreFile:`"$storefile`" +Overwrite /Variables:`"BSPVER=$env:BSP_VERSION`""
    }
    else {
        cmd /r "icd /Build-ProvisioningPackage /CustomizationXML:$File /PackagePath:$Output /StoreFile:`"$storefile`" +Overwrite /Variables:`"BSPVER=$env:BSP_VERSION`"" | Out-Null
    }
    if (!($?)) {
        Publish-Error "$File ppkg failed"
        $retval = $false
    }
    else {
        # sign the cat file
        $file = $Output.Replace(".ppkg", ".cat")
        Write-Verbose "Signing $file"
        sign $file | Out-Null
    }

    Pop-Location
    Clear-Temp
    return $retval
}

function Invoke-FeatureMerger {
    <#
    .SYNOPSIS
    Wrapper around calling FeatureMerger.exe

    .DESCRIPTION
    This command invokes FeatureMerger.exe, optionally logs output to a file.
    
    .Parameter FMFileList
    The input FMFileList XML for FeatureMerger

    .Parameter LogFileName
    File to store FeatureMerger.exe log, if $VerbosePreference is set correctly
    #>

    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $FMFileList,

        [Parameter(Position = 1, Mandatory = $false)]
        [String] $LogFileName
    )

    if ($VerbosePreference -ieq "Continue") {
        FeatureMerger $FMFileList $env:PKGBLD_DIR $env:BSP_VERSION $env:BLD_DIR\MergedFMs /InputFMDir:$env:BLD_DIR\InputFMs /Languages:en-us /Resolutions:1024x768 /ConvertToCBS /variables:"_cputype=$env:BSP_ARCH;buildtype=fre;releasetype=production"
    }
    else {
        FeatureMerger $FMFileList $env:PKGBLD_DIR $env:BSP_VERSION $env:BLD_DIR\MergedFMs /InputFMDir:$env:BLD_DIR\InputFMs /Languages:en-us /Resolutions:1024x768 /ConvertToCBS /variables:"_cputype=$env:BSP_ARCH;buildtype=fre;releasetype=production" | Out-File $LogFileName -Encoding utf8
    }

    if (!($?)) {
        Publish-Error "FeatureMerger failed to process $FMListFile. See $LogFileName"
        return $false
    }

    return $true
}

function New-IoTFIPPackage {
    <#
    .SYNOPSIS
    Creates Feature Identifier Packages (FIP packages) for the given feature manifest files and updates the feature manifest files with the generated FIP packages. Returns boolean true for success and false for failure.

    .DESCRIPTION
    This command runs FeatureMerger.exe for the predefined FMList files in the workspace. It processes by default the OEMFMList  file present in the Source-arch\Packages\ directory. In addition, when the -IncludeOCP is specified it processes the OCPFMList present in the templates directory. When the BSP parameter is defined, it processess the bspfmlist present in the source-arm\bsp\packages directory.
    The updated FM files are stored in the build dir under MergedFM folder.

    .PARAMETER BSP
    Optional parameter to specify the bsp to be processed.

    .PARAMETER IncludeOCP
    Optional parameter to specify inclusion of OCPFMList processing

    .EXAMPLE
    $result = New-IoTFIPPackage QCDB410C -IncludeOCP
    Builds all three - OEM / BSP and OCP FM files.

    .EXAMPLE
    $result = New-IoTFIPPackage
    Builds only the OEM FM files.

    .NOTES
    All the packages referred in the FM files must be available before running this command. In general there is no need to execute this command stand alone as this is invoked in the New-IoTFFUImage cmdlet.
    .LINK
    [New-IoTFFUImage](New-IoTFFUImage.md)
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        # Provisioning settings file (customizations.xml)
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$BSP = $null,

        [Parameter(Mandatory = $false)]
        [Switch] $IncludeOCP
    )
    $retval = $true
    New-DirIfNotExist $env:BLD_DIR\InputFMs

    # Process the OEM FM files
    Publish-Status "Exporting OEM FM files.."
    (Get-Content -Path "$env:PKGSRC_DIR\OEMFM.xml") -replace "%PKGBLD_DIR%", $env:PKGBLD_DIR -replace "%OEM_NAME%", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\OEMFM.xml -Encoding utf8
    (Get-Content -Path "$env:COMMON_DIR\Packages\OEMCommonFM.xml") -replace "%PKGBLD_DIR%", $env:PKGBLD_DIR -replace "%OEM_NAME%", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\OEMCommonFM.xml -Encoding utf8
    (Get-Content -Path "$env:PKGSRC_DIR\OEMFMFileList.xml") -replace "OEM_NAME", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\OEMFMFileList.xml -Encoding utf8

    # Running feature merger for OEMFMList
    Publish-Status "Processing OEMFMList.."
    if (-Not (Invoke-FeatureMerger -FMFileList $env:BLD_DIR\InputFMs\OEMFMFileList.xml -LogFileName $env:BLD_DIR\FIPPackage_oem.log)) {
        $retval = $false
    }
    if ($IncludeOCP) {
        Publish-Status "Exporting OCP FM files.."
        (Get-Content -Path "$env:TEMPLATES_DIR\ocpupdate\OCPUpdateFM.xml") -replace "%PKGBLD_DIR%", $env:PKGBLD_DIR -replace "%OEM_NAME%", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\OCPUpdateFM.xml -Encoding utf8
        [string]$cputype = [string]($env:BSP_ARCH).ToUpper()
        (Get-Content -Path "$env:TEMPLATES_DIR\ocpupdate\OCPUpdateFMFileList.xml") -replace "OEM_NAME", $env:OEM_NAME -replace "CPU_TYPE", $cputype | Out-File $env:BLD_DIR\InputFMs\OCPUpdateFMFileList.xml -Encoding utf8
        Publish-Status "Processing OCPFMList"
        if (-Not (Invoke-FeatureMerger -FMFileList $env:BLD_DIR\InputFMs\OCPUpdateFMFileList.xml -LogFileName $env:BLD_DIR\FIPPackage_ocp.log)) {
            $retval = $false
        }
    }
    else { Write-Verbose "Skipping OCP FM files" }

    # Handle CEPAL
    if ((Test-Path "$env:SRC_DIR\CEPAL\CEPALFM.xml" -PathType Leaf) -And (Test-Path "$env:SRC_DIR\CEPAL\CEPALFMFileList.xml" -PathType Leaf)) {
        Publish-Status "Exporting CEPAL FM files.."
        (Get-Content -Path "$env:SRC_DIR\CEPAL\CEPALFM.xml") -replace "%PKGBLD_DIR%", $env:PKGBLD_DIR -replace "%OEM_NAME%", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\CEPALFM.xml -Encoding utf8
        (Get-Content -Path "$env:SRC_DIR\CEPAL\CEPALFMFileList.xml") -replace "OEM_NAME", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\CEPALFMFileList.xml -Encoding utf8

        Publish-Status "Processing CEPALFMList.."
        if (-Not (Invoke-FeatureMerger -FMFileList $env:BLD_DIR\InputFMs\CEPALFMFileList.xml -LogFileName $env:BLD_DIR\FIPPackage_cepal.log)) {
            $retval = $false
        }
    }

    # Cleanup the files here.
    Remove-Item -Path $env:PKGBLD_DIR\*.spkg
    Remove-Item -Path $env:PKGBLD_DIR\*.merged.txt
    Clear-Temp

    # Bail if no BSP
    if (!$BSP) {
        Write-Verbose "Skipping bspfm processing"
        return $retval
    }
    if (!(Test-path -Path $env:BSPSRC_DIR\$BSP -PathType Container)) {
        Publish-Error "$BSP not found"
        return $false
    }

    # Check for fm files in the bsp folder and if not found , bail out
    $fmfile = Get-ChildItem -Path $env:BSPSRC_DIR\$BSP\Packages\ -File -Filter *FM.xml -Recurse | Foreach-Object { $_.FullName }
    if ($null -eq $fmfile ) {
        Publish-Error "BSP fm files not found."
        return $false
    }

    Publish-Status "Exporting $BSP BSP FM files"
    $fmfiles = @($fmfile)
    foreach ($file in $fmfiles) {
        $filename = Split-Path -Path $file -Leaf
        (Get-Content -Path "$file") -replace "%PKGBLD_DIR%", $env:PKGBLD_DIR -replace "%OEM_NAME%", $env:OEM_NAME -replace "%BSPPKG_DIR%", $env:BSPPKG_DIR -replace "%MSPKG_DIR%", $env:MSPKG_DIR | Out-File $env:BLD_DIR\InputFMs\$filename -Encoding utf8
    }

    $bspfmlist = $BSP + "FMFileList.xml"

    if (!(Test-path -Path $env:BSPSRC_DIR\$BSP\Packages\$bspfmlist)) {
        Publish-Error "$BSP FMList not found"
        return $false
    }

    (Get-Content -Path "$env:BSPSRC_DIR\$BSP\Packages\$bspfmlist") -replace "OEM_NAME", $env:OEM_NAME | Out-File $env:BLD_DIR\InputFMs\$bspfmlist -Encoding utf8
    Publish-Status "Processing $bspfmlist"
    if (-Not (Invoke-FeatureMerger -FMFileList $env:BLD_DIR\InputFMs\$bspfmlist -LogFileName $env:BLD_DIR\FIPPackage_$BSP.log)) {
        $retval = $false
    }

    # Cleanup
    Remove-Item -Path $env:PKGBLD_DIR\*.spkg
    Remove-Item -Path $env:PKGBLD_DIR\*.merged.txt
    Clear-Temp
    return $retval
}

function New-IoTFFUImage {
    <#
    .SYNOPSIS
    Creates the IoT FFU image for the specified product / configuration. Returns boolean true for success and false for failure.

    .DESCRIPTION
    This command invokes Imageapp.exe to generate the Flash.ffu for the specified product/config oeminput xml file. Before invoking the ImageApp, this command processes various product specific packages and also invokes New-IoTFIPPackage to generate the FIP packages.

    .PARAMETER Product
    Mandatory parameter identifying the Product directory

    .PARAMETER Config
    Mandatory parameter identifying the config supported by the product. Defined in the product settings.xml. Together with Product parameter, this identifies the oeminputxml file to be processed.

    .PARAMETER Validate
    Optional switch parameter to validate the presence of the required packages for the image creation and also verify if all binaries and packages are properly signed.

    .EXAMPLE
    $result = New-IoTFFUImage SampleA Test

    .EXAMPLE
    $result = New-IoTFFUImage SampleA Retail -Validate

    .NOTES
    This command can take long time to complete in the order of few tens of minutes.

    .LINK
    [New-IoTRecoveryImage](New-IoTRecoveryImage.md)

    .LINK
    [Add-IoTProduct](Add-IoTProduct.md)
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config,
        # Validate packages option
        [Parameter(Position = 2, Mandatory = $false)]
        [Switch]$Validate
    )
    $retval = $true
    $iotprod = $null
    try {
        $iotprod = New-IoTProduct $Product $Config
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return $false
    }
    Write-IoTVersions
    # Check all feature ids are proper
    Publish-Status "Validating product feature ids"
    $retval = $iotprod.ValidateFeatures()
    if (!$retval) {
        Publish-Error "Feature validation failed."
        return $false
    }

    # Build product specific packages
    Publish-Status "Building product specific packages"
    $retval = New-IoTCabPackage Registry.Version
    $proddir = Split-Path -Path $iotprod.OemXML.FileName -Parent
    $ppkgname = "$env:BLD_DIR\ppkgs\$Product" + "Prov.ppkg"
    $retval = New-IoTProvisioningPackage $proddir\prov\customizations.xml $ppkgname
    if (!$retval) {
        Publish-Error "Failed to create product provisioning package"
        return $false
    }
    if (Test-Path "$env:COMMON_DIR\ProdPackages") {
        $retval = New-IoTCabPackage $env:COMMON_DIR\ProdPackages $Product
        if (!$retval) {
            Publish-Error "Failed to create common product packages"
            return $false
        }
    }

    if ((Test-Path $proddir\Packages) -and ($null -ne (Get-ChildItem $proddir\Packages))) {
        Publish-Status "Building product specific packages"
        $retval = New-IoTCabPackage $proddir\Packages
        if (!$retval) {
            Publish-Error "Failed to create product specific packages"
            return $false
        }
    }
    else { Write-Verbose "Product specific packages not found." }
    $hookfile = "$env:BSPSRC_DIR\$($iotprod.BspName)\tools\NewFFUImage-Hook.ps1"
    if (Test-Path $hookfile ) {
        #TODO check the impact of dot sourcing.
        . $hookfile $proddir $iotprod.BspName
    }

    # Validate if all the packages required are present and signed properly
    if ($Validate) {
        Publish-Status "Validating product packages"
        $retval = $iotprod.ValidatePackages()
        if (!$retval) {
            Publish-Error "Package validation failed."
            return $false
        }
    }

    Publish-Status "Building FM files.."
    #TODO : Optimize below better
    $result = $false
    if (Test-Path $proddir\Packages\CUSConfig) {
        $result = New-IoTFIPPackage $iotprod.BspName -IncludeOCP
    }
    else {
        $result = New-IoTFIPPackage $iotprod.BspName
    }

    if (!$result) {
        Publish-Error "Failed to create FIP packages"
        return $false
    }

    Publish-Status "Creating Image.."
    $outdir = Split-Path -Path $iotprod.FFUName -Parent
    New-DirIfNotExist $outdir


    if ($VerbosePreference -ieq "Continue") {
        ImageApp $iotprod.FFUName $iotprod.OemXML.FileName $env:MSPACKAGE /CPUType:$env:BSP_ARCH
    }
    else {
        Publish-Status "See $env:BLD_DIR\$($Product)_$Config.log for progress"
        Publish-Status "This will take a while..."
        ImageApp $iotprod.FFUName $iotprod.OemXML.FileName $env:MSPACKAGE /CPUType:$env:BSP_ARCH | Out-File $env:BLD_DIR\$($Product)_$Config.log -Encoding utf8
    }

    if ($?) {
        Publish-Success "Build Completed. See $outdir\Flash.ffu"
        $retval = $true
    }
    else {
        Publish-Error "Build failed"
        $retval = $false
    }

    DeviceNodeCleanup.x64
    Clear-Temp
    return $retval
}

function Test-IoTPackages {
    <#
    .SYNOPSIS
    Validates if all packages required for the specified product/config image creation are available and properly signed. This returns boolean true for success and false for failure.

    .DESCRIPTION
    This command parses all the FM files specified in the product/config oeminputxml file and identifies the packages required for the image creation. With the required package list, it checks the presence of the .cab file and validates the signature of the cab file and its contents.

    .PARAMETER Product
    Mandatory parameter identifying the Product directory

    .PARAMETER Config
    Mandatory parameter identifying the config supported by the product. Defined in the product settings.xml. Together with Product parameter, this identifies the oeminputxml file to be processed.

    .EXAMPLE
    $result = Test-IoTPackages SampleA Retail

    .NOTES
    This method is also invoked in the New-IoTFFUImage if -Validate switch is specified.

    .LINK
    [New-IoTFFUImage](New-IoTFFUImage.md)
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
    )
    try {
        $iotprod = New-IoTProduct $Product $Config
        $iotprod.ValidatePackages()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}

function Test-IoTFeatures {
    <#
    .SYNOPSIS
    Validates if all features specified in the specified product/config oeminputxml are defined. This returns boolean true for success and false for failure.

    .DESCRIPTION
    This command parses all the FM files specified in the product/config oeminputxml file and verifies if the feature ids specified in the oeminputfile are defined. This also warns if developer feature ids or test feature ids used in a retail oeminputxml file.

    .PARAMETER Product
    Mandatory parameter identifying the Product directory

    .PARAMETER Config
    Mandatory parameter identifying the config supported by the product. Defined in the product settings.xml. Together with Product parameter, this identifies the oeminputxml file to be processed.

    .EXAMPLE
    $result = Test-IoTFeatures SampleA Retail

    .NOTES
    This method is also invoked in the New-IoTFFUImage always.

    .LINK
    [New-IoTFFUImage](New-IoTFFUImage.md)
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
    )
    try {
        $iotprod = New-IoTProduct $Product $Config
        $iotprod.ValidateFeatures()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}

function Import-IoTDUCConfig {
    <#
    .SYNOPSIS
    Imports the Device Update Center Configuration files into the product directory

    .DESCRIPTION
    Imports the Device Update Center Configuration files into the product directory. This also updates all the oeminputfiles with inclusion of the OCPUpdateFM.xml and CUS_DEVICE_INFO feature and removes IOT_GENERIC_POP feature.

    .PARAMETER Product
    Mandatory parameter identifying the Product directory

    .PARAMETER ZipFile
    Mandatory parameter, the path of the CusConfig.zip file downloaded from the Device Update Center

    .EXAMPLE
    Import-IoTDUCConfig SampleA "C:\Users\myacc\Downloads\CUSConfig.zip"

    .NOTES
    See also Export-IoTDUCCab
    .LINK
    [Device Update Center User Guide](https://aka.ms/deviceupdatecenter)
    .LINK
    [Export-IoTDUCCab](Export-IoTDUCCab.md)
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ZipFile
    )
    try {
        $iotprod = New-IoTProduct $Product "Test"
        $iotprod.ImportDUCConfig($ZipFile)
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}

function Export-IoTDUCCab {
    <#
    .SYNOPSIS
    Exports the update cab file required to upload on the Device Update Center

    .DESCRIPTION
    Creates the single large cab containing all required cabs and signs this large cab with the EV cert registered with the Device Update Center. This cab can be uploaded directly to the Device Update Center portal. The output will be available in the build directory `$env:BUILD_DIR\<Product>\<Config>\$env:BSP_VERSION\`

    .PARAMETER Product
    Mandatory parameter identifying the Product directory

    .PARAMETER Config
    Mandatory parameter identifying the config supported by the product. Defined in the product settings.xml. Together with Product parameter, this identifies the build files to be processed.

    .EXAMPLE
    Export-IoTDUCCab SampleA Retail

    .NOTES
    See also Import-IoTDUCConfig
    .LINK
    [Device Update Center User Guide](https://aka.ms/deviceupdatecenter)
    .LINK
    [Import-IoTDUCConfig](Import-IoTDUCConfig.md)
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product,
        # Product configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
    )
    try {
        $iotprod = New-IoTProduct $Product $Config
        $iotprod.ExportOCP()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}

function Export-IoTDeviceModel {
    <#
    .SYNOPSIS
    Exports the DeviceModel XML file required to register the device in the Device Update Center portal.

    .DESCRIPTION
    Creates the IoTDeviceModel xml file with the required contents (SMBIOS and shipping versions). this file can be found at the product directory with the name `IoTDeviceModel_<productname>.xml`

    .PARAMETER Product
    Mandatory parameter identifying the Product

    .EXAMPLE
    Export-IoTDeviceModel SampleA

    .NOTES
    See also Import-IoTDUCConfig
    .LINK
    [Device Update Center User Guide](https://aka.ms/deviceupdatecenter)
    .LINK
    [Import-IoTDUCConfig](Import-IoTDUCConfig.md)
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Product
    )
    try {
        $iotprod = New-IoTProduct $Product Test
        $iotprod.CreateDeviceModel()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
}

function Clear-UserTemp() {
    <#
    .SYNOPSIS
    Clears the User temp directory removing the temp files left behind by the imaging tools

    .DESCRIPTION
    Clears the User temp directory removing the temp files left behind by the imaging tools

    .EXAMPLE
    Clear-UserTemp

    .NOTES
    This is not required to be run with the new toolkit as the temp folder location is changed. You can use this to cleanup your machine from the temp files left behind with the earlier toolkit based builds.
    #>
    $dirstodelete = @()
    $searchstr = "*" + $env:OEM_NAME + "*"
    $filestodelete = Get-ChildItem -Path "$env:Temp\*" -Include *.mum, *.manifest, update.cat, *ImageUpdate*, *IoTUAP*, *UpdateOS*, $searchstr -Recurse | Foreach-Object { $_.FullName }

    foreach ($file in $filestodelete) {
        $frags = $file.Split("\")
        $index = [array]::IndexOf($frags, "Temp") + 1
        if (!($dirstodelete -contains $frags[$index])) {
            $dirstodelete += $frags[$index]
        }
    }

    foreach ($dir in $dirstodelete) {
        Write-Debug "Cleaning $dir"
        if (Test-Path $env:Temp\$dir) {
            Remove-Item $env:Temp\$dir -Recurse -Force
        }
    }

    $tempdirs = Get-ChildItem -Path "$env:Temp" -Directory
    foreach ($dir in $tempdirs) {
        # No recurse here. Only delete empty dirs in the temp folder
        $files = Get-ChildItem -Path $dir.FullName
        if ($null -eq $files) {
            Write-Debug "Cleaning empty dir: $($dir.Name)"
            Remove-Item $dir.FullName
        }
        $files = $null
    }
}

function New-IoTInf2Cab {
    <#
    .SYNOPSIS
    Creates a cab file for the given inf.

    .DESCRIPTION
    This command creates the wm.xml file in the same location as the inf file and builds a cab file. This does not add the driver to the workspace. See Add-IoTDriverPackage for adding driver to workspace.

    .PARAMETER InfFile
    Mandatory parameter, specifying the inf file.

    .PARAMETER OutputName
    Optional parameter specifying the package name (namespace.name format). Default is Drivers.<InfName>.

    .EXAMPLE
    New-IoTInf2Cab C:\Test\gpiodrv.inf Drivers.GPIO
    Creates Oemname.Drivers.GPIO.cab in the build\<arch>\pkg directory.

    .NOTES
    See Add-IoTDriverPackage to add driver to workspace and New-IoTCabPackage to build a cab file.

    .LINK
    [Add-IoTDriverPackage](Add-IoTDriverPackage.md)
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Leaf })]
        [String]$InfFile,
        [Parameter(Position = 1, Mandatory = $false)]
        [String]$OutputName
    )

    $fileobj = Get-Item $InfFile
    if ($fileobj.Extension -ine ".inf" ) {
        Publish-Error "$InfFile is not an inf file"
        return
    }

    if ([string]::IsNullOrWhiteSpace($OutputName)) {
        $OutputName = "Drivers." + $fileobj.BaseName
    }

    $srcdir = Split-Path -Path $InfFile
    $filedir = $srcdir

    # Write the wm.xml file
    $namespace = $OutputName.Split('.')[0]
    $name = $OutputName.Split('.')[1]
    try {
        $wmwriter = New-IoTWMWriter $filedir $namespace $name -force
        $wmwriter.Start($null)
        $wmwriter.AddDriver($fileobj.Name)
        $wmwriter.Finish()
    }
    catch {
        $msg = $_.Exception.Message
        Publish-Error "$msg"; return
    }
    # create package
    $retval = New-IoTCabPackage $filedir
    if ($retval) {
        Publish-Success "Driver cab created successfully."
    }
    else {
        Publish-Error "Failed creating driver cab."
    }
}
