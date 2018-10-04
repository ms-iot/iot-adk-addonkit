<#
This module contains the Test functions to validate the signatures of the binaries
#>
. $PSScriptRoot\IoTPrivateFunctions.ps1

#string array to cache the CrossCAList
[string[]] $CrossCAList
function Get-IoTCrossCAList() {
    if (!$Script:CrossCAList) {
        $ConfigFile = "$PSScriptRoot\IoTEnvSettings.xml"
        [xml] $Config = Get-Content -Path $ConfigFile
        $Script:CrossCAList = $Config.IoTEnvironment.CrossCertCAs.CrossCertCA
    }
    $Script:CrossCAList
}
function Test-IoTCabSignature {
    <#
    .SYNOPSIS
    Checks if the cab file and its contents are properly signed.
    
    .DESCRIPTION
    Checks if the cab file and its contents are properly signed.
    
    .PARAMETER CabFile
    Mandatory parameter, the cab file to be inspected
    
    .PARAMETER Config
    Mandatory parameter, specifing the Config. Can be "Retail" or any other ("Test"/"Dev" etc)
    
    .EXAMPLE
    $result = Test-IoTCabSignature C:\myfile.cab Retail
    
    .NOTES
    Uses Test-IoTSignature cmdlet to validate the .cab file, and its contents - .cat. .exe, .dll and .sys
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$CabFile,
        # Product Configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
    )
    $retval = $true;
    if (!(Test-Path $CabFile)) {
        Publish-Error "$CabFile not found."
        return $false
    }
    if ((Get-Item $CabFile).Extension -ine ".cab") {
        Publish-Error "$CabFile is not supported. Provide a .cab file"
        return $false
    }

    # First check the signature of the cab itself
    $retval = Test-IoTSignature $CabFile $Config
    $files_to_check = @("*.dll", "*.sys", "*.exe", "*.cat")

    # Expand cab to get required binaries to a temp dir
    cmd /r "expand $CabFile $env:TMP -F:*" | Out-Null
    $cabcontents = Get-ChildItem -Path $env:TMP -Recurse -Include $files_to_check  | Foreach-Object {$_.FullName}

    # Check signature of the binaries
    if ($cabcontents -ine $null) {
        foreach ($file in $cabcontents) {
            $result = Test-IoTSignature $file $Config
            if (!$result) { $retval = $false }
        }
    }
    else { Write-Debug "No $files_to_check in $CabFile" }

    Clear-Temp
    return $retval
}

function Test-IoTSignature {
    <#
    .SYNOPSIS
    Checks if the file is properly signed.

    .DESCRIPTION
    Checks if the file is properly signed. For Retail Config, it checks if the signature is rooted to Microsoft or a cross rooted cert.

    .PARAMETER FileName
    Mandatory parameter, the file to be inspected

    .PARAMETER Config
    Mandatory parameter, specifying the Config. Can be "Retail" or any other ("Test"/"Dev" etc)

    .EXAMPLE
    $result = Test-IoTSignature C:\myfile.dll Retail

    .NOTES
    This verifies using the signtool. [ signtool verify /v /pa FileName ]
    #>
    [CmdletBinding()]
    Param
    (
        # Product name to process
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$FileName,
        # Product Configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Config
    )
    $retval = $true
    $Name = Split-Path -Path $FileName -Leaf
    $signresult = cmd /r signtool verify /v /pa $FileName
    if ($lastExitCode) {
        Publish-Error "$Name is not signed"
        return $false
    }

    if ( ($signresult | ForEach-Object { $_.Contains("(TEST ONLY)") }) -contains $true ) {
        # Warn about test signature only for retail Config. Otherwise stay quiet.
        if ($Config -ieq "Retail") {
            Publish-Warning " $Name is test signed"
            $retval = $false
        }
    }
    else {
        foreach ($line in $signresult) {
            #TODO: Check for OEM UMCI. Currently only checking cross certs for drivers
            if ($line.contains("    Issued by")) {
                $crosscalist = Get-IoTCrossCAList
                $ca = ($line.Split(":"))[1].trim()
                if ($crosscalist.contains($ca)) {
                    # Looks good. The text message suppressed. Warn only when there is a concern.
                    Write-Verbose "$Name signed with $ca issued Cross Cert"
                }
                else {
                    if (!$ca.contains("Microsoft")) {
                        # Not signed by Microsoft or cross-cert, so warn.
                        Publish-Warning " $Name not signed with a cross signed cert. Signed with $ca"
                        $retval = $false
                    }
                    else {
                        # Looks good. The text message suppressed. Warn only when there is a concern.
                        Write-Verbose "$Name signed with $ca Cert"
                    }
                }
                break
            }
        }
    }
    return $retval
}

