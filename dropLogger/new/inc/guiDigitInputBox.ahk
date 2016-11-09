guiDigitInputBox(x, y, buttons = "") {
	DetectHiddenWindows, On
	If !WinExist("Digit Inputbox")
	{
		; properties
		gui inputbox: margin, 1, 1
		gui inputbox: +LabelguiInputbox_ -caption +AlwaysOnTop
		
		; controls
		gui inputbox: font, s15 verdana
		gui inputbox: add, edit, y9 w45 h45 r1 -VScroll -E0x200 Center Number
		gui inputbox: font
		
		If (buttons) {
			gui inputbox: add, button, w40 gguiInputbox_save, Ok
			gui inputbox: add, button, x+5 w40 gguiInputbox_close, Cancel
		}
	}
	ControlSetText, Edit1, , Digit Inputbox
	DetectHiddenWindows, Off
	
	; show
	gui inputbox: show, % " x" x " y" y " w45 h45", Digit Inputbox
	
	SetTimer, guiInputbox_hasFocusTimer, 10
	
	; hotkeys
	hotkey, IfWinActive, Digit Inputbox
	hotkey, enter, guiInputbox_save
	hotkey, IfWinActive
	
	; close
	WinWaitClose, Digit Inputbox
	return output
	
	guiInputbox_save:
		SetTimer, guiInputbox_hasFocusTimer, Off
		ControlGetText, output, Edit1, Digit Inputbox
		gui inputbox: hide
	return
	
	guiInputbox_hasFocusTimer:
		WinGetActiveTitle, activeWindow
		If !(activeWindow = "Digit InputBox")
			Gosub guiInputbox_close
	return
	
	guiInputbox_escape:
	guiInputbox_close:
		SetTimer, guiInputbox_hasFocusTimer, Off
		output := ""
		gui inputbox: hide
	return
}