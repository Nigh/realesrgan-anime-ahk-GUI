
#Requires AutoHotkey v2.0 64-bit
SetWorkingDir(A_ScriptDir)
#SingleInstance force

f := FileOpen("resource.ahk", "w")
f.Write(";@Ahk2Exe-AddResource webview\64bit\WebView2Loader.dll, 64bit\WebView2Loader.dll`n")

Loop Files, "dist\*.*", "FR" {
	resPath := RegExReplace(A_LoopFilePath, "^dist\\", "")
	f.Write(";@Ahk2Exe-AddResource " A_LoopFilePath ", " resPath "`n")
}
