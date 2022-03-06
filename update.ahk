
#include meta.ahk

if FileExist("updater.exe")
{
	FileDelete("updater.exe")
}

lastUpdate:=IniRead("setting.ini", "update", "last", 0)
autoUpdate:=IniRead("setting.ini", "update", "autoupdate", 1)
updateMirror:=IniRead("setting.ini", "update", "mirror", 1)
IniWrite(updateMirror, "setting.ini", "update", "mirror")
mirrorList:=[
	"https://github.com",
	"https://ghproxy.com/https://github.com",
	"https://download.fastgit.org",
	"https://github.com.cnpmjs.org",
]
updatemirrorTried:=Array()
today:=A_MM . A_DD
if(autoUpdate) {
	if(lastUpdate!=today) {
		get_latest_version()
	} else {
		version_str:=IniRead("setting.ini", "update", "ver", "0")
		if(version_str!=version) {
			IniWrite(version, "setting.ini", "update", "ver")
			MsgBox(version . "`nUpdate log`n`n" . update_log)
		}
	}
} else {
	TrayTip "Update Skiped`n`nCurrent version`nv" version,"Update", 1
}

updateTimeout(*)
{
	tryNextUpdate()
	Return
}

get_latest_version(){
	global
	req := ComObject("MSXML2.ServerXMLHTTP")
	updateMirror:=IsNumber(updateMirror)?updateMirror+0:1
	if(updateMirror > mirrorList.Length or updateMirror <= 0) {
		updateMirror := 1
	}
	updateSite:=mirrorList[updateMirror]
	; MsgBox("GET:" . mirrorList[updateMirror] . downloadUrl . versionFilename)
	updateReqDone:=0
	req.open("GET", mirrorList[updateMirror] . downloadUrl . versionFilename, true)
	req.onreadystatechange := updateReady
	req.send()
	SetTimer(updateTimeout, -10000)
	Return

}

tryNextUpdate()
{
	global mirrorList, updateMirror, updatemirrorTried
	SetTimer(updateTimeout, 0)
	updatemirrorTried.Push(updateMirror)
	For k, v in mirrorList
	{
		local tested
		tested:=False
		for , p in updatemirrorTried
		{
			if(p=k) {
				tested:=True
				break
			}
		}
		if not tested {
			updateMirror:=k
			get_latest_version()
			Return
		}
	}
	TrayTip "Status=" req.status, "update failed", 0x3
}
; with MSXML2.ServerXMLHTTP method, there would be multiple callback called

updateReady(){
	global req, version, updateReqDone, downloadUrl, downloadFilename, mirrorList, updateMirror, updatemirrorTried
	; log("update req.readyState=" req.readyState, 1)
    if(req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		; log("state already changed", 1)
		Return
	}
	updateReqDone := 1
	; log("update req.status=" req.status, 1)
    if(req.status == 200 and StrLen(req.responseText)<=64){ ; OK.
		SetTimer(updateTimeout, 0)
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", &verNow)
		RegExMatch(req.responseText, "^(\d+)\.(\d+)\.(\d+)$", &verNew)
		if((verNew[1]>verNow[1])
		|| (verNew[1]==verNow[1] && ((verNew[2]>verNow[2])
			|| (verNew[2]==verNow[2] && verNew[3]>verNow[3])))){
			result:=MsgBox("Found new version " . req.responseText . ", download?", "Download", 0x2024)
			if result = "Yes"
			{
				try {
					Download(mirrorList[updateMirror] . downloadUrl . downloadFilename, "./" . downloadFilename)
					MsgBox("Download finished`nProgram will restart now",, "T3")
					todayUpdated()
					FileInstall("updater.exe", "updater.exe", 1)
					Run("updater.exe")
					ExitApp
				} catch as e {
					TrayTip "An exception was thrown!`nSpecifically: " . e.Message, "upgrade failed", 0x3
				}
			}
		} else {
			todayUpdated()
		}
	} else {
		tryNextUpdate()
	}
}

todayUpdated(){
	IniWrite(A_MM . A_DD, "setting.ini", "update", "last")
}
