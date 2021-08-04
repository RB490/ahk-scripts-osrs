; misc
    #SingleInstance Off
    OnMessage(0x201, "WM_LBUTTONDOWN") ; WM_LBUTTONDOWN := 0x201 
    OnMessage(0x204, "WM_RBUTTONDOWN") ; WM_RBUTTONDOWN := 0x204 
    OnMessage(0x111, "WM_COMMAND") ; WM_COMMAND := 0x111 detect edit field losing focus
    If (A_IsCompiled) {
        Menu, Tray, NoStandard ; remove default compiled tray menu
        Menu, Tray, Add, Reload, btnReloadScript ; remove default compiled tray menu
        Menu, Tray, Add, Exit, btnExitScript ; remove default compiled tray menu
    }

; global vars
    global mainGui := new class_mainGuiClass("gui button script")
    global g_debug := false

; autoexec
    If (g_debug) {
        Gosub debug
        return
    }
    mainGui.Setup() ; show main gui
    WinWaitClose, % mainGui.ahkid ; if gui gets closed from alt+tab menu, 'GuiClose' label is not triggered
    exitapp
return

; menu buttons
    dummyHandler:
    return

    btnExitScript:
        exitapp
    return

    btnReloadScript:
        reload
    return

; global hotkeys
    #If !(A_IsCompiled)
    ~^s::reload
    #If

; includes
    #Include, <class gui>
    #Include, %A_ScriptDir%\inc
    #Include, class gui main.ahk
    #Include, functions.ahk
    #Include, subroutines.ahk