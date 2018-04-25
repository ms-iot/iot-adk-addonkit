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
$drivesinuse = (Get-PSDrive -PSProvider filesystem).Name
$dlxDoc = [xml] (get-content $inputXML);
Write-Host "PartitionName,ID,Type,TotalSectors,FileSystem,Drive";
$Partitions = $dlxDoc.GetElementsByTagName("Partition");
$count = 1;
$guids = "{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}","{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}","0x0C","0x07";
$mbrguids = "0x0C","0x07";
$IsMBR = $false
Foreach ($Partition in $Partitions)
{
    $ParName=$Partition.Name;
    $ParType=$Partition.Type;
    $ParSize=$Partition.TotalSectors;
    $ParFS=$Partition.FileSystem;
    $ParDrive='-';
    if(!$ParSize){ $ParSize=0;}
    if(!$ParFS){ $ParFS="NA";}
    if ( $guids -contains "$ParType") {
        $ParDrive= GetFreeDriveLetter;
        $drivesinuse+= $ParDrive;
    }
    Write-Host "$ParName,$count,$ParType,$ParSize,$ParFS,$ParDrive";
    if ( $mbrguids -contains "$ParType") {
        $IsMBR = $true;
    }
    if (($count -eq 3) -and ($IsMBR) ) {
        # account for extended partition in slot 4 with MBR layouts
        $count = $count + 2;
    }
    else { $count = $count + 1; }
} 

