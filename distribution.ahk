#SingleInstance Force
SetWorkingDir(A_ScriptDir)

#include meta.ahk

try
{
	props := FileOpen("compile_prop.ahk", "w")
	props.WriteLine(";@Ahk2Exe-SetName " appName)
	props.WriteLine(";@Ahk2Exe-SetVersion " version)
	props.WriteLine(";@Ahk2Exe-SetMainIcon icon.ico")
	props.WriteLine(";@Ahk2Exe-SetCompanyName HelloWorks")
	props.WriteLine(";@Ahk2Exe-SetDescription ahko")
	props.WriteLine(";@Ahk2Exe-ExeName " appName)
	props.Close()
}
catch as e
{
	MsgBox("Writting compile props`nERROR CODE=" . e.Message)
	ExitApp
}

if FileExist(binaryFilename)
{
	FileDelete(binaryFilename)
}

if FileExist(versionFilename)
{
	FileDelete(versionFilename)
}

if InStr(FileExist("dist"), "D")
{
	try
	{
		DirDelete("dist", 1)
	}
	catch as e
	{
		MsgBox("removing dist`nERROR CODE=" . e.Message)
		ExitApp
	}
}

DirCreate("dist")

try {
	RunWait("./ahk-compile-toolset/tcc/tcc.exe ./ahk-compile-toolset/updater.c -DdownloadFilename='`"" downloadFilename "`"' -DbinaryFilename='`"" binaryFilename "`"'")
} catch as e {
	MsgBox("updater compile`nERROR CODE=" . e.Message)
	ExitApp
}

try
{
	RunWait("./ahk-compile-toolset/ahk2exe.exe /in " ahkFilename " /out " binaryFilename " /base `"" A_AhkPath "`" /compress 1")
}
catch as e
{
	MsgBox(ahkFilename . "`nERROR CODE=" . e.Message)
	ExitApp
}

try
{
	RunWait("./ahk-compile-toolset/AutoHotkey64.exe .\" . ahkFilename . " --out=version")
}
catch as e
{
	MsgBox("get version`nERROR CODE=" . e.Message)
	ExitApp
}

try
{
	RunWait("powershell -command `"Compress-Archive -Path .\" binaryFilename " -DestinationPath " downloadFilename '"', , "Hide")
}
catch as e
{
	MsgBox("compress`nERROR CODE=" . e.Message)
	ExitApp
}
FileDelete(binaryFilename)
FileDelete("updater.exe")
FileMove(downloadFilename, "dist\" downloadFilename, 1)
FileMove(versionFilename, "dist\" versionFilename, 1)
MsgBox("Build Finished")
