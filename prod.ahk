
;@Ahk2Exe-IgnoreBegin
if A_Args.Length > 0
{
	for n, param in A_Args
	{
		RegExMatch(param, "--out=(\w+)", &outName)
		if(outName[1]=="version") {
			f := FileOpen(versionFilename,"w","UTF-8-RAW")
			f.Write(version)
			f.Close()
			ExitApp
		}
	}
}
_exit(ThisHotkey){
	ExitApp
}
_reload(ThisHotkey){
	Reload
}
Hotkey("F5", _exit)
Hotkey("F6", _reload)
;@Ahk2Exe-IgnoreEnd
