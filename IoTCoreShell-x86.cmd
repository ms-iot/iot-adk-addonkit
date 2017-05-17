@echo off
powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0\Tools\LaunchTool.cmd x86\"' -Verb runAs"
