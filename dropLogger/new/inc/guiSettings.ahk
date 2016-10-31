guiSettings() {
	static _autoOpenStatsCheckbox, _lastPriceUpdateDisplay
	
	autoOpenStats := ini_getValue(ini, "Settings", "autoOpenStats")
	guiSettingsX := ini_getValue(ini, "Window Positions", "guiSettingsX")
	guiSettingsY := ini_getValue(ini, "Window Positions", "guiSettingsY")
	
	; properties
	Gui settings: New, +LastFound
	Gui settings: Margin, 5, 5
	Gui settings: +LabelguiSettings_
	
	; controls
	Gui settings: Add, Checkbox, checked%autoOpenStats% hwnd_autoOpenStatsCheckbox, Show stats on startup
	
	Gui settings: Add, Button, xs gguiSettings_updatePrices, Update prices
	If (ini_getValue(ini, "General", "lastPriceUpdate"))
		FormatTime, lastPriceUpdate_formatted, % ini_getValue(ini, "General", "lastPriceUpdate"), dd/MM/yyyy @ HH:mm:ss
	Gui settings: Add, Text, x+5 yp+5 w200 hwnd_lastPriceUpdateDisplay, % "Last updated: " lastPriceUpdate_formatted
	
	Gui settings: Add, Button, x250 y5 gguiSettings_resetLog, Reset log
	
	Gui settings: Add, Button, xs w300 gguiSettings_save, Save
	
	; show
	If (guiSettingsX) and (guiSettingsY)
		Gui settings: show, % "x" guiSettingsX " y" guiSettingsY " AutoSize", Drop Logger Settings
	else
		Gui settings: show, AutoSize, Drop Logger Settings
	
	; close
	WinWaitClose, Drop Logger Settings
	return
	
	guiSettings_updatePrices:
		Gui settings: +Disabled
		updatePrices()
		Gui settings: -Disabled
		
		FormatTime, lastPriceUpdate_formatted, % ini_getValue(ini, "General", "lastPriceUpdate"), dd/MM/yyyy @ HH:mm:ss
		GuiControl settings: , % _lastPriceUpdateDisplay, % "Last updated: " lastPriceUpdate_formatted
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