######################################
# DeviceModel.ps1
# Creates the Device Model XML file to upload in the Device Update Center
######################################

Param(
    [string] $productname,
    [switch] $Silent
)

################
# Main Function
################

$dixmlfile = "$env:SRC_DIR\Products\$productname\IoTDeviceModel_$($productname).xml"
Write-Host "DeviceInventory file : $dixmlfile"
if (Test-Path $dixmlfile) {
    Write-Host "$dixmlfile already exists" -ForegroundColor Red
    return
}

$arch = $env:ARCH
$key = "Registry::HKEY_CLASSES_ROOT\Installer\Dependencies\Microsoft.Windows.Windows_10_IoT_Core_$($arch)_Packages.x86.10"
if (Test-Path $key) {
    $corekitver = (Get-ItemProperty -Path $key).Version
    $corekitver = $corekitver.Replace("10.1.", "10.0.")
}
else {
    Write-Host "IoT Core kit ver not found in registry" -ForegroundColor Red
    return
}

Write-Host "OS Version           : $corekitver"
Write-Host "BSP Version          : $env:BSP_VERSION"

$smbioscfg = "$env:SRC_DIR\Products\$productname\SMBIOS.CFG"
if (Test-Path $smbioscfg) {
    Write-Host "Parsing SMBIOS.CFG to get SMBIOS information"
    $doc = Get-Content $smbioscfg
    foreach ($line in $doc) {
        $parts = $line.Split(",")
        if ($parts[0] -eq "01") {
            switch ($parts[1]) {
                '04' {
                    $Manufacturer = $parts[3] -replace '"', ""
                    Write-Output "Manufacturer : $Manufacturer"
                    break
                }
                '05' {
                    $ProductName = $parts[3] -replace '"', ""
                    Write-Output "Product Name : $ProductName"
                    break
                }
                '19' {
                    $SKUNumber = $parts[3] -replace '"', ""
                    Write-Output "SKU Number   : $SKUNumber"
                    break
                }
                '1A' {
                    $Family = $parts[3] -replace '"', ""
                    Write-Output "Family       : $Family"
                    break
                }
            }
        }
    }
}
$encoding = [System.Text.Encoding]::UTF8
$xmlwriter = New-Object System.Xml.XmlTextWriter($dixmlfile, $encoding)
$xmlwriter.Formatting = "Indented"
$xmlwriter.Indentation = 4
$xmlwriter.WriteStartDocument()
$xmlwriter.WriteStartElement("DeviceInventory")
$xmlwriter.WriteAttributeString("SchemaVersion", "1")
$xmlwriter.WriteAttributeString("BuildArch", $arch)
$xmlwriter.WriteAttributeString("OSString", $corekitver)
$xmlwriter.WriteAttributeString("OCPString", $env:BSP_VERSION)
$xmlwriter.WriteStartElement("MachineInfo")
if ($Manufacturer) {
    $usrinput = $Manufacturer
}
else {
    if (!$Silent) {
        $usrinput = Read-Host("Enter Manufacturer           ")
    }
    else { $usrinput = $env:OEM_NAME }
} 
$xmlwriter.WriteAttributeString("Manufacturer", $usrinput)
if ($Family) {
    $usrinput = $Family
}
else {
    if (!$Silent) {
        $usrinput = Read-Host("Enter Family           ")
    }
    else { $usrinput = $env:OEM_NAME + "Family" }
}
$xmlwriter.WriteAttributeString("Family", $usrinput)
if ($ProductName) {
    $usrinput = $ProductName
}
else {
    $usrinput = $productname 
}
$xmlwriter.WriteAttributeString("ProductName", $usrinput)
if ($SKUNumber) {
    $usrinput = $SKUNumber
}
else {
    if (!$Silent) {
        $usrinput = Read-Host("Enter SKUNumber           ")
    }
    else { $usrinput = $productname + "01" }
}
$xmlwriter.WriteAttributeString("SKUNumber", $usrinput)
$usrinput = "Fabrikam"
if (!$Silent) {
    $usrinput = Read-Host("Enter BaseboardManufacturer  ")
}
$xmlwriter.WriteAttributeString("BaseboardManufacturer", $usrinput)
$usrinput = $productname + "_v01"
if (!$Silent) {
    $usrinput = Read-Host("Enter BaseboardProduct (HWvID) ")
}
$xmlwriter.WriteAttributeString("BaseboardProduct", $usrinput)
$xmlwriter.WriteEndElement() # MachineInfo element
$xmlwriter.WriteEndElement() # DeviceInventory element
$xmlwriter.WriteEndDocument()
$xmlwriter.Flush()
$xmlwriter.Close()
Write-Host "DeviceInventory created"
