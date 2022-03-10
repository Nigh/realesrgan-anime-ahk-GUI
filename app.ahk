
SetWorkingDir(A_ScriptDir)
#SingleInstance force
#include meta.ahk
;@Ahk2Exe-SetName %appName%
;@Ahk2Exe-SetVersion %version%
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %appName%

#include prod.ahk

; if you need admin privilege, enable it.
if(0)
{
	UAC()
}
#include update.ahk
setTray()
OnExit(trueExit)

; ===============================================================
; ===============================================================
; your code below
DirCreate(A_Temp "\CYKSM\models_realesrgan")
FileInstall(".\realesrgan-ncnn-vulkan.exe", A_Temp "\CYKSM\rn-vulkan.exe", 1)
FileInstall(".\vcomp140.dll", A_Temp "\CYKSM\vcomp140.dll", 1)
FileInstall(".\vcomp140d.dll", A_Temp "\CYKSM\vcomp140d.dll", 1)
FileInstall(".\models_realesrgan\realesrgan-x4plus-anime.bin", A_Temp "\CYKSM\models_realesrgan\realesrgan-x4plus-anime.bin", 1)
FileInstall(".\models_realesrgan\realesrgan-x4plus-anime.param", A_Temp "\CYKSM\models_realesrgan\realesrgan-x4plus-anime.param", 1)

MonitorGet(1, &Left, &Top, &Right, &Bottom)
Screen_Height:=Bottom-Top
Screen_Width:=Right-Left

#include Gdip_All.ahk
pGDI := Gdip_Startup()

Class anime4x
{
	static state := 0
	static afterfunc := ""
	static callbackfunc := ""
	static inputfile := ""
	static outputfile := ""
	static input_bitmap := ""
	static output_bitmap := ""

	static inputpath(inputfile) {
		this.inputfile := inputfile
		this.input_bitmap:=Gdip_CreateBitmapFromFile(this.inputfile)
		Return this.input_bitmap
	}
	static outputpath(outputfile) {
		this.outputfile := outputfile
	}


	static after(func) {
		this.afterfunc := func
	}

	static callback(func) {
		this.callbackfunc := func
	}

	static go() {
		this.state := 1
		SetTimer(this.callbackfunc, 150)
		RunWait(A_Temp "\CYKSM\rn-vulkan.exe -i " this.inputfile " -o " this.outputfile " -n realesrgan-x4plus-anime -m models_realesrgan",,"Hide")
		SetTimer(this.callbackfunc, 0)
		this.state := 0
		this.output_bitmap:=Gdip_CreateBitmapFromFile(this.outputfile)
		SetTimer(this.afterfunc, -1)
	}
}


mygui:=Gui("-AlwaysOnTop -Owner")
myGui.OnEvent("DropFiles", mygui_DropFiles)
mygui.SetFont("s32 Q5", "Meiryo")
mygui.Add("Text","x20 y10 Section","次元克赛马")
mygui.SetFont("s10 Q5", "Meiryo")
mygui.Add("Text","x+20 y+-52","v" . version)
mygui.Add("Link","xp y+0",'bilibili: <a href="https://space.bilibili.com/895523">下限Nico</a>')
mygui.Add("Link","xp y+0",'GitHub: <a href="https://github.com/Nigh">xianii</a>')
mygui.Add("Text","x50 yp","二次元反向马赛克工具")

ori_pic:=mygui.Add("Picture", "x20 w400 h400 0xE 0x200 0x800000 -0x40")
new_pic:=mygui.Add("Picture", "x+10 w400 h400 0xE 0x200 0x800000 -0x40")
runBtn:=mygui.Add("Button", "x20 y+10 w810 r3 Disabled", "转换")
runBtn.OnEvent("Click", generate)

generate(btn, *) {
	btn.Enabled:=false
	btn.Text := "转换中"
	ends(){
		global new_pic, ori_pic
		btn.Text:="转换"
		mygui_ctrl_show_pic(new_pic, anime4x.output_bitmap)
		btn.gui.Opt("+OwnDialogs")
		MsgBox("转换完成，已保存在桌面")
	}
	proc() {
		if(StrLen(btn.Text)<19) {
			btn.Text:="< " btn.Text " >"
		} else {
			btn.Text:="转换中"
		}
	}
	anime4x.callback(proc)
	anime4x.after(ends)
	anime4x.go()
}

mygui.Show("AutoSize")

Return

mygui_set_pic_size(picW, picH)
{
	global Screen_Width, Screen_Height, ori_pic, new_pic, runBtn
	minW:=400
	minH:=400
	maxW:=0.4*Screen_Width
	maxH:=0.6*Screen_Height

	percentW:=maxW/picW
	percentH:=maxH/picH
	percentMin:=Min(percentW, percentH)

	if(percentMin<1) {
		ctrlW:=picW*percentMin<400 ? 400:picW*percentMin
		ctrlH:=picH*percentMin<400 ? 400:picH*percentMin
		percent:=percentMin
	} else {
		ctrlW:=picW<400 ? 400:picW
		ctrlH:=picH<400 ? 400:picH
		percent:=1
	}
	ori_pic.Move(20, , ctrlW, ctrlH)
	new_pic.Move(20+20+ctrlW, , ctrlW, ctrlH)
	ori_pic.GetPos(,&y)
	runBtn.Move(20, y+ctrlH+10, 2*ctrlW+10)
	new_pic.gui.Show("AutoSize")
	new_pic.Redraw()
	ori_pic.Redraw()
	Return percent
}

mygui_ctrl_show_pic(GuiCtrlObj, pBitmap)
{
	Gdip_GetImageDimensions(pBitmap, &W, &H)
	percent := mygui_set_pic_size(W, H)
	picW:=W*percent
	picH:=H*percent
	GuiCtrlObj.GetPos(,, &ctrlW, &ctrlH)
	pBitmapShow := Gdip_CreateBitmap(picW, picH)
	G := Gdip_GraphicsFromImage(pBitmapShow)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap, 0, 0, picW, picH)
	hBitmapShow := Gdip_CreateHBITMAPFromBitmap(pBitmapShow)
	SetImage(GuiCtrlObj.hwnd, hBitmapShow)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapShow), DeleteObject(hBitmapShow)
}

mygui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y) {
	global ori_pic, new_pic, runBtn
	GuiObj.Opt("+OwnDialogs")
	if(FileArray.Length>1) {
		MsgBox "一次只能拖进一个文件哦"
		Return
	}
	SplitPath(FileArray[1],,,&Ext)
	if(anime4x.inputpath(FileArray[1])<=0||!InStr("jpgjpegpng",Ext,0)) {
		MsgBox "无效的图片文件"
	} else {
		runBtn.Enabled:=True
		mygui_ctrl_show_pic(ori_pic ,anime4x.input_bitmap)
		SetImage(new_pic.hwnd, 0)
		
		SplitPath(FileArray[1],,,,&name)
		anime4x.outputpath(A_Desktop "\" name "_4x.png")
	}
}

GuiClose:
ExitApp
trueExit(ExitReason, ExitCode){
	global pGDI
	Gdip_Shutdown(pGDI)
	ExitApp
}

; ===============================================================
; ===============================================================

UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")

	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
		try
		{
			if A_IsCompiled
				Run '*RunAs "' A_ScriptFullPath '" /restart'
			else
				Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
		}
		ExitApp
	}
}
#include tray.ahk
