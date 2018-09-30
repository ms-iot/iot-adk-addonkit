@echo off
powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/k \"%~dp0\Tools\CmdTools\LaunchTool.cmd\"' -Verb runAs"
