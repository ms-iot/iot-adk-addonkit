@echo off
setlocal EnableDelayedExpansion
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dpn0.ps1" %*
