<#
IoTDeviceLayout Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTDeviceLayout {
    [string] $FileName
    [xml] $XmlDoc
    [string[]] $FsPartitions
    [hashtable] $DriveLetters

    # Constructor
    IoTDeviceLayout ([string] $FilePath) {
        if (!(Test-Path $FilePath)) {
            throw "$FilePath file not found"
        }
        $this.FileName = $FilePath
        $this.XmlDoc = [xml] (Get-Content -Path $FilePath)
        $this.FsPartitions = @()
        $this.DriveLetters = @{}
    }

    [void] ParseDeviceLayout() {
        Write-Verbose "Parsing $($this.FileName)"
        $partitions = $this.XmlDoc.DeviceLayout.Partitions.Partition
        $drivesinuse = @()
        $drivesinuse += (Get-PSDrive -PSProvider filesystem).Name
        Write-Debug "Initial : $drivesinuse"

        $guids = @("{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}", "{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}", "0x0C", "0x07")
        $mbrguids = @("0x0C", "0x07")
        $IsMBR = $false
        $count = 1
        $this.FsPartitions = @()
        foreach ($partition in $partitions) {
            $ParDrive = "-"
            $ParName = $partition.Name
            $ParFS = $partition.FileSystem
            if (!$ParFS) { $ParFS = "NA"}
            $ParType = $partition.Type

            # Assign a drive letter if partition type is in guids list
            if ($guids -contains $ParType) {
                foreach ($drvletter in "DEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()) {
                    if ($drivesinuse -notcontains $drvletter) {
                        $ParDrive = $drvletter; break
                    }
                }
                $drivesinuse += $ParDrive
                Write-Debug "DrivesinUse : $drivesinuse"
                $this.FsPartitions += "$ParName,$ParDrive,$count,$ParFS,$ParType"
                $this.DriveLetters[$ParName] = "$ParDrive" + ":\"
            }
            if ( $mbrguids -contains "$ParType") {
                $IsMBR = $true;
            }
            if (($count -eq 3) -and ($IsMBR) ) {
                # account for extended partition in slot 4 with MBR layouts
                $count = $count + 2;
            }
            else { $count = $count + 1; }
        }
        Write-Debug "Final   : $drivesinuse"
    }

    [Boolean] ValidateDeviceLayout() {
        $retval = $true
        $mmosfound = 0
        $systemguids = @("{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}", "0x0C")
        $partitions = $this.XmlDoc.DeviceLayout.Partitions.Partition
        foreach ($partition in $partitions) {
            $ParName = $partition.Name
            $ParFS = $partition.FileSystem
            if (!$ParFS) { $ParFS = "NA"}
            $ParType = $partition.Type

            # Partition specific validations
            if ($ParName -ieq "MMOS") {
                if ($ParFS -ieq "NTFS") { Publish-Warning "Recovery partition is NTFS. Change to FAT32 if you are using Bitlocker" }
                $mmosfound = 1
            }
            elseif ($ParName -ieq "EFIESP") {
                if ($systemguids -notcontains $ParType) {
                    Publish-Warning "EFIESP partition should be set to SYSTEM_GUID ($systemguids) for Bitlocker to work, it is now $ParType"
                }
            }
            elseif ($ParName -ieq "MainOS") {
                $freesectors = [convert]::ToInt32($partition.MinFreeSectors)
                if ($freesectors -ilt 1048576 ) {
                    Publish-Error "Free sectors in MainOS is less than recommended 512MB size. Expected value is 1048576 or above. Current value is $freesectors"
                    $retval = $false
                }
            }
        }
        if (!$mmosfound) { Publish-Warning "MMOS Partition not found in device layout" }
        return $retval
    }

    [void] GenerateRecoveryScripts([string] $RecoveryPath) {
    
        New-DirIfNotExist $RecoveryPath
        # Generate required files
        # Define the files/dirs that we will generate
        $setdrivecmd = "$RecoveryPath\setdrives.cmd"
        $diskpart_assign = "$RecoveryPath\diskpart_assign.txt"
        $diskpart_remove = "$RecoveryPath\diskpart_remove.txt"
        $restore_junction = "$RecoveryPath\restore_junction.cmd"

        # Write the header part for the diskpart scripts here
        Set-Content -Path $diskpart_assign -Value "sel dis 0"
        Add-Content -Path $diskpart_assign -Value "lis par`n"
        Add-Content -Path $diskpart_assign -Value "lis vol`n"

        Set-Content -Path $diskpart_remove -Value "sel dis 0"
        Add-Content -Path $diskpart_remove -Value "lis par`n"
        Add-Content -Path $diskpart_remove -Value "lis vol`n"

        # Use the FsPartitions and generate the files
        $systemguids = @("{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}", "0x0C")
        foreach ($partition in $this.FsPartitions) {
            $parts = $partition.Split(",")
            $ParName = $parts[0]
            $ParDrive = $parts[1]
            $ParID = $parts[2]
            $ParFS = $parts[3]
            $ParType = $parts[4]

            Write-Verbose "Setting $ParName Drive: DL_$ParName=$ParDrive"

            if ($ParName -ieq "MainOS") {
                # For the target version, make sure MainOS gets C drive
                Add-Content -Path $setdrivecmd -Value "echo Setting $ParName Drive: DL_$ParName=C"
                Add-Content -Path $setdrivecmd -Value "set DL_$ParName=C`n"
                Add-Content -Path $diskpart_assign -Value "sel par $ParID"
                Add-Content -Path $diskpart_assign -Value "assign letter=C noerr`n"
            }
            else {
                Add-Content -Path $setdrivecmd -Value "echo Setting $ParName Drive: DL_$ParName=$ParDrive"
                Add-Content -Path $setdrivecmd -Value "set DL_$ParName=$ParDrive`n"
                Add-Content -Path $diskpart_assign -Value "sel par $ParID"
                Add-Content -Path $diskpart_assign -Value "assign letter=$ParDrive noerr`n"
            }
            Add-Content -Path $diskpart_remove -Value "sel par $ParID"
            Add-Content -Path $diskpart_remove -Value "remove noerr`n"

            # Add to restore junction if type is NTFS and not mainOS and not having systemguids
            if (($ParName -ine "MainOS") -and ($ParFS -ieq "NTFS")) {
                if ($systemguids -notcontains $ParType) {
                    $drv = $ParDrive + ":\"
                    Add-Content -Path $restore_junction -Value "REM restoring $ParName junction"
                    Add-Content -Path $restore_junction -Value "mountvol $drv /L > volumeguid_$ParName.txt"
                    Add-Content -Path $restore_junction -Value "set /p VOLUMEGUID_$ParName=<volumeguid_$ParName.txt"
                    Add-Content -Path $restore_junction -Value "rmdir C:\$ParName"
                    Add-Content -Path $restore_junction -Value "mklink /J C:\$ParName %VOLUMEGUID_$ParName%`n"
                }
            }
        }

        # Write the end part for the diskpart scripts here
        Add-Content -Path $diskpart_assign -Value "lis vol"
        Add-Content -Path $diskpart_assign -Value "exit`n"
        Add-Content -Path $diskpart_remove -Value "lis vol"
        Add-Content -Path $diskpart_remove -Value "exit`n"
        Publish-Success "Recovery scripts available at $RecoveryPath"
    }
}
