; 32bit java needs to be installed for rs to load in browser instead of prompting for the game client to be installed
#Persistent
#SingleInstance, off
OnExit, shutdownRoutine

menu, tray, NoStandard
menu, tray, add, Settings, openSettings
menu, tray, add

If (A_IsCompiled = 1)
	menu, tray, add, Exit, closeScript
else
	menu, tray, Standard

Gosub loadSettings

guiClient(url)
return

openSettings:
	guiSettings()
return

closeScript:
	WinGetPos(_guiClient, guiClientX, guiClientY, guiClientW, guiClientH, 1)
	Gosub saveSettings
	exitapp
return

loadSettings:
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
		Gosub writeIni

	iniWrapper_loadSection(ini, "Settings")
return

saveSettings:
	iniWrapper_saveSection(ini, "Settings")
	ini_save(ini)
return

shutdownRoutine:
	Gosub saveSettings
	exitapp
return

enterAccountDetails:
	SendInput % account
	Send {tab}
	SendInput % password
return

writeIni:
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "urlList=" . "www.oldschool.runescape.com/game?world=349|runescape.com/game")
		ini_insertKey(ini, "Settings", "url=" . "www.oldschool.runescape.com/game?world=349")
		ini_insertKey(ini, "Settings", "selectedPreset=" . "Default")
		ini_insertKey(ini, "Settings", "borderless=" . 0)
		ini_insertKey(ini, "Settings", "resizable=" . 1)
		ini_insertKey(ini, "Settings", "hideAd=" . 0)
		ini_insertKey(ini, "Settings", "account=")
		ini_insertKey(ini, "Settings", "password=")
		ini_insertKey(ini, "Settings", "hotkey_login=" . "^+f1")
	
		ini_insertKey(ini, "Settings", "guiClientX=" . 10)
		ini_insertKey(ini, "Settings", "guiClientY=" . 10)
		ini_insertKey(ini, "Settings", "guiClientW=" . 767)
		ini_insertKey(ini, "Settings", "guiClientH=" . 505)
	
	ini_save(ini)
	ini_load(ini, iniFile)
return

guiSettings() {
	global
	
	; properties
	gui settings: default
	gui settings: margin, 5, 5
	gui settings: +LabelguiSettings_ +Hwnd_guiSettings
	
	; controls
	gui settings: add, text, x5, Url
	gui settings: add, combobox, w300 vurl, % urlList
	GuiControl settings: ChooseString, url, % url
	gui settings: add, text, , Account
	gui settings: add, edit, w300 r1 -vscroll -hscroll -wrap -multi vaccount, % account
	gui settings: add, text, , Password
	gui settings: add, edit, w300 r1 -vscroll -hscroll -wrap -multi vpassword, % password
	gui settings: add, text, , Login Hotkey
	gui settings: add, hotkey, x+5 vhotkey_login, % hotkey_login
	
	gui settings: add, checkbox, x5 checked%borderless% vBorderless, Borderless
	gui settings: add, checkbox, checked%resizable% vresizable, Resizable
	gui settings: add, checkbox, checked%hideAd% vhideAd, Hide Ad
	
	gui settings: add, button, w300 gguiSettings_buttonSave, Save
	
	; show
	gui settings: show, x0 y0
	
	; close
	WinWaitClose, % "ahk_id " _guiSettings
	gui settings: Destroy
	return
	
	guiSettings_loadPreset:
		gui settings: submit, NoHide
		
		iniWrapper_loadSection(ini, "preset_" selectedPreset)
	return
	
	guiSettings_deletePreset:
		gui settings: submit, nohide
		
		msgbox, 68, , Are you sure you want to delete this preset?
		IfMsgBox, No
			return
		
		If (selectedPreset = "Default")
		{
			msgbox Cannot remove default preset
			return
		}
		
		ini_replaceSection(ini, "preset_" selectedPreset)
		selectedPreset := "Default"
		gui settings: Destroy
		guiSettings()
	return
	
	guiSettings_buttonSave:
		gui settings: submit
		
		If !InStr(urlList, url)
			urlList .= "|" url
		
		Gosub saveSettings

		reload
	return
}

guiClient(url) {
	global

	; properties
	Gui client: Default
	Gui client: Margin, 0, 0 
	Gui client: +LabelguiClient_ +Hwnd_guiClient +LastFound
	
	If (resizable = 1)
		Gui client: +Resize
		
	If (borderless = 1)
		gui client: -caption
	
	; controls
	Gui client: Add, ActiveX,vWB, Shell.Explorer2
	WB.silent := 1 ; hide errors
	ComObjConnect(WB, WB_events)  ; Connect WB's events to the WB_events class object.	
	
	If (hideAd = 1)
	{
		ad := 147
		GuiControl, Move, WB, % " y" - ad " w" guiClientW " h" guiClientH + ad
	}
	else
	{
		ad := 27
		GuiControl, Move, WB, % " y" - ad " w" guiClientW " h" guiClientH + ad
	}
	
	; show
	If (guiClientW = 0)
		Gui client: Show, % " x" guiClientX " y" guiClientY " AutoSize", Client
	else
		Gui client: Show, % " x" guiClientX " y" guiClientY " w" guiClientW " h" guiClientH, Client
		; Gui client: Show, % " x" guiClientX " y" guiClientY " w" 1000 " h" 1000, Client
	
	If !(url = "")
		WB.Navigate(url)
		; WB.Navigate("tweakers.net")
	
	; hotkeys
	If !(hotkey_login = "")
	{
		hotkey, IfWinActive, % "ahk_id " _guiClient
		hotkey, % hotkey_login, enterAccountDetails
	}
	
	; close
	WinWaitClose, % "ahk_id " _guiClient
	exitapp
	return
	
	; labels
	guiClient_Close:
		WinGetPos(_guiClient, guiClientX, guiClientY, guiClientW, guiClientH, 1)
		gui client: Destroy
	return
	
	guiClient_size:
		WinGetPos(_guiClient, guiClientX, guiClientY, guiClientW, guiClientH, 1)
		If (hideAd = 1)
			GuiControl, Move, WB, % " y" - ad " w" guiClientW " h" guiClientH + ad
		else
			GuiControl, Move, WB, % " y" - ad " w" guiClientW " h" guiClientH + ad
	return
}


#IfWinActive, ahk_class Notepad++
~^s::
	If (A_IsCompiled = 1)
		return

	reload
return
#IfWinActive
