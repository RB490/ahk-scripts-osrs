WM_LBUTTONDOWN() {
    ; ignore everything except the 'menu bar'
    control := getMouseControl()
    if !InStr(control, "Static1") and !InStr(control, "Static2")
        return

    PostMessage, 0xA1, 2,,, A
}

WM_RBUTTONDOWN() {
    control := getMouseControl()
    if !InStr(control, "Static1") and !InStr(control, "Static2")
        return

    InputBox, input, Set title, Please enter a new title , , 240, 130
    if (ErrorLevel)
        return ; CANCEL was pressed.

    mainGui.SetText("Static2", input) ; title bar
}

WM_COMMAND(wParam) { ; source: https://www.autohotkey.com/boards/viewtopic.php?t=57152
	NC := (wParam >> 16) & 0xFFFF ; NC= notification code
	if (NC = 0x0200) { ; if the message is "EN_KILLFOCUS = 0x200"
		setTargetGui.Hide() ; lost focus
	}
}

getMouseControl(getText := "") {
    MouseGetPos, , , , OutputVarControlClassNN, 0 ; get control classNN eg. Edit1
    
    If (getText) {
        ControlGetText, OutputControlText , % OutputVarControlClassNN, A ; retrieve control text
        output := StrReplace(OutputControlText, A_Space)
    }
    else
        output := OutputVarControlClassNN

    return output
}