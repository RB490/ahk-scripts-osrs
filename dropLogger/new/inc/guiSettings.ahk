guiSettings() {
	static _autoOpenStatsCheckbox, _lastItemDatabaseUpdateDisplay, _lastMobListUpdateDisplay
	
	autoOpenStats := ini_getValue(ini, "Settings", "autoOpenStats")
	guiSettingsX := ini_getValue(ini, "Window Positions", "guiSettingsX")
	guiSettingsY := ini_getValue(ini, "Window Positions", "guiSettingsY")
	
	; properties
	Gui settings: New, +LastFound
	Gui settings: Margin, 5, 5
	Gui settings: +LabelguiSettings_
	
	; controls
	Gui settings: Add, Button, w150 gguiSettings_updateItemDatabase, Update item database
	If (ini_getValue(ini, "General", "lastItemDatabaseUpdate"))
		FormatTime, lastItemDatabaseUpdate_formatted, % ini_getValue(ini, "General", "lastItemDatabaseUpdate"), dd/MM/yyyy @ HH:mm:ss
	Gui settings: Add, Text, x+5 yp+5 w190 hwnd_lastItemDatabaseUpdateDisplay, % "Last updated: " lastItemDatabaseUpdate_formatted
	
	Gui settings: Add, Button, xs w150 gguiSettings_updatemobList, Update mob list
	If (ini_getValue(ini, "General", "lastMobListUpdate"))
		FormatTime, lastmobListUpdate_formatted, % ini_getValue(ini, "General", "lastMobListUpdate"), dd/MM/yyyy @ HH:mm:ss
	Gui settings: Add, Text, x+5 yp+5 w190 hwnd_lastmobListUpdateDisplay, % "Last updated: " lastmobListUpdate_formatted
	
	Gui settings: Add, Button, xs w150 gguiSettings_resetLog, Reset log
	
	Gui settings: Add, Checkbox, x+5 yp+5 checked%autoOpenStats% hwnd_autoOpenStatsCheckbox, Automatically open stats gui
	
	Gui settings: Add, Button, xs w350 gguiSettings_save, Save
	
	; show
	If (guiSettingsX) and (guiSettingsY)
		Gui settings: show, % "x" guiSettingsX " y" guiSettingsY " AutoSize", Drop Logger Settings
	else
		Gui settings: show, AutoSize, Drop Logger Settings
	
	; close
	WinWaitClose, Drop Logger Settings
	return
	
	guiSettings_updateItemDatabase:
		Gui settings: +Disabled
		updateItemDatabase()
		Gui settings: -Disabled
		
		FormatTime, lastItemDatabaseUpdate_formatted, % ini_getValue(ini, "General", "lastItemDatabaseUpdate"), dd/MM/yyyy @ HH:mm:ss
		GuiControl settings: , % _lastItemDatabaseUpdateDisplay, % "Last updated: " lastItemDatabaseUpdate_formatted
	return
	
	guiSettings_updateMobList:
		Gui settings: +Disabled
		updateMobList()
		Gui settings: -Disabled
		
		FormatTime, lastMobListUpdate_formatted, % ini_getValue(ini, "General", "lastMobListUpdate"), dd/MM/yyyy @ HH:mm:ss
		GuiControl settings: , % _lastMobListUpdateDisplay, % "Last updated: " lastMobListUpdate_formatted
	return
	
	guiSettings_save:
		ControlGet, autoOpenStats, Checked, , , % "ahk_id " _autoOpenStatsCheckbox
		ini_replaceValue(ini, "Settings", "autoOpenStats", autoOpenStats)
		
		Gosub guiSettings_close
	return
	
	guiSettings_resetLog:
		gui settings: +OwnDialogs
		msgbox, 52, , All log entries will be deleted!`n`nThis cannot be undone.`n`nAre you sure?
		IfMsgBox, No
			return
		FileDelete, % g_logFile
		FileAppend, , % g_logFile
		g_log := ""
	return
	
	guiSettings_close:
		WinGetPos, guiSettingsX, guiSettingsY, , , Drop Logger Settings
		ini_replaceValue(ini, "Window Positions", "guiSettingsX", guiSettingsX)
		ini_replaceValue(ini, "Window Positions", "guiSettingsY", guiSettingsY)
		Gui settings: Destroy
	return
}