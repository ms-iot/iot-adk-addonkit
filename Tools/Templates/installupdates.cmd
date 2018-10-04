@echo off
REM Script to install the updates
setlocal

SET install_dir=%~dp0
cd %install_dir%
for /f "delims=" %%i in (packagelist.txt) do (
   echo Processing %%i
   call applyupdate -stage %%i
)

echo.
echo Commit updates
applyupdate -commit
endlocal
exit /b

