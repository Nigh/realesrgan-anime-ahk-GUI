
SetWorkingDir(A_ScriptDir)
#SingleInstance force
#include meta.ahk
;@Ahk2Exe-SetName %appName%
;@Ahk2Exe-SetVersion %version%
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %appName%

#include prod.ahk

#include update.ahk
setTray()
OnExit(trueExit)

#Include webview\WebViewToo.ahk

DirCreate(A_Temp "\CYKSM\models_realesrgan")
FileInstall(".\bin\realesrgan-ncnn-vulkan.exe", A_Temp "\CYKSM\rn-vulkan.exe", 1)
FileInstall(".\bin\vcomp140.dll", A_Temp "\CYKSM\vcomp140.dll", 1)
FileInstall(".\bin\vcomp140d.dll", A_Temp "\CYKSM\vcomp140d.dll", 1)
FileInstall(".\bin\models_realesrgan\realesrgan-x4plus-anime.bin", A_Temp "\CYKSM\models_realesrgan\realesrgan-x4plus-anime.bin", 1)
FileInstall(".\bin\models_realesrgan\realesrgan-x4plus-anime.param", A_Temp "\CYKSM\models_realesrgan\realesrgan-x4plus-anime.param", 1)

#include Gdip_All.ahk
pGDI := Gdip_Startup()

#include anime4x.ahk

scriptBusy := false

WebViewSettings := {}
if (A_IsCompiled) {
	WebViewCtrl.CreateFileFromResource("64bit\WebView2Loader.dll", WebViewCtrl.TempDir)
    WebViewSettings := {DllPath: WebViewCtrl.TempDir "\64bit\WebView2Loader.dll"}
}

MyGui := WebViewGui("+Resize +MinSize800x600",,, WebViewSettings)
MyGui.OnEvent("Close", mygui_Close)

MyGui.AddCallbackToScript("Visit", WebviewVisit)
MyGui.AddCallbackToScript("anime4x", Anime4xRun)
MyGui.AddCallbackToScript("animePolish", AnimePolishRun)

if(A_IsCompiled) {
	MyGui.Navigate("index.html")
} else {
	MyGui.Navigate("http://localhost:5173")
	MyGui.Debug()
}
MyGui.Show("w820 h600")
Return

pushMsg(type, code, content:="") {
	MyGui.PostWebMessageAsJson('{"type":"' type '","code":' code ',"content":"' content '"}')
}

AnimePolishRun(webview, base64) {

}
Anime4xRun(webview, base64) {
	if(scriptBusy) {
		pushMsg("state", 2)
		Return
	}
	worker(*) {
		if FileExist(A_Temp '\CYKSM\temp_input.png') {
			FileDelete(A_Temp '\CYKSM\temp_input.png')
		}
		if FileExist(A_Temp '\CYKSM\temp_output.png') {
			FileDelete(A_Temp '\CYKSM\temp_output.png')
		}
		
		base64 := RegExReplace(base64, "(?i)^.*?base64,")
		pBitmap := Gdip_BitmapFromBase64(&base64)
		input_error := Gdip_SaveBitmapToFile(pBitmap, A_Temp '\CYKSM\temp_input.png')
		if(input_error < 0) {
			pushMsg("error", input_error, "GDIp save bitmap to file failed")
			return
		}
		
		anime4x.inputpath(A_Temp '\CYKSM\temp_input.png')
		anime4x.outputpath(A_Temp '\CYKSM\temp_output.png')
		pushMsg("state", 1)
		global scriptBusy := true
		result := anime4x.go()
		scriptBusy := false
		if(result == 0) {
			pushMsg("result", result, anime4x.output_base64)
		} else {
			pushMsg("error", result, "realesrgan error")
		}
	}
	SetTimer(worker, -1)
}

WebviewVisit(webview, msg) {
	Run(msg)
}

mygui_Close(*) {
	trueExit(0, 0)
}
trueExit(ExitReason, ExitCode){
	ExitApp
}

; ===============================================================
; ===============================================================

#include tray.ahk

#Include *i resource.ahk

;@Ahk2Exe-IgnoreBegin
; For dev
F6::ExitApp(5173)
;@Ahk2Exe-IgnoreEnd
