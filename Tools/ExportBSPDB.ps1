######################################
# ExportBSPDB.ps1
# Exports the cab files referred in the BSPDBPublish xml file
######################################

Param(
    [string] $FFUDir,
    [string] $DestDir
)

################
# Main Function
################
$BSPDBPublishxml = "$FFUDir\$($env:FFUNAME).BSPDB_publish.xml"

$bspdbpubdoc = [xml] (get-content $BSPDBPublishxml)
$BSPVersion = $bspdbpubdoc.CompDBPublishingInfo.BSPVersion
Write-Host "BSP Version : $BSPVersion"

if ($BSPVersion -ine $env:BSP_VERSION ) {
    Write-Host "BSP version is different from $env:BSP_VERSION." -ForegroundColor Red
    #return
}
Write-Host "Exporting required packages to $outputpath"
$packages = $bspdbpubdoc.GetElementsByTagName("Package")
Foreach ($package in $packages) {
    Write-Host $package.Path
    if (!(Test-Path $package.Path )) {
        $package.Path = $env:MSPACKAGE + "\" + $package.Path
        if (!(Test-Path $package.Path )) {
            Write-Host "$($package.Path) not found" -ForegroundColor Red
        }
    }
    Copy-Item $package.Path $DestDir
}
$BSPDBxml = "$FFUDir\$($env:FFUNAME).BSPDB.xml"
Write-Host "Exporting BSP DB"
Copy-Item $BSPDBxml $DestDir
$bspdbdoc = [xml] (get-content $BSPDBxml)
$pkgs = $bspdbdoc.CompDB.Packages.Package
$ocpname = Split-Path $DestDir -Leaf
$outfile = "$DestDir\..\$($ocpname)_pkgver.txt"
#$outfile = Resolve-Path $outfile
Set-Content -Path $outfile -Value "PackageName,Version"
foreach ($pkg in $pkgs) {
    Add-Content -Path $outfile -Value "$($pkg.ID).cab,$($pkg.Version)"
}

