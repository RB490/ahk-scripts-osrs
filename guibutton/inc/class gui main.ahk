class class_mainGuiClass extends gui {
    Setup() {
        ; events
        this.Events["Close"] := this.Close.Bind(this)
        this.Events["_Btn+"] := this.AlwaysOntop.Bind(this)
        this.Events["_Btn-"] := this.Minimize.Bind(this)
        this.Events["_BtnX"] := this.Close.Bind(this)
        this.Events["_BtnDigits"] := this.SetTarget.Bind(this)
        ; this.Events["_BtnStart"] := this.Start.Bind(this)
        this.Events["_BtnPgUp"] := this.MainButton.Bind(this)
        
        ; properties
        this.Margin(5, 5)
        this.Options("-border")
        this.Options("+LabelmainGui_")

        ; controls
        this.Font("s1")
        this.Add("Text", "x0 y0 w65 h23 Border Center cSilver gmainGui_BtnHandler")
        this.Font("")
        
        this.Add("Text", "x4 y4 w60 BackGroundTrans", "Button")
        this.Add("Button", "x68 y0 h23 w23 gmainGui_BtnHandler", "+")
        this.Add("Button", "x94 y0 h23 w23 gmainGui_BtnHandler", "-")
        this.Add("Button", "x120 y0 h23 w23 gmainGui_BtnHandler", "X")


        ; this.Font("s25")
        ; this.Add("Text", "x5 w135 Center gmainGui_BtnHandler", "00:00:00")
        ; this.Font("")
        
        ; this.Add("Button", "x5 w65 gmainGui_BtnHandler", "Start")
        this.Add("Button", "x+5 w130 gmainGui_BtnHandler", "PgUp")

        ; show
        If (g_debug)
            this.Pos(1640, 5)
        this.Pos(1627, 496)
        this.Show()
        this.AlwaysOnTop()
        return
    }

    MoveGui() { ; wm_mousemove event is used since this method was causing issues
        msgbox % A_ThisFunc
        PostMessage, 0xA1, 2,,, A
    }

    AlwaysOnTop() {
        WinSet, AlwaysOnTop, Toggle, % "ahk_id " this.hwnd
    }

    Minimize() {
        WinMinimize, % "ahk_id " this.hwnd
    }

    Start() {
    }

    MainButton() {
        WinActivate, ahk_exe RuneLite.exe
        Send {PgUp}
    }

    Stop() {
    }

    Close() {
        exitapp
    }
}

mainGui_BtnHandler:
    ; ignore 'menu bar'
    control := getMouseControl()
    if InStr(control, "Static1") or InStr(control, "Static2")
        return

    OutputControlText := getMouseControl("retrieveControlText")

    If InStr(OutputControlText, ":") ; handle the ever changing digit text control
        OutputControlText := "Digits"
    
    ; msgbox % A_ThisLabel ": _Btn" OutputControlText ; debug - view called method

    ; call the class's method
    for a, b in class_mainGuiClass.Instances 
		if (a = A_Gui+0)
			b["Events"]["_Btn" OutputControlText].Call()
return