function Add-IoTSignature {
    <#
    .SYNOPSIS
    Signs the files with the certificate selected via Set-IoTSignature

    .DESCRIPTION
    Signs the files with the certificate selected via Set-IoTSignature

    .PARAMETER Path
    Path for the files to be signed. Can be a single file or a directory of files

    .PARAMETER Type
    Optional parameter indicating the file type(s) to be signed. If omitted, all file types (*.exe,*.dll.*.sys,*.cat) will be signed.

    .EXAMPLE
    Add-IoTSignature C:\QCSBSP 

    .EXAMPLE
    Add-IoTSignature C:\QCSBSP *.sys,*.dll

    .NOTES
    
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(Position = 1, Mandatory = $false)]
        [String[]]$Type = $null
    )
    $types = @('*.exe', '*.sys', '*.dll', '*.cat')
    if (Test-Path $Path -PathType Container) {
        $filter = $types
        if ($Type) { 
            $check = $Type | Where-Object { $types -notcontains $_ }
            if ($check ) {
                Publish-Error "$check not supported"
                return
            }
            $filter = $Type
        }

        $filestosign = (Get-ChildItem $Path -File -Include $filter -Recurse) | ForEach-Object {$_.FullName}
        if (!$filestosign) {
            Publish-Warning "No $($filter -join ",") files to sign in $Path"
            return
        }
        foreach ($file in $filestosign) {
            Write-Verbose "Signing $file"
            sign $file | Out-Null
        }
        
    }
    elseif (Test-Path $Path -PathType Leaf -Include $types) {
        #Single file. Sign this file 
        Write-Verbose "Signing $file"
        sign $Path | Out-Null
    }
    else {
        Publish-Error "$Path cannot be signed"
    }
}
function Redo-IoTCabSignature {
    <#
    .SYNOPSIS
    Resigns the cab file and its contents / cat files with the certificate set in the environment.

    .DESCRIPTION
    Resigns the cab file and its contents / cat files with the certificate set in the environment. This is useful to sign the cabs from Silicon Vendors with OEM Cross certificate. 

    .PARAMETER Path
    Path containing the source cab files

    .PARAMETER DestinationPath
    Path where the resigned cabs are stored.

    .EXAMPLE
    Redo-IoTCabSignature C:\QCSBSP C:\QCBSP-Signed

    .NOTES
    
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateScript( { Test-Path $_ -PathType Container })]
        [String]$Path,
        # Product Configuration to process
        [Parameter(Position = 1, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$DestinationPath
    )
    New-DirIfNotExist $DestinationPath
    $excludesign = ".HalExt"
    $cabfiles = Get-ChildItem -Path $Path -Filter *.cab 
    if (!$cabfiles) {
        Publish-Error "No .cab files found in $Path"
        return
    }
    foreach ($cabfile in $cabfiles) {
        $filename = $cabfile.BaseName
        Publish-Status "Processing $filename.cab"
        $tempdir = "$DestinationPath\$filename"
        New-Item -Path $tempdir -ItemType Container | Out-Null
        Write-Debug "pkgsigntool unpack : $tempdir"
        pkgsigntool unpack $cabfile.FullName /out:$tempdir | Out-Null
        if ($filename.Contains($excludesign)) {
            Write-Verbose "Skipping signing for $filename ($excludesign)"
        }
        else {
            Add-IoTSignature $tempdir *.sys, *.dll
        }
        Write-Debug "pkgsigntool update : $tempdir"
        pkgsigntool update $tempdir  | Out-Null
        Write-Debug "makecat : $tempdir\content.cdf"
        makecat $tempdir\content.cdf  | Out-Null
        Write-Debug "signcat : $tempdir\update.cat"
        sign $tempdir\update.cat  | Out-Null
        Write-Debug "pkgsigntool repack : $tempdir.cab"
        pkgsigntool repack $tempdir /out:"$tempdir.cab"  | Out-Null
        Write-Debug "signcab : $tempdir.cab"
        sign "$tempdir.cab" | Out-Null
        Remove-Item -Path $tempdir -Recurse -Force | Out-Null
    }
}


function Test-IoTSignatureNew([string] $filename, [string] $Config) {
    $retval = $false
    $Name = Split-Path -Path $filename -Leaf

    # Get a X590Certificate2 certificate object for a file
    $authenticode = Get-AuthenticodeSignature -FilePath $filename
    if ($authenticode.Status -ine "Valid") {
        Publish-Error "$Name signature status is $($authenticode.Status)"
    }
    else {
        $cert = $authenticode.SignerCertificate
        $issuerht = $cert.IssuerName.Name
        $issuername = $issuerht.Split(",")[0].Replace("CN=", "")
        Write-Debug  "File is signed by cert issued by $issuername"

        if ($issuername.contains("Microsoft")) {
            Write-Verbose "$Name signed with $issuername Cert"
            $retval = $true
        }
        elseif ($issuername.contains("TEST ONLY")) {
            if ($Config -ine "Retail") {
                Write-Verbose "$Name signed with test cert :$issuername "
                $retval = $true
            }
            else { Publish-Error "$Name is test signed" }
        }
        else {
            # Create a new chain to store the certificate chain
            $chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain

            # Build the certificate chain from the file certificate
            if ($chain.Build($cert)) {
                $rootcert = $chain.ChainElements[$chain.ChainElements.Count - 1].Certificate
                $rootht = $rootcert.IssuerName.Name
                $rootca = $rootht.Split(",")[0].Replace("CN=", "")
                $crosscalist = Get-IoTCrossCAList
                if ($crosscalist.contains($rootca)) {
                    # Looks good. The text message suppressed. Warn only when there is a concern.
                    Write-Verbose "$Name signed with $rootca issued Cross Cert"
                    $retval = $true
                }
                else {
                    # Not signed by Microsoft or cross-cert, so warn.
                    Publish-Warning " $Name not signed with a cross signed cert. Signed with $rootca"
                }
            }
            else { Publish-Error "Trust chain cannot be established." }
        }
    }
    return $retval
}
