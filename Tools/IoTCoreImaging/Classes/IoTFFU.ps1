<#
IoTFFU Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTFFU {

    #Singleton instance
    static [IoTFFU] $FFUObject

    [string] $FileName
    [string] $FileDir
    [string] $DiskDrive # to store the mount info
    [string] $MountPath
    [IoTDeviceLayout] $DeviceLayout

    #Constructor
    IoTFFU () {
        if ([IoTFFU]::FFUObject -ne $null) {
            throw "Instance already exists. Use [IoTFFU]::GetInstance"
        }
    }

    static [IoTFFU] GetInstance() {
        if ([IoTFFU]::FFUObject -eq $null) {
            [IoTFFU]::FFUObject = [IoTFFU]::new()
        }
        return [IoTFFU]::FFUObject
    }
    #Initialize
    [void] Initialize ([string] $ffufile) {
        if (!(Test-Path $ffufile)) { throw "$ffufile file not found" }
        $this.FileName = $ffufile
        $this.FileDir = Split-Path -Path $ffufile
    }

    [void] Mount() {
        # Check whether the ffu is already mounted
        if ($this.IsMounted()) {
            Publish-Error "Mount failed as another FFU is already mounted."
            return 
        }
        
        # Mount the ffu
        Publish-Status "Mounting $($this.FileName)"
        Push-Location $this.FileDir
        $mountlog = wpimage mount $this.FileName

        #TODO: handle error condition here
        # parse mountlog to get mountpath and diskdrive
        foreach ($line in $mountlog) {
            $texts = $line.Split(":")
            if ($texts[0].contains("Main Mount Path")) {
                if ([string]::IsNullOrWhiteSpace($texts[2]))
                {
                    # parse new format: "Main Mount Path:  \\.\Volume{ae420040-0000-0000-0000-800200000000}\\"
                    $this.MountPath = $texts[1].trim()
                }
                else
                {
                    # parse old format: "Main Mount Path: C:\Users\slmihov\AppData\Local\Temp\oyzhnc4l.zvq.mnt\"
                    $this.MountPath = $texts[1].trim() + ":" + $texts[2].trim()
                }
            }
            elseif ($texts[0].contains("Physical Disk Name")) {
                $this.DiskDrive = $texts[1].trim()
            }
        }

        Publish-Status "FFU mounted :" $this.MountPath $this.DiskDrive
        Pop-Location

        # Get device layout from the FFU
        $dlxml = "$($this.MountPath)Windows\ImageUpdate\Devicelayout.xml"
        if (!(Test-Path $dlxml)) {
            Publish-Error "Cannot find device layout"
            return
        }
        $this.DeviceLayout = New-IoTDeviceLayout $dlxml
        $this.DeviceLayout.ParseDeviceLayout()

        Publish-Success "Device layout parsing completed"

        $this.AssignDriveLetters()
    }

    [Boolean] IsMounted() {
        return ![string]::IsNullOrWhiteSpace($this.DiskDrive) 
    }

    [Boolean] Dismount([string] $filename) {
        $retval = $false
        if ($this.IsMounted()) {
            # Remove drive letters
            Publish-Status "Removing drive letters"
            $this.RemoveDriveLetters()
            if ([string]::IsNullOrWhiteSpace($filename)) {
                Publish-Status "Dismounting FFU without saving"
                wpimage dismount -physicaldrive $this.DiskDrive
                $retval = $?
            }
            else {
                Publish-Status "Dismounting FFU and saving as $filename"
                Remove-ItemIfExist "$($this.FileDir)\$filename"
                wpimage dismount -physicaldrive $this.DiskDrive -imagepath "$($this.FileDir)\$filename" -nosign
                $retval = $?
            }

            #TODO: handle dismount error conditions
            # Clear mount point info
            if ($retval) {
                $this.DiskDrive = "" #clear out mount point
                $this.MountPath = ""
            }
        }
        else {  Publish-Warning "FFU is not mounted." }
        return $retval
    }

    [void] ExtractWims() {
        if ($this.IsMounted()) {
            # Extract wim files and then copy
            Publish-Status "Extracting wims..."
            $efiespwim = "$($this.FileDir)\efiesp.wim"
            $efiesp = $this.DeviceLayout.DriveLetters.EFIESP
            Remove-ItemIfExist $efiespwim
            Publish-Status "Extracting EFIESP wim from $efiesp"
            New-WindowsImage -ImagePath $efiespwim -CapturePath $efiesp -Name "EFIESP"

            # Data partition extraction
            $datawim = "$($this.FileDir)\data.wim"
            Remove-ItemIfExist $datawim
            $data = $this.DeviceLayout.DriveLetters.Data
            Publish-Status "Extracting Data wim from $data"
            New-WindowsImage -ImagePath $datawim -CapturePath $data -Name "DATA" -CompressionType "max"

            # MainOS partition extraction
            $mainoswim = "$($this.FileDir)\mainos.wim"
            Remove-ItemIfExist $mainoswim
            $mainos = $this.DeviceLayout.DriveLetters.MainOS
            Publish-Status "Extracting MainOS wim from $mainos, this may take a while..."
            New-WindowsImage -ImagePath $mainoswim -CapturePath $mainos -Name "MainOS" -CompressionType "max"
            Publish-Success "Wim extractions completed."
        }
        else {  Publish-Warning "FFU is not mounted." }
    }

    hidden [void] AssignDriveLetters() {
        if ($this.IsMounted()) {
            $disknr = $this.DiskDrive.Substring($this.DiskDrive.length - 1)
            Write-Debug "DiskNr = $disknr"
            foreach ($partition in $this.DeviceLayout.FsPartitions) {
                #$this.DeviceLayout.FsPartitions "$ParName,$ParDrive,$count,$ParFS,$ParType"
                $parts = $partition.Split(",")
                $ParDrive = $parts[1] + ":"
                $ParID = $parts[2]
                Add-PartitionAccessPath -DiskNumber $disknr -PartitionNumber $ParID -AccessPath $ParDrive
            }
            Publish-Status "Assigned drive letters below"
            Publish-Status ($this.DeviceLayout.DriveLetters | Out-String)
        }
    }

    hidden [void] RemoveDriveLetters() {
        if ($this.IsMounted()) {
            $disknr = $this.DiskDrive.Substring($this.DiskDrive.length - 1)
            Write-Debug "DiskNr = $disknr"
            foreach ($partition in $this.DeviceLayout.FsPartitions) {
                #$this.DeviceLayout.FsPartitions "$ParName,$ParDrive,$count,$ParFS,$ParType"
                $parts = $partition.Split(",")
                $ParDrive = $parts[1] + ":"
                $ParID = $parts[2]
                Remove-PartitionAccessPath -DiskNumber $disknr -PartitionNumber $ParID -AccessPath $ParDrive
            }
            Publish-Status "Drive letters removed"
        }
    }

    [void] ScanNewCIPolicy() {
        if ($this.IsMounted()) {
            $secdir = "$($this.FileDir)\security"
            New-DirIfNotExist $secdir
            $initialPolicy = "$secdir\initialpolicy.xml"
            $initialPolicy_Pub = "$secdir\initialpolicy_Publisher.xml"
            $initialPolicy_Leaf = "$secdir\initialpolicy_Leaf.xml"
            $drive = $this.DeviceLayout.DriveLetters.MainOS
            New-CIPolicy -Level PcaCertificate -FilePath $initialPolicy -fallback Hash -ScanPath "$drive" -PathToCatroot "$drive\Windows\System32\catroot" -UserPEs 3> "$($this.FileDir)\CIPolicyLog.txt"

            #New-CIPolicy -Level Publisher -FilePath $initialPolicy_Pub -fallback Hash -ScanPath "$drive" -PathToCatroot "$drive\Windows\System32\catroot" -UserPEs 3> "$($this.FileDir)\CIPolicyLog.txt"

            #New-CIPolicy -Level LeafCertificate -FilePath $initialPolicy_Leaf -fallback Hash -ScanPath "$drive" -PathToCatroot "$drive\Windows\System32\catroot" -UserPEs 3> "$($this.FileDir)\CIPolicyLog.txt"            

            $xmldoc = [xml] (Get-Content -Path $initialPolicy)
            $signers = $xmldoc.SiPolicy.Signers.Signer.Name | Sort-Object | Select-Object -Unique
            Publish-Status "Unique Signers found are listed below"
            foreach ($signer in $signers) {
                Publish-Status $signer
            }
            Publish-Status "CI Policy scan done"
        }
        else {  Publish-Warning "FFU is not mounted." }
    }
}
