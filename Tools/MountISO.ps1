######################################
# MountISO.ps1
# Mounts an ISO file 
# sets the env variable ISO_DRIVE with the drive letter
######################################

Param(
    [string] $inputISO
)

################
# Main Function
################

$isodrive = (Get-DiskImage -ImagePath $inputISO | Get-Volume).DriveLetter
if (!$isodrive) {
    Mount-DiskImage -ImagePath $inputISO -StorageType ISO
    $isodrive = (Get-DiskImage -ImagePath $inputISO | Get-Volume).DriveLetter
}

Write-Host "$isodrive"

