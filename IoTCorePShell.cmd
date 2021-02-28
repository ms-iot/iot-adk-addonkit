@echo off
powershell -Command "Start-Process 'pwsh.exe' -ArgumentList '-noexit -ExecutionPolicy Bypass -Command \". %~dp0Tools\Launchshell.ps1\"' -Verb runAs"
