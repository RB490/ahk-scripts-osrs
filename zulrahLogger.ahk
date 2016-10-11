#SingleInstance, force
#Persistent
OnExit, exitRoutine
Gosub loadSettings

; g_logFile := "e:\downloads\maxGear.txt"
; guiStats()
; return

guiIntro()
guiMain()
return

loadSettings:
	OnMessage(0x202, "WM_LBUTTONUP")
	OnMessage(0x200, "WM_MOUSEMOVE")
	
	nullTime := A_YYYY A_MM A_DD "000000"
	global dropTable
	dropTable := "Zulrah's scales,Zul-andra teleport,Uncut onyx,Torstol,torstol seed,Toadflax,toadflax seed,Tanzanite fang,Swamp tar,Snapdragon,snapdragon seed,Snakeskin,Serpentine visage,Saradomin brew (4),Runite ore,Raw shark,Pure essence,Papaya tree seed,Palm tree seed,Mahogany plank,Magic seed,Magic logs,Magic fang,Law rune,Jar of swamp,Grapes,Flax,Dwarf weed,dwarf weed seed,Dragon med helm,Dragon halberd,Dragon bones,Dragon bolt tips,Death rune,Crystal seed,Coconut,Coal,Chaos rune,Calquat tree seed,Battlestaff,Antidote++ (4),Adamantite bar,Uncut sapphire,Uncut ruby,Uncut emerald,Uncut diamond,Tooth half of key,Steel arrow,Silver ore,Shield left half,Runite bar,Rune sq shield,Rune spear,Rune kiteshield,Rune javelin,Rune battleaxe,Rune arrow,Rune 2h sword,Nature talisman,Nature rune,Loop half of key,Law rune,Dragonstone,Dragon spear,Dragon med helm,Death rune,Chaos talisman,Adamant javelin"

	global iniFile
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		Gosub writeIni
		ini_load(ini, iniFile)
	}
	
	iniWrapper_loadSection(ini, "Settings")
	
	global ini
	
	global g_guiLog_selectedItem
	
	global g_logFile
	
	global _guiMain
	global guiMainX
	global guiMainY
	
	global _guiIntro
	global guiIntroX
	global guiIntroY
	
	global _guiTime
	global guiTimeX
	global guiTimeY
	
	global _guiLog
	global guiLogX
	global guiLogY
	
	global _guiStats
	global guiStatsX
	global guiStatsY
	
	global g_guiStats_bankTime
	global g_guiStats_downTime
	global g_guiStats_avgBaseScales
	global g_guiStats_lastPriceUpdate
return

saveSettings:
	iniWrapper_saveSection(ini, "Settings")
		
	ini_save(ini, iniFile)
return

