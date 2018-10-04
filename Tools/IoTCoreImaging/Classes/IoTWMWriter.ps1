<#
IoTWMWriter Class definition
#>
. $PSScriptRoot\..\IoTPrivateFunctions.ps1

class IoTWMWriter {
    [string] $Name
    [string] $Namespace
    [string] $FileDir
    [Boolean] $SkipLegacyName
    [System.Xml.XmlTextWriter] $WmWriter
    hidden [string] $Filename
    hidden [Boolean] $IsWritingStarted
    hidden [string] $NestedSection

    # Constructor
    IoTWMWriter([string] $filedir, [string] $namespace, [string] $name, [Switch] $force) {
        if (!(Test-Path $filedir)) { throw "$filedir not found" }
        $this.FileDir = $filedir
        $this.Namespace = $namespace
        $this.Name = $name
        $this.Filename = "$filedir\$namespace.$name.wm.xml"
        if (Test-Path $this.Filename) { 
            if ($force) {
                Remove-Item $this.Filename -Force
            }
            else { throw "$($this.Filename) already exists" }
        }
        $this.WmWriter = New-Object System.Xml.XmlTextWriter($this.Filename, [System.Text.Encoding]::UTF8)
        $this.WmWriter.Formatting = "Indented"
        $this.WmWriter.Indentation = 4
        $this.IsWritingStarted = $false
        $this.SkipLegacyName = $false
    }

    [void] Start([string] $partition) {
        $this.Start("`$(OEMNAME)", $partition)
    }

