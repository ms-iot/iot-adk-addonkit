######################################
# GetPartitionInfo.ps1
# Parses the partitions in the device layout file 
# Prints out a csv with the partition names with ids, type and total sectors
# Example: GetPartitionInfo.ps1 Devicelayout.xml 
######################################

Param(
    [string] $inputXML
)

################
# Main Function
################

$dlxDoc = [xml] (get-content $inputXML);
Write-Host "PartitionName,ID,Type,TotalSectors,FileSystem";
$Partitions = $dlxDoc.GetElementsByTagName("Partition");
$count = 1;
Foreach ($Partition in $Partitions)
{
    $ParName=$Partition.Name;
    $ParType=$Partition.Type;
    $ParSize=$Partition.TotalSectors;
	$ParFS=$Partition.FileSystem;
    Write-Host "$ParName,$count,$ParType,$ParSize,$ParFS";
    $count= $count + 1;
}
