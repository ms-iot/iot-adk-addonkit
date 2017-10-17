######################################
# GetPartitionInfo.ps1
# Parses the partitions in the device layout file
# Prints out a csv with the partition names with ids, type and total sectors
# Example: GetPartitionInfo.ps1 Devicelayout.xml
######################################

Param(
    [string] $inputXML
)

function GetFreeDriveLetter()
{
    Foreach ($drvletter in "DEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()) {
    if ($drivesinuse -notcontains $drvletter) {
        #Write-Host $drvletter, $drivesinuse;
        return $drvletter;
    }
    }
}

################
# Main Function
################

#getting all the used Drive letters reported by the Operating System
$drivesinuse = @();
$(Get-PSDrive -PSProvider filesystem) | %{$drivesinuse += $_.name}
$dlxDoc = [xml] (get-content $inputXML);
Write-Host "PartitionName,ID,Type,TotalSectors,FileSystem,Drive";
$Partitions = $dlxDoc.GetElementsByTagName("Partition");
$count = 1;


Foreach ($Partition in $Partitions)
{
    $ParName=$Partition.Name;
    $ParType=$Partition.Type;
    $ParSize=$Partition.TotalSectors;
    $ParFS=$Partition.FileSystem;
    $ParDrive='-';
    if(!$ParSize){ $ParSize=0;}
    if(!$ParFS)
    {
        $ParFS="NA";
        if (($ParType -eq '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}') -or ($ParType -eq '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}')) {
            $ParDrive= GetFreeDriveLetter;
            $drivesinuse+= $ParDrive;
        }
    }
    else
    {
        $ParDrive=GetFreeDriveLetter;
        $drivesinuse+= $ParDrive;
    }

    Write-Host "$ParName,$count,$ParType,$ParSize,$ParFS,$ParDrive";
    $count= $count + 1;
}