writeIni:
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "guiMainX=" . "")
		ini_insertKey(ini, "Settings", "guiMainY=" . "")
		ini_insertKey(ini, "Settings", "guiIntroX=" . "")
		ini_insertKey(ini, "Settings", "guiIntroY=" . "")
		ini_insertKey(ini, "Settings", "guiTimeX=" . "")
		ini_insertKey(ini, "Settings", "guiTimeY=" . "")
		ini_insertKey(ini, "Settings", "guiLogX=" . "")
		ini_insertKey(ini, "Settings", "guiLogY=" . "")
		ini_insertKey(ini, "Settings", "guiStatsX=" . "")
		ini_insertKey(ini, "Settings", "guiStatsY=" . "")
		ini_insertKey(ini, "Settings", "g_guiStats_bankTime=" . "50")
		ini_insertKey(ini, "Settings", "g_guiStats_downTime=" . "10")
		ini_insertKey(ini, "Settings", "g_guiStats_avgBaseScales=" . "175")
		ini_insertKey(ini, "Settings", "g_guiStats_lastPriceUpdate=" . "10")
		
		ini_insertKey(ini, "Settings", "g_guiMain_tripsEnabled=" . "1")
		ini_insertKey(ini, "Settings", "g_guiMain_killCountEnabled=" . "1")
		ini_insertKey(ini, "Settings", "g_guiMain_dateEnabled=" . "1")
		ini_insertKey(ini, "Settings", "g_guiMain_timeEnabled=" . "1")
		ini_insertKey(ini, "Settings", "g_guiMain_durationEnabled=" . "1")
		ini_insertKey(ini, "Settings", "g_guiMain_dropsEnabled=" . "1")
	
	ini_insertSection(ini, "Prices")
		loop, parse, dropTable, `,
			ini_insertKey(ini, "Prices", A_LoopField "=" . "")
	
	updatePrices()
	g_guiStats_lastPriceUpdate := A_Now
	
	ini_save(ini)
return

exitRoutine:
	If WinExist("ahk_id " _guiMain)
		WinGetPos(_guiMain, guiMainX, guiMainY)
	
	If WinExist("ahk_id " _guiIntro)
		WinGetPos(_guiIntro, guiIntroX, guiIntroY)
	
	If WinExist("ahk_id " _guiTime)
		WinGetPos(_guiTime, guiTimeX, guiTimeY)
	
	If WinExist("ahk_id " _guiLog)
		WinGetPos(_guiLog, guiLogX, guiLogY)
	
	If WinExist("ahk_id " _guiStats)
		WinGetPos(_guiStats, guiStatsX, guiStatsY)
	
	Gosub saveSettings
	
	exitapp
return

guiIntro() {
	; properties
	gui intro: default
	gui intro: margin, 5, 5
	gui intro: +LabelguiIntro_ +Hwnd_guiIntro -MinimizeBox
	
	; controls
	gui intro: add, button, w70 r2 w70 r2 gguiIntro_openFile, Open
	gui intro: add, button, w70 r2 gguiIntro_newFile, New
	
	; show
	If !(guiIntroX = "") and !(guiIntroY = "")
		gui Intro: show, % "x" guiIntroX " y" guiIntroY " AutoSize"
	else
		gui Intro: show, AutoSize
	
	; close
	WinWaitClose, % "ahk_id " _guiIntro
	exitapp
	return
	
	guiIntro_openFile:
		FileSelectFile, file, , , Open Radial, (*.txt)
		If (file = "")
			return
		gui intro: Destroy
		g_logFile := file
		guiMain()
	return
	
	guiIntro_newFile:
		FileSelectFile, file, S, , Open Radial, (*.txt)
		If (file = "")
			return
		
		SplitPath, file, OutFileName, OutDir, OutExtension, fileNoExt
		If (OutExtension)
			file := OutDir "\" fileNoExt
		file .= ".txt"
		
		If FileExist(file)
		{
			msgbox, 36, , Another file with this name already exists. Overwrite?
			IfMsgBox No
				return
		}
		
		gui intro: Destroy
		
		FileDelete, % file
		FileAppend, , % file
		g_logFile := file
		
		guiMain()
	return
	
	guiIntro_escape:
	guiIntro_close:
		WinGetPos(_guiIntro, guiIntroX, guiIntroY)
		exitapp
	return
}

guiMain() {
	global g_guiMain_display, g_guiMain_btnStats
	global g_guiMain_tripsEnabled, g_guiMain_killCountEnabled, g_guiMain_dateEnabled, g_guiMain_timeEnabled, g_guiMain_durationEnabled, g_guiMain_dropsEnabled
	
	; properties
	gui main: default
	gui main: margin, 5, 5
	gui main: +LabelguiMain_ +Hwnd_guiMain +LastFound
	
	; controls
	gui main: add, button, w150 r2 gguiMain_startTrip, Start Trip
	gui main: add, button, x+5 w150 r2 gguiMain_logKill, + Kill
	gui main: add, button, x5 w305 r1 gguiMain_undo, Undo
	
	gui main: add, checkbox, checked%g_guiMain_tripsEnabled% vg_guiMain_tripsEnabled gguiMain_refresh, Trips
	gui main: add, checkbox, x+5 checked%g_guiMain_killCountEnabled% vg_guiMain_killCountEnabled gguiMain_refresh, #
	gui main: add, checkbox, x+5 checked%g_guiMain_dateEnabled% vg_guiMain_dateEnabled gguiMain_refresh, Date
	gui main: add, checkbox, x+5 checked%g_guiMain_timeEnabled% vg_guiMain_timeEnabled gguiMain_refresh, Time
	gui main: add, checkbox, x+5 checked%g_guiMain_durationEnabled% vg_guiMain_durationEnabled gguiMain_refresh, Duration
	gui main: add, checkbox, x+5 checked%g_guiMain_dropsEnabled% vg_guiMain_dropsEnabled gguiMain_refresh, Drops
	
	gui main: add, edit, x5 w305 r10 vg_guiMain_display
	
	gui main: add, button, x5 w305 r1 gguiMain_btnStats vg_guiMain_btnStats, Stats
	
	Gosub guiMain_refresh
	
	; show
	If !(guiMainX = "") and !(guiMainY = "")
		gui main: show, % "x" guiMainX " y" guiMainY " AutoSize", % g_logFile
	else
		gui main: show, AutoSize, % g_logFile
	
	ControlSend, Edit1, ^{End}
	
	; close
	WinWaitClose, % "ahk_id " _guiMain
	gui main: Destroy
	guiIntro()
	return
	
	guiMain_logKill:
		guiLog(time, drops)
		If !(time) or !(drops)
			return
			
		If !(killCount)
			killCount := 1
		else
			killCount++
			
		FormatTime, output, % a_now, dd/MM/yyyy - HH:mm:ss
		logToFile("#" killCount " " output ": [" time "] " drops)
		Gosub guiMain_refresh
	return
	
	guiMain_startTrip:
		logToFile("### Trip Start ###")
		Gosub guiMain_refresh
	return
	
	guiMain_undo:
		logToFileUndo()
		Gosub guiMain_refresh
	return
	
	guiMain_btnStats:
		GuiControl main: Disable, g_guiMain_btnStats
		guiStats()
	return
	
	guiMain_refresh:
		gui main: +LastFound
		gui main: Submit, NoHide
		FileRead, input, % g_logFile

		output := ""
		loop, parse, % input, `n
		{
			If !(A_LoopField)
				break
			If !InStr(A_LoopField, "Trip Start")
			{
				logKillCount := SubStr(A_LoopField, 2, InStr(A_LoopField, A_Space) - 2)
				logKillDate := SubStr(A_LoopField, InStr(A_LoopField, A_Space) + 1, 10)
				logKillTime := SubStr(A_LoopField, InStr(A_LoopField, "-" A_Space) + 2, 8)
				logKillDuration := StringBetween(A_LoopField, "[", "]")
				logDrops := SubStr(A_LoopField, InStr(A_LoopField, "]") + 2)
				
				outputLine := ""
				If (g_guiMain_killCountEnabled)
					outputLine .= "#" logKillCount A_Space
				If (g_guiMain_dateEnabled)
					outputLine .= logKillDate A_Space
				If (g_guiMain_timeEnabled)
					outputLine .= "-" A_Space logKillTime ":" A_Space
				If (g_guiMain_durationEnabled)
					outputLine .= "[" logKillDuration "]" A_Space
				If (g_guiMain_dropsEnabled)
					outputLine .= logDrops
				
				output .= outputLine "`n"
			}
			else If (g_guiMain_tripsEnabled)
				output .= A_LoopField "`n"
		}
		
		GuiControl main:, g_guiMain_display, % output
		ControlSend, Edit1, ^{End}
		
		killCount := ""
		loop, parse, input, `n
			If InStr(A_LoopField, ":")
				killCount++
				
		If WinExist("ahk_id " _guiStats)
			guiStats("update")
	return
	
	guiMain_close:
		WinGetPos(_guiMain, guiMainX, guiMainY)
		gui main: Submit
		gui main: Destroy
	return
}

guiStats(update = "") {
	global g_guiStats_trips, g_guiStats_kills, g_guiStats_totalkillDuration, g_guiStats_avgkillDuration, g_guiStats_avgKillsPerTrip
	global g_guistats_totalDropValue, g_guistats_averageDropValue
	global g_guistats_averageProfitPerHour, g_guistats_averageKillsPerHour, g_guistats_averageTripsPerHour
	global g_guiStats_bankTime, g_guiStats_downTime, g_guiStats_avgBaseScales, g_guiStats_lastPriceUpdate
	global g_guiStats_dropRatesLv, g_guiStats_dropInfoLv
	
	If (update)
	{
		Gosub guiStats_refresh
		return
	}
	If WinExist("ahk_id " _guiStats)
		return
	
	; properties
	gui stats: default
	gui stats: margin, 5, 5
	gui stats: +LabelguiStats_ +Hwnd_guiStats +LastFound
	
	; controls
	gui stats: Add, Tab2, x5 w470 h270 section, General|Drop Rates|Hourly Rates||Misc|Settings
	
	gui stats: Tab, General
	
	gui stats: add, text, y+5 w455 r1 vg_guistats_trips
	gui stats: add, text, y+5 w455 r1 vg_guistats_kills
	gui stats: add, text, y+5 w455 r1 vg_guistats_totalkillDuration
	gui stats: add, text, y+5 w455 r1 vg_guistats_avgkillDuration
	gui stats: add, text, y+5 w455 r1 vg_guistats_avgKillsPerTrip
	gui stats: add, text, y+5 w455 r1 vg_guistats_totalDropValue
	gui stats: add, text, y+5 w455 r1 vg_guistats_averageDropValue
	
	gui stats: Tab, Drop Rates
	
	gui stats: add, ListView, w455 r12 AltSubmit vg_guiStats_dropRatesLv gguiStats_dropRatesLv, Drop|Rate
	
	gui stats: Tab, Hourly Rates
	gui stats: add, text, w455 r1 vg_guistats_averageProfitPerHour
	gui stats: add, text, w455 r1 vg_guistats_averageKillsPerHour
	gui stats: add, text, w455 r1 vg_guistats_averageTripsPerHour
	
	gui stats: add, text, y+20 w455 r1, * Not including supplies
	
	gui stats: Tab, Misc
	
	gui stats: add, ListView, w455 r12 AltSubmit vg_guiStats_dropInfoLv gguiStats_dropInfoLv, Drop|Kills since last drop|Shortest dry streak|Longest dry streak
	
	gui stats: Tab, Settings
	
	gui stats: add, text, w90 section, Average base scales drop
	gui stats: add, edit, x+5 w75 Number vg_guiStats_avgBaseScales gguiStats_refreshTimer, % g_guiStats_avgBaseScales
	gui stats: add, UpDown, Range0-9999
	GuiControl stats: , g_guiStats_avgBaseScales, % g_guiStats_avgBaseScales ; updown control sets value to 0
	
	gui stats: add, text, xs ys+40, Time (seconds)
	gui stats: add, text, w90, Banking
	gui stats: add, edit, x+5 w75 Number Limit2 vg_guiStats_bankTime gguiStats_refreshTimer, % g_guiStats_bankTime
	gui stats: add, UpDown
	GuiControl stats: , g_guiStats_bankTime, % g_guiStats_bankTime ; updown control sets value to 0
	gui stats: add, text, xs w90, Between kills
	gui stats: add, edit, x+5 w75 Number Limit2 vg_guiStats_downTime gguiStats_refreshTimer, % g_guiStats_downTime
	gui stats: add, UpDown
	GuiControl stats: , g_guiStats_downTime, % g_guiStats_downTime ; updown control sets value to 0
	
	gui stats: add, button, xs gguiStats_updatePrices, Update Prices
	gui stats: add, text, w455 vg_guiStats_lastPriceUpdate
	
	gui stats: Tab
	
	; show
	If !(guiStatsX = "") and !(guiStatsY = "")
		gui Stats: show, % "x" guiStatsX " y" guiStatsY " AutoSize"
	else
		gui Stats: show, AutoSize
		
	Gosub guiStats_refresh
	
	ControlSend, Edit1, ^{End}
	return
	
	guiStats_updatePrices:
		updatePrices()
		g_guiStats_lastPriceUpdate := A_Now
		Gosub guiStats_refresh
	return
	
	guiStats_refreshTimer:
		SetTimer, guiStats_refresh, -250
	return
	
	guiStats_refresh:
		gui stats: default
		gui stats: Submit, NoHide
		
		; reset vars
		trips := ""
		killCount := ""
		avgKillCountPerTrip := ""
		totalkillDuration := A_YYYY A_MM A_DD 00 00 00
		avgkillDuration := A_YYYY A_MM A_DD 00 00 00
		avgkillDurationInSeconds := ""
		totalkillDurationSeconds := ""
		
		totalDrops := ""
		dropRateList := ""
		
		g_guistats_totalDropValue := ""
		
		; calculate values
		FileRead, logFile, % g_logFile
		loop, parse, logFile, `n
		{
			If !(A_LoopField)
				break
			LoopField := string_cleanUp(A_LoopField)
			
			; trips
			If (LoopField = "### Trip Start ###")
				trips++
				
			If InStr(LoopField, ":") ; killcount, kill duration
			{
				killCount++
				loop, parse, % StringBetween(A_LoopField, "[", "]"), :
				{
					If (A_Index = 1)
						totalkillDurationSeconds += A_LoopField * 60
					If (A_Index = 2)
						totalkillDurationSeconds += A_LoopField
				}
				
				; drop rates
				loop, parse, % SubStr(A_LoopField, InStr(A_LoopField, "]") + 2), `,
					If (A_Index = 1)
						totalDrops .= string_cleanUp(A_LoopField) "`n"
					else
						totalDrops .= string_cleanUp(A_LoopField) "`n"
			}
		}
		totalUniqueDrops := string_removeDuplicates(totalDrops)
		
		avgkillDurationInSeconds := Round(totalkillDurationSeconds / killCount)
		EnvAdd, avgkillDuration, avgkillDurationInSeconds, Seconds
		FormatTime, avgkillDurationFormatted, % avgkillDuration, mm:ss
		
		EnvAdd, totalkillDuration, totalkillDurationSeconds, Seconds
		FormatTime, totalkillDurationFormatted, % totalkillDuration, mm:ss
		
		avgKillCountPerTrip := Round(KillCount / trips, 2)
		
		loop, parse, totalDrops, `n
			g_guistats_totalDropValue += priceLookup(A_LoopField)
		g_guistats_totalDropValue += priceLookup("Zulrah's scales") * (killCount * g_guiStats_avgBaseScales)
		
		g_guistats_averageDropValue := Round(g_guistats_totalDropValue / killCount)
		
		g_guistats_averageTripsPerHour := 3600 / (avgKillCountPerTrip * (avgkillDurationInSeconds + g_guiStats_downTime) + g_guiStats_bankTime)
		g_guistats_averageTripsPerHour := Round(g_guistats_averageTripsPerHour, 1)
		
		g_guistats_averageKillsPerHour := g_guistats_averageTripsPerHour * avgKillCountPerTrip
		g_guistats_averageKillsPerHour := Round(g_guistats_averageKillsPerHour, 1)
		
		g_guistats_averageProfitPerHour := g_guistats_averageKillsPerHour * g_guistats_averageDropValue
		g_guistats_averageProfitPerHour := Round(g_guistats_averageProfitPerHour)
		
		; update gui
			; General
				GuiControl stats:, g_guistats_trips, % "Trips:`t`t`t" trips
				GuiControl stats:, g_guistats_kills, % "Kills:`t`t`t" killCount
				GuiControl stats:, g_guistats_totalkillDuration, % "Total Kill Time:`t`t" totalkillDurationFormatted
				GuiControl stats:, g_guistats_avgkillDuration, % "Average Kill Time:`t" avgkillDurationFormatted
				GuiControl stats:, g_guistats_avgKillsPerTrip, % "Average Kills Per Trip:`t" avgKillCountPerTrip
				
				GuiControl stats:, g_guistats_totalDropValue, % "Total drop value:`t" ThousandsSep(g_guistats_totalDropValue)
				GuiControl stats:, g_guistats_averageDropValue, % "Average drop value:`t" ThousandsSep(g_guistats_averageDropValue)
				
			; Drop Rates
				gui stats: ListView, g_guiStats_dropRatesLv
				GuiControl, -Redraw, g_guiStats_dropRatesLv
				LV_Delete()
				loop, parse, totalUniqueDrops, `n
				{
					If !(A_LoopField)
						break
					
					dropCount := ""
					input := string_getDuplicates(A_LoopField, totalDrops)
					loop, parse, input, `n
						dropCount++
					dropRate := Round(killCount / dropCount, 2)
					dropRateList .= A_LoopField "`t`t" dropRate "`n"
					LV_Add(, A_LoopField, dropRate)
				}
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(2, "Integer")
				LV_ModifyCol(2, "SortDesc")
				
				If (guiStats_dropRatesLvSelectedRowNumber)
					LV_Modify(guiStats_dropRatesLvSelectedRowNumber, "Vis") ; scroll down to last selected row
				
				GuiControl, +Redraw, g_guiStats_dropRatesLv
				
			; Misc
				gui stats: ListView, g_guiStats_dropInfoLv
				GuiControl, -Redraw, g_guiStats_dropRatesLv
				LV_Delete()
				
				loop, parse, totalUniqueDrops, `n
				{
					If !(A_LoopField)
						break
					
					LoopField := A_LoopField
					
					; kills since last drop
					killsSinceLastDrop:= ""
					loop, parse, logFile, `n
					{
						If InStr(A_LoopField, LoopField)
							killsSinceLastDrop := ""
						else
							killsSinceLastDrop++
					}
					killsSinceLastDrop -= 1
					
					; dry streaks
					dryStreakStart := ""
					dryStreaksOutput := ""
					dryStreak := ""
					loop, parse, logFile, `n
					{
						If !InStr(A_LoopField, "### Trip Start ###")
						{
							If !InStr(A_LoopField, LoopField)
								dryStreak++
							
							If InStr(A_LoopField, LoopField)
							{
								If !(dryStreak)
									dryStreak := 0
								dryStreaksOutput .= dryStreak "`n"
								dryStreak := 0
							}
						}
					}
					
					Sort, dryStreaksOutput, N ; low to high
					loop, parse, dryStreaksOutput, `n
					{
						shortestDryStreak := A_LoopField
						break
					}
					
					dryStreaksOutput .= dryStreak "`n" ; add drystreak since last drop after shortest dry streak is retrieved
					
					Sort, dryStreaksOutput, NR ; high to low
					loop, parse, dryStreaksOutput, `n
					{
						longestDryStreak := A_LoopField
						break
					}
					
					LV_Add(, LoopField, killsSinceLastDrop, shortestDryStreak, longestDryStreak)
				}
				
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
				LV_ModifyCol(2, "Integer")
				LV_ModifyCol(3, "AutoHdr")
				LV_ModifyCol(3, "Integer")
				LV_ModifyCol(4, "AutoHdr")
				LV_ModifyCol(4, "Integer")
				
				LV_ModifyCol(2, "SortDesc")
				GuiControl, +Redraw, g_guiStats_dropRatesLv
				
			; hourly rates
			GuiControl stats:, g_guistats_averageProfitPerHour, % "Profit*:`t" ThousandsSep(g_guistats_averageProfitPerHour)
			GuiControl stats:, g_guistats_averageKillsPerHour, % "Kills:`t" g_guistats_averageKillsPerHour
			GuiControl stats:, g_guistats_averageTripsPerHour, % "Trips:`t" g_guistats_averageTripsPerHour
			
			; settings
			FormatTime, g_guiStats_lastPriceUpdateFormatted, % g_guiStats_lastPriceUpdate, dd/MM/yyyy - HH:mm:ss
			GuiControl stats:, g_guiStats_lastPriceUpdate, % "Last Updated:`t" g_guiStats_lastPriceUpdateFormatted
	return
	
	guiStats_dropRatesLv:
		If (A_GuiEvent = "Normal") or (A_GuiEvent = "DoubleClick")
			guiStats_dropRatesLvSelectedRowNumber := A_EventInfo
	return
	
	guiStats_dropInfoLv:
		If (A_GuiEvent = "Normal") or (A_GuiEvent = "DoubleClick")
			guiStats_dropInfoLvSelectedRowNumber := A_EventInfo
	return
	
	guiStats_close:
		WinGetPos(_guiStats, guiStatsX, guiStatsY)
		gui stats: Destroy
		GuiControl main: Enable, g_guiMain_btnStats
	return
}

