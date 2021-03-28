; source: https://github.com/Run1e/Columbus
Class Gui {
	static Instances := []
	static params := {Size:["A_GuiWidth", "A_GuiHeight"], DropFiles:["A_GuiEvent"]}
	
	__New(title := "AutoHotkey Window", options := "") {
		Gui, New, % "+hwndhwnd " options, % title
		this.hwnd := hwnd
		this.ahkid := "ahk_id" hwnd
		this.IsVisible := false
		this.Events := []
		Gui.Instances[hwnd] := this
	}
	
	__Delete() {
		this.Destroy()
	}
	
	SetDefault() {
		Gui % this.hwnd ":Default"
	}
	
	Owner(hwnd) {
		Gui % this.hwnd ":+Owner" hwnd
	}

	Disable() {
		Gui % this.hwnd ": +Disabled"
	}
	
	Enable() {
		Gui % this.hwnd ": -Disabled"
	}
	
	Destroy() {
		Gui % this.hwnd ":Destroy"
	}

	Options(options, ext := "") {
		Gui % this.hwnd ":" options, % ext
	}
	
	Show(options := "") {
		this.IsVisible := true
		Gui % this.hwnd ":Show", % options
	}
	
	Hide() {
		this.IsVisible := false
		Gui % this.hwnd ":Hide"
	}
	
	Toggle() {
		this[this.IsVisible ? "Hide" : "Show"]()
	}
	
	Pos(x := "", y := "", w := "", h := "") {
		this.IsVisible := true
		Gui % this.hwnd ":Show", % (x ? "x" x : "") 
							. (y ? " y" y : "") 
							. (w ? " w" w : "") 
							. (h ? " h" h : "")
	}
	
	Control(cmd := "", control := "", param := "") {
		GuiControl % this.hwnd ":" (cmd ? cmd : ""), % (control ? control : ""), % (param ? param : "")
		; set carret to end of edit
		If InStr(control, "Edit")
			ControlSend, % control, ^{end}, % this.ahkid
	}
	
	ControlGet(cmd, value := "", control := "") {
		ControlGet, out, % cmd, % (value ? value : ""), % (control ? control : ""), % this.ahkid
		return out
	}
	
	GuiControlGet(cmd := "", control := "", param := "") {
		GuiControlGet, out, % (cmd ? cmd : ""), % (control ? control : ""), % (param ? param : "")
		return out
	}
	
	Add(control, options := "", param := "") {
		if InStr(options, "hwnd")
			return m("HWNDS are returned!")
		Gui % this.hwnd ":Add", % control, % options " hwndcontrolhwnd", % param
		return controlhwnd
	}

	AddGlobal(control, options := "", param := "") {
		global
		if InStr(options, "hwnd")
			return m("HWNDS are returned!")
		Gui % this.hwnd ":Add", % control, % options " hwndcontrolhwnd", % param
		return controlhwnd
	}
	
	Font(font := "", type := "") {
		Gui % this.hwnd ":Font", % font, % type
	}
	
	Tab(num) {
		Gui % this.hwnd ":Tab", % num
	}
	
	Color(BG, FG) {
		Gui % this.hwnd ":Color", % BG, % FG
	}
	
	Margin(x, y) {
		Gui % this.hwnd ":Margin", % x, % y
	}
	
	GetText(control := "Edit1") {
		ControlGetText, text, % control, % this.ahkid
		return text
	}
	
	SetText(control := "Edit1", text := "") {
		this.Control(, control, text)
	}
	
	SelectText(control := "Edit1") {
		ControlFocus, % control, % this.ahkid

		ControlGet, _control, Hwnd, , % control, % this.ahkid

		ControlFocus,, ahk_id %_control%
        SendMessage, 177, 0, -1,, ahk_id %_control%
	}

	ControlFocus(control := "Edit1") {
		ControlFocus, % control, % this.ahkid
	}

	SetEvents(x) {
		for a, b in x
			this.Events[a] := b
	}
}

GuiSize:
GuiClose:
GuiEscape:
GuiDropFiles:
params := []
for a, b in Gui.Params[SubStr(A_ThisLabel, 4)]
	params.Insert(%b%)
for a, b in Gui.Instances 
	if (a = A_Gui+0) {
		if IsLabel(b["Events"][SubStr(A_ThisLabel, 4)])
			SetTimer, % b["Events"][SubStr(A_ThisLabel, 4)], -1
		else if A_ThisLabel.contains("escape", "close")
			Gui % a ":Destroy"
		else
			b["Events"][SubStr(A_ThisLabel, 4)].Call(params*)
	}
return

m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,0, % A_ScriptName, % list
}