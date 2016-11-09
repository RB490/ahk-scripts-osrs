guiMain() {
	static guiMain_searchString
	
	guiMainX := ini_getValue(ini, "Window Positions", "guiMainX")
	guiMainY := ini_getValue(ini, "Window Positions", "guiMainY")
	
	; properties
	gui main: new
	gui main: margin, 5, 5
	gui main: +LabelguiMain_
	
	; controls
	gui main: font, s12
	gui main: add, edit, w250 gguiMain_search vguiMain_searchString, % guiMain_searchString
	gui main: add, ListBox, w250 r10 gguiMain_Lb vg_mob
	gui main: font
	gui main: add, button, w250 gguiMain_settings, Settings
	
	Gosub guiMain_refresh
	Gosub guiMain_search
	
	; show
	If !(guiMainX = "") and !(guiMainY = "")
		Gui main: show, % "x" guiMainX " y" guiMainY " AutoSize NoActivate", Drop Logger Mob Select
	else
		Gui main: show, AutoSize NoActivate, Drop Logger Mob Select
	
	loadSettings("loadItemsObj")
	return
	
	guiMain_Lb:
		IF (A_GuiEvent = "DoubleClick")
			Gosub guiMain_Submit
	return
	
	guiMain_search:
		gui main: submit, nohide
		
		If !(guiMain_searchString) {
			Gosub guiMain_refresh
			return
		}
		
		GuiControl main: -Redraw, g_mob
		GuiControl main: , g_mob, |
		
		loop, parse, % ini_getValue(ini, "general", "mobList"), |
			If InStr(A_LoopField, guiMain_searchString)
				GuiControl main: , g_mob, %  A_LoopField "|"
		
		GuiControl main: +Redraw, g_mob
	return
	
	guiMain_refresh:
		GuiControl main: -Redraw, g_mob
		GuiControl main: , g_mob, |
		loop, parse, % ini_getValue(ini, "general", "mobList"), |
			GuiControl main: , g_mob, %  A_LoopField "|"
		GuiControl main: +Redraw, g_mob
	return
	
	guiMain_settings:
		gui main: +Disabled
		guiSettings()
		Gosub guiMain_refresh
		gui main: -Disabled
	return
	
	guiMain_Submit:
		gui main: submit, nohide
		
		selectLogFile()
		If !(g_logFile)
			return
		
		gui main: destroy
		
		If !(ini_getValue(ini, "Drop Tables", g_mob))
			updateMobDropTable(g_mob)

		guiLog()
	return
	
	guiMain_escape:
	guiMain_close:
		WinGetPos, guiMainX, guiMainY, , , Drop Logger Mob Select
		ini_replaceValue(ini, "Window Positions", "guiMainX", guiMainX)
		ini_replaceValue(ini, "Window Positions", "guiMainY", guiMainY)
	exitapp
}