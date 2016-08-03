#SingleInstance, force

guiBrowser("http://crystalmathlabs.com/tracker/update.php?player=hersen")
guiBrowser("http://crystalmathlabs.com/tracker/update.php?player=hersens")
return

guiBrowser(url) {
	global

	DetectHiddenWindows, On
	
	IfWinExist, % "ahk_id " _guiBrowser
		ie.quit
	
	ie := ComObjCreate("InternetExplorer.Application")

	ie.Visible := false  ; This is known to work incorrectly on IE7.

	ie.ToolBar := false
	ie.Silent := false
	ie.width := 500 ; A_ScreenWidth - 100
	ie.height := 500 ; A_ScreenHeight - 100
	
	_guiBrowser := ie.hwnd

	ie.Navigate(url)
	
	loop,
	{
		If !(ie.busy = 0) ; done loading
			break
		sleep 100
	}
			
	sleep 100
	
	ie.quit
}