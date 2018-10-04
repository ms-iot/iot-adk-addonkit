<#
This contains IoTWMXML Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTWMXML {
    [string] $FileName
    [xml] $XmlDoc
    static [string] $xmlns = "urn:Microsoft.CompPlat/ManifestSchema.v1.00"
    # Constructor
    IoTWMXML ([string]$inputxml, [Boolean]$Create) {
        $fileexist = Test-Path $inputxml -PathType Leaf
        if (!$Create -and !$fileexist ) { throw "$inputxml file not found" }
        $this.FileName = $inputxml
        if ($Create) {
            if (!$fileexist) {
                $this.CreateWMXML()
            }
            else { Publish-Warning "$inputxml already exists, opening existing file" }
        }
        $this.XmlDoc = [xml]( Get-Content -Path $inputxml)
    }

    hidden [void] CreateWMXML() {
        Write-Verbose "Creating $($this.FileName)..."
        $xmlwriter = New-Object System.Xml.XmlTextWriter($this.Filename, [System.Text.Encoding]::UTF8)
        $xmlwriter.Formatting = "Indented"
        $xmlwriter.Indentation = 2
        $xmlwriter.WriteStartDocument()
        $xmlwriter.WriteStartElement("identity")
        $xmlwriter.WriteAttributeString("xmlns", "xsd", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema")
        $xmlwriter.WriteAttributeString("xmlns", "xsi", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema-instance")
        $file = Split-Path -Path $this.FileName -Leaf
        $names = $file.Split('.')
        if ($names.Count -eq 4){
            $name = $names[1]
            $namespace = $names[0]
        }
        else {
            $name = $names[0]
            $namespace = "Common"
        }
        $xmlwriter.WriteAttributeString("name", $name)
        $xmlwriter.WriteAttributeString("namespace", $namespace)
        $xmlwriter.WriteAttributeString("owner", "`$(OEMNAME)")
        if (!$this.SkipLegacyName) {
            $xmlwriter.WriteAttributeString("legacyName", "`$(OEMNAME).$namespace.$name")
        }
        $xmlwriter.WriteAttributeString("xmlns", [IoTWMXML]::xmlns)
        $xmlwriter.WriteStartElement("onecorePackageInfo")
        $xmlwriter.WriteAttributeString("targetPartition", "MainOS")
        $xmlwriter.WriteAttributeString("releaseType", "Production")
        $xmlwriter.WriteAttributeString("ownerType", "OEM")
        $xmlwriter.WriteEndElement() # onecorePackageInfo element
        $xmlwriter.WriteEndElement() # identity element
        $xmlwriter.WriteEndDocument()
        $xmlwriter.Flush()
        $xmlwriter.Close()
    }

    [void] SetTargetPartition([string] $partition) {
        $this.XmlDoc.identity.onecorePackageInfo.targetPartition = $partition
        $this.XmlDoc.Save($this.FileName)
    }

    [void] AddFile([string]$destpath, [string]$srcname, [string]$destname) {
        $node = $this.XmlDoc.GetElementsByTagName("file") |  Where-Object { ($_.source) -ieq $srcname }
        if ($node) {
            Publish-Warning "$srcname already defined"
            return
        }
        $newfile = $this.XmlDoc.CreateElement("file", [IoTWMXML]::xmlns)
        $attr = $this.XmlDoc.CreateAttribute("destinationDir")
        $attr.Value = $destpath
        $newfile.Attributes.Append($attr)
        $attr = $this.XmlDoc.CreateAttribute("source")
        $attr.Value = $srcname
        $newfile.Attributes.Append($attr)
        $attr = $this.XmlDoc.CreateAttribute("name")
        $attr.Value = $destname
        $newfile.Attributes.Append($attr)
        $node = $this.XmlDoc.identity.files
        if ($node) {
            $node.AppendChild($newfile)
        }
        else {
            $filesnode = $this.XmlDoc.CreateElement("files", [IoTWMXML]::xmlns)
            $filesnode.AppendChild($newfile)
            $rootnode = $this.XmlDoc.identity
            $rootnode.AppendChild($filesnode)
        }
        Write-Debug "$srcname added"
        $this.XmlDoc.Save($this.FileName)
    }

    [void] RemoveFile([string]$srcname) {

        $node = $this.XmlDoc.GetElementsByTagName("file") |  Where-Object { ($_.source) -ieq $srcname }
        if (!$node) {
            Publish-Warning "$srcname not present"
            return
        }
        $parentnode = $node.ParentNode
        $oldnode = $parentnode.RemoveChild($node)
        # Remove <files> tag if no <file> present.
        if (!$parentnode.ChildNodes.Count) {
            $oldnode = $parentnode.ParentNode.RemoveChild($parentnode)
        }
        Write-Debug "$oldnode removed"
        $this.XmlDoc.Save($this.FileName)
    }

    [void] AddRegistry([string] $keyName, [string] $regValue, [string] $regType, [string] $regData) {
        $node = $this.XmlDoc.GetElementsByTagName("regKey") |  Where-Object { ($_.keyName) -ieq $keyName }
        if ($node) {
            if ( $null -eq $regvalue) {
                Publish-Warning "$keyName already defined"
                return 
            }
            if (-not [string]::IsNullOrWhiteSpace($regValue) ) {
                $regnode = $node.GetElementsByTagName("regValue") |  Where-Object { ($_.name) -ieq $regValue }
                if ($regnode) {
                    Publish-Warning "$keyName $regValue already defined"
                    return
                }
            }
        }
        $regValNode = $this.XmlDoc.CreateElement("regValue", [IoTWMXML]::xmlns)
        $attr = $this.XmlDoc.CreateAttribute("name")
        $attr.Value = $regValue
        $regValNode.Attributes.Append($attr)
        $attr = $this.XmlDoc.CreateAttribute("type")
        $attr.Value = $regType
        $regValNode.Attributes.Append($attr)
        $attr = $this.XmlDoc.CreateAttribute("value")
        $attr.Value = $regData
        $regValNode.Attributes.Append($attr)

        if ($node) {
            $node.AppendChild($regValNode)
        }
        else {
            # regKey not present, so create the element
            $regNode = $this.XmlDoc.CreateElement("regKey",[IoTWMXML]::xmlns)
            $attr = $this.XmlDoc.CreateAttribute("keyName")
            $attr.Value = $keyName
            $regNode.Attributes.Append($attr)
            $regNode.AppendChild($regValNode)
            $regkeysNode = $this.XmlDoc.identity.regKeys
            if ($regkeysNode) {
                # regKeys node present, so just add this child node
                $regkeysNode.AppendChild($regNode)
            }
            else {
                # regKeys node not present, create the node and add to the root node
                $regkeysNode = $this.XmlDoc.CreateElement("regKeys",[IoTWMXML]::xmlns)
                $regkeysNode.AppendChild($regNode)
                $rootnode = $this.XmlDoc.identity
                $rootnode.AppendChild($regkeysNode)
            }
        }
        Write-Debug "$keyName $regValue added"
        $this.XmlDoc.Save($this.FileName)
    }

    [void] RemoveRegistry([string] $keyName, [string] $regValue) {

        $node = $this.XmlDoc.GetElementsByTagName("regKey") |  Where-Object { ($_.keyName) -ieq $keyName }
        if (!$node) {
            Publish-Warning "$keyName not present"
            return
        }
        if (-not [string]::IsNullOrWhiteSpace($regValue) ) {
            $regnode = $node.GetElementsByTagName("regValue") |  Where-Object { ($_.name) -ieq $regValue }
            if (!$regnode) {
                Publish-Warning "$regValue not defined for $keyName"
                return
            }
            $oldnode = $node.RemoveChild($regnode)
        }
        else {
            # Note : deletes all the regValues under this regKey as well
            $parentnode = $node.ParentNode
            $oldnode = $parentnode.RemoveChild($node)
            if (!$parentnode.ChildNodes.Count) {
                $oldnode = $parentnode.ParentNode.RemoveChild($parentnode)
            }
        }
        Write-Debug "$oldnode removed"
        $this.XmlDoc.Save($this.FileName)
    }
}
