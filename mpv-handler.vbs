' MPV Protocol Handler - Silent Launcher
' Zero window flash, pure Windows Script Host (wscript)

Option Explicit

Dim shell, fso, scriptDir, mpvPath, inputUrl, processedUrl

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Check mpv.exe: prioritize parent directory, then current directory
If fso.FileExists(fso.BuildPath(scriptDir, "..\mpv.exe")) Then
    mpvPath = fso.GetAbsolutePathName(fso.BuildPath(scriptDir, "..\mpv.exe"))
ElseIf fso.FileExists(fso.BuildPath(scriptDir, "mpv.exe")) Then
    mpvPath = fso.GetAbsolutePathName(fso.BuildPath(scriptDir, "mpv.exe"))
Else
    MsgBox "未找到 mpv.exe！请确认 mpv.exe 位于上一级目录或当前目录下。" & vbCrLf & "当前目录: " & scriptDir, vbCritical, "MPV Handler 错误"
    WScript.Quit 1
End If

If WScript.Arguments.Count = 0 Then WScript.Quit 1
inputUrl = WScript.Arguments(0)

processedUrl = ProcessUrl(inputUrl)

' 0 = hidden window, False = async run
shell.Run """" & mpvPath & """ """ & processedUrl & """", 0, False

Function ProcessUrl(url)
    Dim temp, p, webLinkPatterns
    temp = url

    ' Remove trailing slash
    If Right(temp, 1) = "/" Then temp = Left(temp, Len(temp) - 1)

    ' Support weblink format: mpv://weblink/?url=...
    webLinkPatterns = Array("mpv://weblink/?url=", "mpv://weblink?url=", _
                           "mpvplay://weblink/?url=", "mpvplay://weblink?url=")
    For Each p In webLinkPatterns
        If LCase(Left(temp, Len(p))) = LCase(p) Then
            temp = Mid(temp, Len(p) + 1)
            temp = UrlDecode(temp)
            ProcessUrl = temp
            Exit Function
        End If
    Next

    ' Remove mpv:// or mpvplay://
    If LCase(Left(temp, 6)) = "mpv://" Then
        temp = Mid(temp, 7)
    ElseIf LCase(Left(temp, 10)) = "mpvplay://" Then
        temp = Mid(temp, 11)
    End If

    ' Fix browser protocol format issue: http// or https//
    If LCase(Left(temp, 7)) = "https//" Then
        temp = "https://" & Mid(temp, 8)
    ElseIf LCase(Left(temp, 6)) = "http//" Then
        temp = "http://" & Mid(temp, 7)
    End If

    ' URL Decode
    temp = UrlDecode(temp)
    ProcessUrl = temp
End Function

Function UrlDecode(str)
    Dim i, c, h, result
    result = ""
    i = 1
    Do While i <= Len(str)
        c = Mid(str, i, 1)
        If c = "%" And i + 2 <= Len(str) Then
            h = Mid(str, i + 1, 2)
            On Error Resume Next
            result = result & Chr(CInt("&H" & h))
            If Err.Number <> 0 Then
                result = result & c
                Err.Clear
                On Error GoTo 0
                i = i + 1
            Else
                On Error GoTo 0
                i = i + 3
            End If
        ElseIf c = "+" Then
            result = result & " "
            i = i + 1
        Else
            result = result & c
            i = i + 1
        End If
    Loop
    UrlDecode = result
End Function