    [void] Start([string] $oemname, [string] $partition) {
        if ($this.IsWritingStarted) { Publish-Error "Writer already started" ; return }
        if ([string]::IsNullOrWhiteSpace($partition)) {$partition = "MainOS"}
        # Write the XML Decleration
        $this.WmWriter.WriteStartDocument()
        $this.WmWriter.WriteStartElement("identity")
        $this.WmWriter.WriteAttributeString("xmlns", "xsd", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema")
        $this.WmWriter.WriteAttributeString("xmlns", "xsi", "http://www.w3.org/2000/xmlns/", "http://www.w3.org/2001/XMLSchema-instance")
        $this.WmWriter.WriteAttributeString("name", $this.Name)
        $this.WmWriter.WriteAttributeString("namespace", $this.Namespace)
        $this.WmWriter.WriteAttributeString("owner", $oemname)
        if (!$this.SkipLegacyName) {
            $this.WmWriter.WriteAttributeString("legacyName", "$oemname.$($this.Namespace).$($this.Name)")
        }
        $this.WmWriter.WriteAttributeString("xmlns", "urn:Microsoft.CompPlat/ManifestSchema.v1.00")
        $this.WmWriter.WriteStartElement("onecorePackageInfo")
        $this.WmWriter.WriteAttributeString("targetPartition", $partition)
        $this.WmWriter.WriteAttributeString("releaseType", "Production")
        $this.WmWriter.WriteAttributeString("ownerType", "OEM")
        $this.WmWriter.WriteEndElement() # onecorePackageInfo element
        $this.IsWritingStarted = $true
    }

    [void] Finish() {
        if (!$this.IsWritingStarted) {
            Publish-Error "Writer not started. Call Start()"
            return
        }
        # If any nested section was active, close that.
        if ($null -ine $this.NestedSection) { $this.WmWriter.WriteEndElement() }
        $this.WmWriter.WriteEndElement() # identity element
        $this.WmWriter.WriteEndDocument()
        $this.WmWriter.Flush()
        $this.WmWriter.Close()
    }

    [void] AddDriver([string] $inffile) {
        if (!$this.IsWritingStarted) { Publish-Error "Writer not started. Call Start()" ; return }
        if ($this.NestedSection -ine "drivers") {
            # Close the previous nested section
            if ($null -ine $this.NestedSection) { $this.WmWriter.WriteEndElement() }
            $this.WmWriter.WriteStartElement("drivers")
            $this.NestedSection = "drivers"
        }
        $this.WmWriter.WriteStartElement("driver")
        $this.WmWriter.WriteStartElement("inf")
        $this.WmWriter.WriteAttributeString("source", $inffile)
        $this.WmWriter.WriteEndElement() # inf element
        $this.WmWriter.WriteEndElement() # driver element
    }

    [void] AddFiles([string] $destinationDir, [string] $source, [string] $name) {
        if (!$this.IsWritingStarted) {
            Publish-Error "AddFiles:Writer not started. Call Start()"
            return
        }

        # Check for mandatory attributes
        if ([string]::IsNullOrWhiteSpace($destinationDir)) {
            Publish-Error "AddFiles:destinationDir required"
            return
        }
        if ([string]::IsNullOrWhiteSpace($source)) {
            Publish-Error "AddFiles:source required"
            return
        }

        if ($this.NestedSection -ine "files") {
            # Close the previous nested section
            if ($null -ine $this.NestedSection) { $this.WmWriter.WriteEndElement() }
            $this.WmWriter.WriteStartElement("files")
            $this.NestedSection = "files"
        }

        $this.WmWriter.WriteStartElement("file")
        $this.WmWriter.WriteAttributeString("destinationDir", $destinationDir)
        $this.WmWriter.WriteAttributeString("source", $source)
        if (![string]::IsNullOrWhiteSpace($name)) {
            $this.WmWriter.WriteAttributeString("name", $name)
        }
        $this.WmWriter.WriteEndElement() # file element
    }

    [void] AddRegKeys([string] $keyName, [string[][]] $regvalue) {
        if (!$this.IsWritingStarted) {
            Publish-Error "Writer not started. Call Start()"
            return
        }

        # Check for mandatory attributes
        if ([string]::IsNullOrWhiteSpace($keyName)) { Publish-Error "AddRegKeys:keyName required" ; return }
        if ($this.NestedSection -ine "regKeys") {
            # Close the previous nested section
            if ($null -ine $this.NestedSection) { $this.WmWriter.WriteEndElement() }
            $this.WmWriter.WriteStartElement("regKeys")
            $this.NestedSection = "regKeys"
        }
        $this.WmWriter.WriteStartElement("regKey")
        $this.WmWriter.WriteAttributeString("keyName", $keyName)
        if ($null -ine $regvalue) {
            foreach ($reg in $regvalue) {
                $this.WmWriter.WriteStartElement("regValue") # regValue element
                $this.WmWriter.WriteAttributeString("name", $reg[0])
                $this.WmWriter.WriteAttributeString("type", $reg[1])
                $this.WmWriter.WriteAttributeString("value", $reg[2])
                $this.WmWriter.WriteEndElement() # regValue element
            }
        }
        $this.WmWriter.WriteEndElement() # regKey element
    }

    [void] AddRegKeyValue([string] $keyName, [string] $regValue, [string] $regValueType, [string] $regValueData) {
        if (!$this.IsWritingStarted) {
            Publish-Error "Writer not started. Call Start()"
            return
        }

        # Check for mandatory attributes
        if ([string]::IsNullOrWhiteSpace($keyName)) { 
            Publish-Error "AddRegKeyValue:keyName required"
            return
        }
        if ($this.NestedSection -ine "regKeys") {
            # Close the previous nested section
            if ($null -ine $this.NestedSection) { $this.WmWriter.WriteEndElement() }
            $this.WmWriter.WriteStartElement("regKeys")
            $this.NestedSection = "regKeys"
        }
        $this.WmWriter.WriteStartElement("regKey")
        $this.WmWriter.WriteAttributeString("keyName", $keyName)
        if (-not [string]::IsNullOrEmpty($regValue)) {
            $this.WmWriter.WriteStartElement("regValue") # regValue element
            $this.WmWriter.WriteAttributeString("name", $regValue)
            $this.WmWriter.WriteAttributeString("type", $regValueType) #TODO check valid value types
            $this.WmWriter.WriteAttributeString("value", $regValueData)
            $this.WmWriter.WriteEndElement() # regValue element
        }
        $this.WmWriter.WriteEndElement() # regKey element
    }

    [void] AddComment([string] $comment) {
        $this.WmWriter.WriteComment($comment)
    }
}
