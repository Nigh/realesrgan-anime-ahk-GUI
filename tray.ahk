

gotoWebpage_maker(page)
{
	webpage(*){
		Run(page)
	}
	return webpage
}

setTray()
{
	global version
	trayExit(*){
		trueExit("","")
	}
	tray := A_TrayMenu
	tray.delete
	tray.add("v" . version, (*)=>{})
	tray.add()
	tray.add("Github 页面", gotoWebpage_maker("https://github.com/Nigh/realesrgan-anime-ahk-GUI"))
	tray.add("Donate 捐助", gotoWebpage_maker("https://ko-fi.com/xianii"))
	tray.add("Exit", trayExit)
	tray.ClickCount := 1
}
