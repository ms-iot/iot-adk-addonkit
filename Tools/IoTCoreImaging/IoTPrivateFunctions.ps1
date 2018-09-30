<#
This contains various helper commands for imaging
#>

# Helper methods - Write Output for piping and Host for the screen
function Publish-Error([string] $message) {
    if (($null -ne $host) -and ($null -ne $host.ui)){
        Write-Host "Error: $message" -ForegroundColor Red
    }
    else {
        Write-Error $message
    }   
}
function Publish-Success() {
    Write-Host $args  -ForegroundColor Green
}
function Publish-Status () {
    Write-Host $args
}
function Publish-Warning ([string] $message) {
    if (($null -ne $host) -and ($null -ne $host.ui)){
        Write-Host "Warning: $message" -ForegroundColor Yellow
    }
    else {
        Write-Warning $message
    } 
}

function New-DirIfNotExist ([string] $path, [switch]$force) {
    if (Test-Path $path) {
        if ($force) { 
            Remove-Item $path -Recurse -Force | Out-Null 
        }
        else { return }
    }
    New-Item $path -ItemType Directory | Out-Null
}

function Remove-ItemIfExist ([string] $path) {
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force | Out-Null 
    }
}
function Expand-IoTPath([string] $filepath) {
    return [System.Environment]::ExpandEnvironmentVariables($filepath)
}

function Clear-Temp() {
    <#
    .SYNOPSIS
    Clears the Temp directory in the workspace

    .DESCRIPTION
    Clears the Temp directory in the workspace

    .EXAMPLE
    Clear-Temp

    .NOTES
    This method is invoked at the end of most of the New commands. You may not need to invoke this explicitly.
    #>

    Remove-Item -Path $env:TMP\* -Recurse -Force
}