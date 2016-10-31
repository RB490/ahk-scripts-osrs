guiLog(action = "") {
	static _btnSettings, _btnUndo, _tabs, _btnTrip, _btnNewTrip, _btnLogKill, _logDisplay, _dropsDisplay, killsThisTrip, tripTimerRunning, tripStartTime, tripCount
	
	autoOpenStats := ini_getValue(ini, "Settings", "autoOpenStats")
	guiLogX := ini_getValue(ini, "Window Positions", "guiLogX")
	guiLogY := ini_getValue(ini, "Window Positions", "guiLogY")
	
	DetectHiddenWindows, On
	
	If WinExist("Drop Logger") and (action = "refresh")
	{
		Gosub guiLog_refresh
		return
	}
	
	If WinExist("Drop Logger") and (action = "logKill")
	{
		Gosub guiLog_kill
		return
	}
	
	If !WinExist("Drop Logger")
	{
		marginWidth = 0
		marginHeight = 0
		iconWidth = 45
		iconHeight = 45
		iconRowHeight = 5
		
		loop, parse, % ini_getValue(ini, "Drop Tables", "rare drop table"), |
			rareDropTableCount++
		loop, parse, % ini_getValue(ini, "Drop Tables", g_mob), |
			dropTableCount++
		
		If (dropTableCount > rareDropTableCount)
		{
			; msgbox hi2
			tabWidth := Ceil(dropTableCount / iconRowHeight) * (iconWidth + marginWidth) + 30
		}
		else
		{
			; msgbox hi1
			tabWidth := Ceil(rareDropTableCount / iconRowHeight) * (iconWidth + marginWidth) + 30
		}
		
		; properties
		Gui log: New, +LabelguiLog_
		Gui log: +LastFound
		Gui log: Margin, 5, 5
		
		; controls
		Gui log: add, button, w150 r2 section hwnd_btnTrip gguiLog_trip
		Gui log: add, button, x+5 w150 r2 section hwnd_btnNewTrip gguiLog_newTrip, New trip
		
		Gui log: add, edit, x5 w305 r20 ReadOnly hwnd_logDisplay
		
		Gui log: add, button, x5 w50 r1 hwnd_btnSettings gguiLog_settings, Settings
		Gui log: add, button, x+5 w50 r1 hwndg__guiLog_btnStats gguiLog_stats, Stats
		Gui log: add, button, x+5 w95 r1 hwnd_btnUndo gguiLog_undo, Undo
		Gui log: add, button, x+5 w95 r1 gguiLog_redo hwndg__guiLog_btnRedo Disabled, Redo
		
		Gui log: Add, Button, xs+155 ys w%tabWidth% section r2 hwnd_btnLogKill gguiLog_kill, + Kill (enter)
		
		Gui log: Add, Tab2, xs w%tabWidth% h268 hwnd_tabs section, Drop Table
		
		Gui log: Margin, % marginWidth, % marginHeight
		
		Gui log: Tab, Drop Table
		
		count := ""
		loop, parse, % ini_getValue(ini, "Drop Tables", g_mob), |
		{
			If !(A_Index = 1)
			{
				LoopField := A_LoopField
				If InStr(LoopField, " x ")
					LoopField := SubStr(LoopField, InStr(LoopField, " x ") + 3)
					
				If !(count)
				{
					count := 1
					Gui log: Add, Picture, xp+10 yp+30 w%iconWidth% h%iconHeight% AltSubmit Border section, % A_ScriptDir "\res\img\items\" LoopField ".gif"
				}
				else If (count = iconRowHeight)
				{
					count := 1
					Gui log: Add, Picture, % "xs" + marginWidth + iconWidth + 1 " ys w" iconWidth " h"iconHeight " AltSubmit Border section", % A_ScriptDir "\res\img\items\" LoopField ".gif"
				}
				else
				{
					count++
					Gui log: Add, Picture, % "yp" + marginHeight + iconHeight + 1 " w" iconWidth " h" iconHeight " AltSubmit Border", % A_ScriptDir "\res\img\items\" LoopField ".gif"
				}
			}
		}
		
		count := ""
		If InStr(ini_getValue(ini, "Drop Tables", g_mob), "rare drop table")
		{
			GuiControl,, % _tabs, Rare Drop Table|
			
			Gui log: Tab, Rare Drop Table
			
			loop, parse, % ini_getValue(ini, "Drop Tables", "rare drop table"), |
			{
				LoopField := A_LoopField
				If InStr(LoopField, " x ")
					LoopField := SubStr(LoopField, InStr(LoopField, " x ") + 3)
					
				If !(count)
				{
					count := 1

					ControlGetPos, tab1static1_x, tab1static1_y, , , Static1
					tab1static1_x -= 3
					tab1static1_y -= 26
					Gui log: Add, Picture, x%tab1static1_x% y%tab1static1_y% w%iconWidth% h%iconHeight% AltSubmit Border section, % A_ScriptDir "\res\img\items\rare drop table\" LoopField ".gif"
				}
				else If (count = iconRowHeight)
				{
					count := 1
					Gui log: Add, Picture, % "xs" + marginWidth + iconWidth + 1 " ys w" iconWidth " h"iconHeight " AltSubmit Border section", % A_ScriptDir "\res\img\items\rare drop table\" LoopField ".gif"
				}
				else
				{
					count++
					Gui log: Add, Picture, % "yp" + marginHeight + iconHeight + 1 " w" iconWidth " h" iconHeight " AltSubmit Border", % A_ScriptDir "\res\img\items\rare drop table\" LoopField ".gif"
				}
			}
		}
		
		Gui log: Tab
		
		Gui log: Margin, 5, 5
		
		Gui log: Add, Edit, % "x315 y320 w" tabWidth - 55 " r1 ReadOnly hwnd_dropsDisplay"
		Gui log: Add, Button, x+5 yp-1 w50 gguiLog_clearDrops, Clear
		
		Gui log: Tab
	}
	
	; show
	If (guiLogX) and (guiLogY)
		Gui log: show, % "x" guiLogX " y" guiLogY " AutoSize", Drop Logger
	else
		Gui log: show, AutoSize, Drop Logger
	
	Gosub guiLog_refresh
	
	ControlSend, , ^{end}, % "ahk_id " _logDisplay
	
	If (autoOpenStats)
		Gosub guiLog_stats
	
	; close
	DetectHiddenWindows, Off
	WinWaitClose, % "Drop Logger - " g_logFile
	return
	
	guiLog_trip:
		FormatTime, now_formatted, % A_Now, dd/MM/yyyy @ HH:mm:ss
		
		If (IsTripOnGoing())
			log("append", "End trip - " now_formatted)
		else
			log("append", "Start trip - " now_formatted)
	return
	
	guiLog_newTrip:
		FormatTime, now_formatted, % A_Now, dd/MM/yyyy @ HH:mm:ss
		
		log("append", "End trip - " now_formatted)
		log("append", "Start trip - " now_formatted)
	return
	
	guiLog_undo:
		log("undo")
		Gosub guiLog_clearDrops
	return
	
	guiLog_redo:
		log("redo")
		Gosub guiLog_clearDrops
	return
	
	guiLog_clearDrops:
		GuiControl log: , % _dropsDisplay
	return
	
	guiLog_kill:
		ControlGetText, selectedDrops, , % "ahk_id " _dropsDisplay
		If !(selectedDrops)
			return
			
		kills := ""
		loop, parse, g_log, `n
			If InStr(A_LoopField, ".")
				kills++
		kills += 1
		
		log("append", kills ". " selectedDrops)
		Gosub guiLog_clearDrops
	return
	
	guiLog_stats:
		GuiControl log: Disable, % g__guiLog_btnStats
		guiStats()
	return
	
	guiLog_Settings:
		Gui log: +Owner
		Gui log: +Disabled
		GuiControl log: Disable, % _btnSettings
		
		guiSettings()
		guiLog("refresh")
		
		GuiControl log: Enable, % _btnSettings
		Gui log: -Disabled
		
		guiStats("refresh")
	return
	
	guiLog_refresh:		
		tripCount := ""
		loop, parse, g_log, `n
			If InStr(A_LoopField, "Start trip")
				tripCount++
		
		killsThisTrip := ""
		loop, parse, g_log, `n
		{
			If !(A_LoopField)
				break
			
			If (tripStarted)
			{
				log_currentTrip .= A_LoopField "`n"
				killsThisTrip++
			}
			
			If InStr(A_LoopField, "Start trip")
			{
				tripStarted := 1
				StringReplace, tripStartTime, A_LoopField, Start trip - 
				tripStartTime := ReFormatTime( tripStartTime, "DD MM YYYY HH MI SS", "/@:")
			}
				
			If InStr(A_LoopField, "End trip")
			{
				tripStarted := 0
				log_currentTrip := ""
				killsThisTrip := ""
			}
		}
		
		GuiControl log: , % _logDisplay, % log_currentTrip
		ControlSend, , ^{end}, % "ahk_id " _logDisplay
		
		If (IsTripOnGoing())
		{
			GuiControl log: , % _btnTrip, End Trip
			GuiControl log: Enable, % _btnNewTrip
			GuiControl log: Enable, % _btnLogKill
			
			If !(tripTimerRunning)
			{
				SetTimer, guiLog_tripTimer, 1000
				tripTimerRunning := 1
			}
			Gosub guiLog_tripTimer
		}
		else
		{
			GuiControl log: , % _btnTrip, Start Trip
			GuiControl log: Disable, % _btnNewTrip
			GuiControl log: Disable, % _btnLogKill
			
			SetTimer, guiLog_tripTimer, Off
			tripTimerRunning := 0
			
			Gui log: show, NoActivate, % "Drop Logger - " g_logFile " - " g_mob
		}
		
		If (g_log)
			GuiControl log: Enable, % _btnUndo
		else
			GuiControl log: Disable, % _btnUndo
	return
	
	guiLog_tripTimer:
		TripTimeInSeconds := A_Now
		EnvSub, TripTimeInSeconds, tripStartTime, seconds

		TripTimeInSecondsFormatted := A_YYYY A_MM A_DD 00 00 00
		EnvAdd, TripTimeInSecondsFormatted, TripTimeInSeconds, Seconds
		FormatTime, TripTimeInSecondsFormatted, % TripTimeInSecondsFormatted, HH:mm:ss
		
		If (killsThisTrip)
			Gui log: show, NoActivate, % "Drop Logger - " g_logFile  " - " g_mob " - " TripTimeInSecondsFormatted " trip #" tripCount " kill #" killsThisTrip
		else
			Gui log: show, NoActivate, % "Drop Logger - " g_logFile  " - " g_mob " - " TripTimeInSecondsFormatted " trip #" tripCount
	return
	
	guiLog_close:
		Gui log: Destroy
		
		WinGetPos, guiLogX, guiLogY, , , Drop Logger
		ini_replaceValue(ini, "Window Positions", "guiLogX", guiLogX)
		ini_replaceValue(ini, "Window Positions", "guiLogY", guiLogY)
		
		g_logFile := ""
		g_log := ""
		g_mob := ""
		
		guiMain()
	return
}