#Persistent
#SingleInstance, force

OnMessage(0x201, "WM_LBUTTONDOWN")

; ahk_class SunAwtFrame
displayGui("-")
return

inputHandler(input) {
	static count
	If !(count)
		count := 0
	
	If (input = "add") {
		count++
		displayGui(count)
	}
	
	If (input = "reset") {
		count := 0
		displayGui("-")
	}

}

displayGui(input) {
	If !(input)
		return
	
	_client := WinExist("ahk_class SunAwtFrame")
	
	If !WinExist("guiDisplay") {
		; properties
		gui display: new
		gui display: +hwnd_guiDisplay
		gui display: +labelguiDisplay_
		gui display: +Owner%_client%
		gui display: +LastFound -caption
		gui display: margin, 10, 10
		
		Gui display: Color, Green
		WinSet, Transparent, 200
		
		; controls
		gui display: font, verdana s18
		gui display: add, text, w30 h30 Center, -
		gui display: font
		
		; show
		gui display: show, hide, guiDisplay
		
		DetectHiddenWindows, On
		WinGetPos, clientX, clientY, clientW, clientH, ahk_class SunAwtFrame
		ControlGetPos, osrsX, osrsY, osrsW, osrsH, , ahk_class SunAwtFrame
		WinGetPos, guiDisplayX, guiDisplayY, guiDisplayW, guiDisplayH, guiDisplay
		
		gui display: show, % " x" clientX + osrsX + osrsW - guiDisplayW " y" clientY + osrsY, guiDisplay
		return
	}
	
	If (input) {
		ControlSetText, Static1, % input, guiDisplay
		return
	}
	
	guiDisplay_ContextMenu:
		menu, rightClickMenu, add
		menu, rightClickMenu, DeleteAll
		
		menu, rightClickMenu, add, Reset, guiDisplay_Reset
		
		menu, rightClickMenu, show
	return
	
	guiDisplay_Reset:
		inputHandler("reset")
	return
}

WM_LBUTTONDOWN() {
	inputHandler("add")
}


#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive
