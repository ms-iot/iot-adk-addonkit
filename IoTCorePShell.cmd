@echo off
powershell -Command "Start-Process 'powershell.exe' -ArgumentList '-noexit -ExecutionPolicy Bypass -Command \". %~dp0Tools\Launchshell.ps1\"' -Verb runAs"
