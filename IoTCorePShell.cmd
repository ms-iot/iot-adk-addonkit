@echo off
powershell -Command "Start-Process 'powershell.exe' -ArgumentList '-noexit -ExecutionPolicy Unrestricted -Command \". %~dp0Tools\Launchshell.ps1\"' -Verb runAs"
