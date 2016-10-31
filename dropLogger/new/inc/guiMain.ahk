guiMain() {
	static guiMain_searchString
	
	; properties
	gui main: new
	gui main: margin, 5, 5
	gui main: +LabelguiMain_
	
	; controls
	gui main: font, s12
	gui main: add, edit, w250 gguiMain_search vguiMain_searchString, % guiMain_searchString
	gui main: add, ListBox, w250 r10 gguiMain_Lb vg_mob
	gui main: font
	gui main: add, button, w250 gguiMain_updateMobList, Update
	
	Gosub guiMain_refresh
	Gosub guiMain_search
	
	; show
	gui main: show, , Choose Mob
	
	; close
	WinWaitClose, Choose Mob
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
	
	guiMain_updateMobList:
		gui main: +Disabled
		updateMobList()
		Gosub guiMain_refresh
		gui main: -Disabled
	return
	
	guiMain_Submit:
		gui main: submit, nohide
		
		selectLogFile()
		If !(g_logFile)
			return
		
		gui main: hide
		
		If !(ini_getValue(ini, "Drop Tables", g_mob))
		{
			ini_insertKey(ini, "Drop Tables", g_mob "=")
			updateMobDropTable(g_mob)
			updatePrices("updateNewlyAdded")
		}
		
		guiLog()
		
		gui main: destroy
	return
	
	guiMain_escape:
	guiMain_close:
	exitapp
}