guiTime() {
	global g_guiTime_timeValueM, g_guiTime_timeValueS, g_guiTime_Display
	
	; properties
	gui Time: Default
	gui Time: +AlwaysOnTop +LabelguiTime_ +Hwnd_guiTime -MinimizeBox
	gui Time: Font
	gui Time: Margin, 5, 5

	; controls
	gui Time: add, text, x5 w90, Minutes (0-59)
	gui Time: add, edit, x+5 w75 Number Limit2 vg_guiTime_timeValueM gguiTime_Convert
	gui Time: add, UpDown, Range0-59

	gui Time: add, text, x5 w90, Seconds (0-59)
	gui Time: add, edit, x+5 w75 Number Limit2 vg_guiTime_timeValueS gguiTime_Convert
	gui Time: add, UpDown, Range0-59

	gui Time: add, text, x5 w90, Time
	gui Time: add, text, x+5 w75 vg_guiTime_Display
	
	gui Time: add, button, x5 w170 gguiTime_Save, Set
	
	; hotkeys
	hotkey, IfWinActive, % "ahk_id " _guiTime
	hotkey, enter, guiTime_Save
	hotkey, IfWinActive
	
	; show
	If !(guiTimeX = "") and !(guiTimeY = "")
		gui Time: show, % "x" guiTimeX " y" guiTimeY " AutoSize"
	else
		gui Time: show, AutoSize
	
	; close
	WinWaitClose, % "ahk_id " _guiTime
	gui Time: Destroy
	return outputFormatted
	
	guiTime_Convert:
		gui Time: Default
		gui Time: Submit, Nohide
		
		loop, parse, % "g_guiTime_timeValueM,g_guiTime_timeValueS", `,
		{
			If (%A_LoopField% = "") ; convert empty var to 00
				%A_LoopField% := 00
				
			If (StrLen(%A_LoopField%) = 1) ; add 0 infront of single digits
				%A_LoopField% := 0 %A_LoopField%
			
			If (A_LoopField = "g_guiTime_timeValueM") ; ensure max value is not exceeded
				If (%A_LoopField% > 59)
				{
					GuiControl Time:, g_guiTime_timeValueM, 59
					Send {End} ; move cursor to end of line
					g_guiTime_timeValueM := 59
				}
				
			If (A_LoopField = "g_guiTime_timeValueS") ; ensure max value is not exceeded
				If (%A_LoopField% > 59)
				{
					GuiControl Time:, g_guiTime_timeValueS, 59
					Send {End} ; move cursor to end of line
					g_guiTime_timeValueS := 59
				}
		}
		output := A_YYYY A_MM A_DD 00 g_guiTime_timeValueM g_guiTime_timeValueS
		FormatTime, outputFormatted, % output, mm:ss
		GuiControl Time:, g_guiTime_Display, % outputFormatted
	return
	
	guiTime_Save:
		gui Time: +OwnDialogs
		
		If (output = A_YYYY A_MM A_DD 00 00 00)
		{
			msgbox Specify a time!
			return
		}
		Gosub guiTime_savePos
		gui Time: Destroy
	return
	
	guiTime_Escape:
	guiTime_close:
		Gosub guiTime_savePos
		gui Time: Destroy
		output := ""
	return
	
	guiTime_savePos:
		WinGetPos(_guiTime, guiTimeX, guiTimeY)
	return
}

guiLog(ByRef killDuration, ByRef Drops) {
	global g_guiLog_drops
	global g_guiLog_timeValueM, g_guiLog_timeValueS, g_guiLog_tabs
	
	DetectHiddenWindows, On
	
	If !WinExist("ahk_id " _guiLog)
	{
		; properties
		gui log: margin, 5, 5
		gui log: +LabelguiLog_ +Hwnd_guiLog +AlwaysOnTop -MinimizeBox
		
		; controls
		iconWidth = 25
		iconHeight = 25
		
		gui log: Add, text, , Kill Time
		
		gui log: add, text, x5 w90, Minutes
		gui log: add, edit, x+5 w75 Number Limit2 vg_guiLog_timeValueM gguiLog_timeConvert
		gui log: add, UpDown, Range0-59
		
		gui log: add, text, x5 w90, Seconds
		gui log: add, edit, x+5 w75 Number Limit2 vg_guiLog_timeValueS gguiLog_timeConvert
		gui log: add, UpDown, Range0-59
		
		gui log: Add, Tab2, x5 w370 h270 section vg_guiLog_tabs, Drop Table|Rare Drop Table
		
		gui log: Tab, Drop Table
		
		gui log: Add, text, section, Misc
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Zul-andra teleport.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dragon bones.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Coconut.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Grapes.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Zulrah's scales.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Battlestaff.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Antidote++ (4).png"
		gui log: Add, text, xs+30 ys section
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Raw shark.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Mahogany plank.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Swamp tar.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Saradomin brew (4).png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Adamantite bar.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Clue scroll (elite).png"
		gui log: Add, text, xs+30 ys section
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Flax.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Snakeskin.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dragon bolt tips.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Magic logs.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Coal.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Runite ore.png"
		
		gui log: Add, text, xs+40 ys section, Seeds
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Magic seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Calquat tree seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Papaya tree seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Palm tree seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Toadflax seed.png"
		gui log: Add, text, xs+30 ys section
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Snapdragon seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dwarf weed seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Torstol seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Spirit seed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Crystal seed.png"
		
		gui log: Add, text, xs+40 ys section, Herbs
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Toadflax.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Snapdragon.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dwarf weed.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Torstol.png"
		
		gui log: Add, text, xs+40 ys section, Runes
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Law rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Death rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Chaos rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Pure essence.png"
		
		gui log: Add, text, xs+40 ys section, Uniques
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Tanzanite fang.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Magic fang.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Serpentine visage.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Uncut onyx.png"
		gui log: Add, text, xs+30 ys section
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Jar of swamp.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Pet snakeling.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Tanzanite mutagen.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Magma mutagen.png"
		
		gui log: Add, text, xs+40 ys section, Gear
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dragon med helm.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\zulrah\Dragon halberd.png"
		
		gui log: Tab, Rare Drop Table
		
		gui log: Add, text, section, Misc
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Coins.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Tooth half of key.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Loop half of key.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Shield left half.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Silver ore.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Runite bar.png"
		
		gui log: Add, text, xs+40 ys section, Gear
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Dragon med helm.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Dragon spear.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune spear.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune 2h sword.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune battleaxe.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune sq shield.png"
		gui log: Add, text, xs+30 ys section
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune kiteshield.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune arrow.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Steel arrow.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Adamant javelin.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Rune javelin.png"
		
		gui log: Add, text, xs+40 ys section, Runes
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Death rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Law rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Nature rune.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Chaos talisman.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Nature talisman.png"
		
		gui log: Add, text, xs+40 ys section, Gems
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Dragonstone.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Uncut diamond.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Uncut ruby.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Uncut emerald.png"
		gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\rare drop table\Uncut sapphire.png"
		
		gui log: Tab
		
		gui log: Add, edit, x5 w329 vg_guiLog_drops
		gui log: Add, button, x+5 yp-1 gguiLog_clearEdit, Clear
		gui log: Add, button, x5 w370 gguiLog_save, Save (enter)
		
		gui log: Tab
		
		; hotkeys
		hotkey, IfWinActive, % "ahk_id " _guiLog
		hotkey, enter, guiLog_save
		hotkey, IfWinActive
	}
	
	Gosub guiLog_clearControls
	
	; show
	If !(guiLogX = "") and !(guiLogY = "")
		gui Log: show, % "x" guiLogX " y" guiLogY " AutoSize"
	else
		gui Log: show, AutoSize
	
	; close
	DetectHiddenWindows, Off
	WinWaitClose, % "ahk_id " _guiLog

	Drops := g_guiLog_drops
	killDuration := outputFormatted
	return
	
	guiLog_save:
		gui log: +OwnDialogs
		gui log: Submit, NoHide
		
		If (output = 20161009000000)
		{
			msgbox No kill time specified!
			return
		}
		
		dropCount := ""
		loop, parse, g_guiLog_drops, `,
			dropCount++
		
		If !(dropCount)
		{
			msgbox No drops selected!
			return
		}
		
		If (dropCount > 2)
			{
				msgbox Limit of 2 drops exceeded!`nZulrah rolls two drops per kill (besides the default scales drop)
				return
			}

		If (dropCount = 1)
			{
				msgbox select two drops!`nZulrah rolls two drops per kill (besides the default scales drop)
				return
			}
		
		gui log: Hide
	return
	
	guiLog_clearEdit:
		GuiControl,, g_guiLog_drops
	return
	
	guiLog_clearControls:
		GuiControl log:, g_guiLog_timeValueM
		GuiControl log:, g_guiLog_timeValueS
		GuiControl log:, g_guiLog_drops
		ControlFocus, Edit1
		GuiControl log: ChooseString, g_guiLog_tabs, Drop Table
	return
	
	guiLog_timeConvert:
		gui log: Default
		gui log: Submit, Nohide
		
		loop, parse, % "g_guiLog_timeValueM,g_guiLog_timeValueS", `,
		{
			If (%A_LoopField% = "") ; convert empty var to 00
				%A_LoopField% := 00
				
			If (StrLen(%A_LoopField%) = 1) ; add 0 infront of single digits
				%A_LoopField% := 0 %A_LoopField%
			
			If (%A_LoopField% > 59) ; ensure max value is not exceeded
				{
					GuiControl log:, %A_LoopField%, 59
					Send {End} ; move cursor to end of line
					%A_LoopField% := 59
				}
		}
		output := A_YYYY A_MM A_DD 00 g_guiLog_timeValueM g_guiLog_timeValueS
		FormatTime, outputFormatted, % output, mm:ss
		If (output = A_YYYY A_MM A_DD 00 00 00)
			outputFormatted := ""
	return
	
	guiLog_escape:
	guiLog_close:
		WinGetPos(_guiLog, guiLogX, guiLogY)
		gui log: Hide
		g_guiLog_drops := ""
		output := ""
	return
}

WM_MOUSEMOVE() {
	static oldInput
	
	input := getItemUnderMouse()
	
	If !(input) ; no item under mouse
	{
		ToolTip
		oldInput := ""
		return
	}

	If (input = oldInput) ; item under the mouse is identical to previous
		return
	
	If !(input = oldInput) ; new item under mouse
	{
		ToolTip, % input
		oldInput := input
	}
}

WM_LBUTTONUP() {
	g_guiLog_selectedItem := getItemUnderMouse()
	If !(g_guiLog_selectedItem)
		return
	
	ControlGet, input, Line, 1, Edit3, % "ahk_id " _guiLog
	If (input = "")
		GuiControl,, g_guiLog_drops, % g_guiLog_selectedItem
	else
		GuiControl,, g_guiLog_drops, % input ", " g_guiLog_selectedItem
}

getItemUnderMouse() {
	MouseGetPos, , , hwnd, control
	If !(control) or !(hwnd = _guiLog)
		return
	
	ControlGetText, output, % control, % "ahk_id " hwnd
	SplitPath, output, , OutDir, , OutNameNoExt
	If !(OutDir) ; something else besides an image was selected
		return
	
	If InStr(output, "rare drop table")
		return getRareItemQuantity(OutNameNoExt) OutNameNoExt
	else
		return getItemQuantity(OutNameNoExt) OutNameNoExt
}

getItemQuantity(input) {
	; drop table
	If (input = "Calquat tree seed") or (input = "Papaya tree seed") or (input = "Toadflax seed")  or (input = "Snapdragon seed") or (input = "Dwarf weed seed")  or (input = "Torstol seed")
		output := 2
	If (input = "Battlestaff") or (input = "Runite ore") or (input = "Antidote++ (4)") or (input = "Saradomin brew (4)")
		output := 10
	If (input = "Dragon bolt tips")
		output := 12
	If (input = "Toadflax") or (input = "Snapdragon") or (input = "Dwarf weed") or (input = "Torstol") or (input = "Coconut")
		output := 20
	If (input = "Adamantite bar")
		output := 30
	If (input = "Dragon bones")
		output := 30
	If (input = "Snakeskin")
		output := 35
	If (input = "Mahogany plank")
		output := 50
	If (input = "Magic logs") or (input = "Raw shark")
		output := 100
	If (input = "Law rune")
		output := 200
	If (input = "Grapes")
		output := 250
	If (input = "Death rune") or (input = "Coal")
		output := 300
	If (input = "Chaos rune") or (input = "Zulrah's scales")
		output := 500
	If (input = "Flax") or (input = "Swamp tar")
		output := 1000
	If (input = "Pure essence")
		output := 1500
	
	If (output)
		output .= " x "
	return output
}

getRareItemQuantity(input) {
	; rare drop table
	If (input = "Coins")
		output := 1
	If (input = "Rune javelin")
		output := 5
	If (input = "Adamant javelin")
		output := 20
	If (input = "Law rune") or (input = "Death rune")
		output := 45
	If (input = "Rune arrow") or (input = "Nature rune")
		output := 67
	If (input = "Silver ore")
		output := 100
	If (input = "Steel arrow")
		output := 150
		
	If (output)
		output .= " x "
	return output
}

priceLookup(input) {
	If !(input)
		return
	quantity := 1
	item := input
	If InStr(input, " x ")
	{
		quantity := SubStr(input, 1, InStr(input, " x ") - 1)
		item := SubStr(input, InStr(input, " x ") + 3)
	}

	price := ini_getValue(ini, "Prices", item)
	If (item = "Coins")
		price := 1
		
	output := price * quantity
	
	return output
}

updatePrices() {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving item prices..
	loop, parse, dropTable, `,
	{
		If !(A_LoopField)
			return

		item := A_LoopField
		itemId := getItemId(item)
		If (itemId)
		{
			file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now ".txt"
			UrlDownloadToFile, https://api.rsbuddy.com/grandExchange?a=guidePrice&i=%itemId%, % file
			FileRead, output, % file
			FileDelete, % file

			price := SubStr(output, 12)
			price := SubStr(price, 1, InStr(price, ",") - 1)
			
			ini_replaceValue(ini, "Prices", item, price)
		}
	}
	SplashTextOff
}

