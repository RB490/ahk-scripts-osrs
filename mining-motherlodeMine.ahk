#Persistent
#SingleInstance, force
CoordMode, Mouse, Relative
SetBatchLines -1
SetKeyDelay -1

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x203, "WM_LBUTTONDBLCLK")

Gosub loadSettings
OnExit, exitRoutine

inventoryCount := 0

guiMotherlode()
return

loadSettings:
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		Gosub writeIni
		ini_load(ini, iniFile)
	}
	
	iniWrapper_loadAllSections(ini)
return

saveSettings:
	iniWrapper_saveAllSections(ini)
		
	ini_save(ini, iniFile)
return

writeIni:
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "guiMotherlodeX=" . "")
		ini_insertKey(ini, "Settings", "guiMotherlodeY=" . "")
	
	ini_save(ini)
return
exitRoutine:
	WinGetPos(_guiMotherlode, guiMotherlodeX, guiMotherlodeY)
	
	Gosub saveSettings
	
	exitapp
return

guiMotherlode(command := "") {
	global
	
	If !WinExist("ahk_id " _guiMotherlode)
	{
		; properties
		gui motherlode: +LastFound
		gui motherlode: margin, 5, 3
		gui motherlode: +hwnd_guiMotherlode +labelguiMotherlode_ -caption
		gui motherlode: +AlwaysOnTop
		
		; controls
		; gui motherlode: add, button, h25 w60 gmotherlodeBtnReset, Reset
		; gui motherlode: add, button, x+0 w25 h25 gmotherlodeBtnSubtract, -
		gui motherlode: font, s15 verdana
		gui motherlode: add, text, cWhite Center vinventoryCount, 00
		
		FormatTime, updateTime , % a_now, HH:mm:ss
		
		gui motherlode: add, text, x+5 cWhite Center vupdateTime, % updateTime
		gui motherlode: font
		
		; gui motherlode: add, button, x+0 w25 h25 gmotherlodeBtnAdd, +
		
		WinSet, Transparent, 100
		gui motherlode: color, 000000
		
		; show
		
		If !(guiMotherlodeX = "") and !(guiMotherlodeY = "")
			gui motherlode: show, % "x" guiMotherlodeX " y" guiMotherlodeY " AutoSize", Inv Count
		else
			gui motherlode: show, AutoSize, Inv Count
		
		; close
		WinWaitclose, % "ahk_id " _guiMotherlode
		return
	}
	If (command = "reset")
		Gosub motherlodeBtnReset
	If (command = "add")
		Gosub motherlodeBtnAdd
	
	return
	
	; labels
	motherlodeBtnAdd:
		gui motherlode: Submit, NoHide
		
		inventoryCount++
		Gosub motherlodeRefreshInventoryCount
	return
	
	motherlodeBtnSubtract:
		gui motherlode: Submit, NoHide
		
		inventoryCount--
		
		Gosub motherlodeRefreshInventoryCount
	return
	
	motherlodeBtnReset:
		inventoryCount := 0
		
		Gosub motherlodeRefreshInventoryCount
	return
	
	motherlodeRefreshInventoryCount:
		If (inventoryCount < 0)
			inventoryCount := 0
		
		GuiControl motherlode: , inventoryCount, % inventoryCount
		
		If (inventoryCount >= 3)
			gui motherlode: color, B0171F
		else
			gui motherlode: color, 000000
		
		FormatTime, updateTime , % a_now, HH:mm:ss
		GuiControl motherlode: , updateTime, % updateTime
	return
}


WM_LBUTTONDOWN() {
	guiMotherlode("add")
}

WM_LBUTTONDBLCLK() {
	guiMotherlode("reset")
}


#IfWinActive ahk_exe OSBuddy.exe
	j::
		click right
	return
	k::
		MouseMove, 0, 40, 0, R
	return
	l::
		click
	return

#IfWinActive

~f12::
	suspend
	SoundBeep
return

#IfWinActive, ahk_class Notepad++
~^s::reload
