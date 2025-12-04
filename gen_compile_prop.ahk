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
	props.WriteLine(";@Ahk2Exe-SetDescription " appName)
	props.WriteLine(";@Ahk2Exe-ExeName " appName)
	props.Close()
}
catch as e
{
	MsgBox("Writting compile props`nERROR CODE=" . e.Message)
	ExitApp(1)
}
