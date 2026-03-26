@echo off
title MetaScope CLI Installer
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Administrator privileges required!
    powershell start -verb runas '%0'
    exit /b
)

echo ================================================
echo         MetaScope CLI Installer v1.1
echo ================================================
echo.

set "INSTALL_DIR=C:\Program Files\MetaScope"
set "EXE_NAME=metascope.exe"
set "SOURCE_EXE=%~dp0%EXE_NAME%"

if not exist "%SOURCE_EXE%" (
    echo [ERROR] %EXE_NAME% not found in current folder!
    pause
    exit /b 1
)

echo [1/5] Stopping running instances...
taskkill /f /im "%EXE_NAME%" >nul 2>&1

echo [2/5] Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [3/5] Copying files...
copy /y "%SOURCE_EXE%" "%INSTALL_DIR%\%EXE_NAME%" >nul

echo [4/5] Adding to system PATH (PowerShell Method)...
powershell -Command "$oldPath = [Environment]::GetEnvironmentVariable('Path', 'Machine'); if ($oldPath -notlike '*%INSTALL_DIR%*') { [Environment]::SetEnvironmentVariable('Path', \"$oldPath;%INSTALL_DIR%\", 'Machine') }"

echo [5/5] Creating shortcuts...
set "SHORTCUT=%USERPROFILE%\Desktop\MetaScope.lnk"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT%'); $s.TargetPath = '%INSTALL_DIR%\%EXE_NAME%'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.Description = 'MetaScope - Media Metadata Extractor'; $s.Save()"

set "STARTMENU=%PROGRAMDATA%\Microsoft\Windows\Start Menu\Programs\MetaScope"
if not exist "%STARTMENU%" mkdir "%STARTMENU%"
copy /y "%SHORTCUT%" "%STARTMENU%\" >nul

echo.
echo ================================================
echo         INSTALLATION COMPLETE!
echo ================================================
echo.
echo [+] Installed to: %INSTALL_DIR%
echo [+] Added to system PATH
echo.
echo IMPORTANT: Close THIS window and open a NEW terminal.
echo Then simply run: metascope
echo.
pause