getItemId(input) {
	static itemIdList
	If !(itemIdList)
	{
		FileRead, itemIdList, % A_ScriptDir "\res\itemIds.json"
		If (ErrorLevel)	
		{
			msgbox Error reading item id list file! Closing..
			exitapp
		}
	}
	
	; make changes to input to match json file
	StringReplace, input, input, ', \u0027, All ; replace backticks with \u0027
	StringReplace, input, input, % " (", (, All ; remove space in for example Saradomin brew (4)
	
	loop, parse, itemIdList, `n
		If InStr(A_LoopField, """" input """")
		{
			match := A_Index - 1
			break
		}
	loop, parse, itemIdList, `n
		If (A_Index = match)
		{
			output := A_LoopField
			break
		}
	output := SubStr(output, InStr(output, ":") + 1)
	StringReplace, output, output, `,
	output := string_cleanUp(output)
	return output
}

logToFile(input) {
	FileAppend, % input "`n", % g_logFile
}

logToFileUndo() {
	FileRead, input, % g_logFile
	If !(input)
		return

	loop, parse, % input, `n ; remove empty lines & count lines
		If !(A_LoopField = "")
		{
			output .= A_LoopField "`n"
			lines++
		}
	input := output
	output := ""
	loop, parse, % input, `n ; add all lines into new var except last line
		If (A_Index = lines)
			break
		else
			output .= A_LoopField "`n"
	FileDelete, % g_logFile
	FileAppend, % output, % g_logFile
}



#IfWinActive, ahk_exe notepad++.exe
~^s::reload