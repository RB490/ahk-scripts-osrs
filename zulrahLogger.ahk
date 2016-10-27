#SingleInstance, force
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x202, "WM_LBUTTONUP")

OnExit, exitRoutine

global g_logFile			; log file path
global g_log				; log file contents
global ini					; ini variable
global g__guiLog_btnRedo	; global so log() can toggle button depending on if there are undone lines to be redone
global g__guiLog_btnStats	; global so guiStats can enable stats button in guiLog

loadSettings()
selectLogFile()
guiLog()
return

exitRoutine:
	If WinExist("Zulrah Logger Stats")
	{
		WinGetPos, guiStatsX, guiStatsY, , , Zulrah Logger Stats
		ini_replaceValue(ini, "Window Positions", "guiStatsX", guiStatsX)
		ini_replaceValue(ini, "Window Positions", "guiStatsY", guiStatsY)
	}
	
	ini_save(ini)
	exitapp
return

selectLogFile() {
	FileSelectFile, g_logFile, 11, , Select Log File, (*.txt)
	If (g_logFile = "")
		exitapp
	SplitPath, g_logFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	g_logFile := OutDir "\" OutNameNoExt ".txt"
	
	If !FileExist(g_logFile)
		FileAppend, , % g_logFile
	FileRead, g_log, % g_logFile
}

loadSettings() {
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		writeIni()
		ini_load(ini, iniFile)
	}
}

writeIni() {
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "averageBaseScales=" . "175")
		ini_insertKey(ini, "Settings", "lastPriceUpdate=" . "")
		ini_insertKey(ini, "Settings", "autoOpenStats=" . "0")
		
	ini_insertSection(ini, "Window Positions")
		ini_insertKey(ini, "Window Positions", "guiLogX=" . "")
		ini_insertKey(ini, "Window Positions", "guiLogY=" . "")
		ini_insertKey(ini, "Window Positions", "guiStatsX=" . "")
		ini_insertKey(ini, "Window Positions", "guiStatsY=" . "")
		ini_insertKey(ini, "Window Positions", "guiSettingsX=" . "")
		ini_insertKey(ini, "Window Positions", "guiSettingsY=" . "")
		
	ini_insertSection(ini, "Item Prices")
		Loop, % A_ScriptDir "\res\img\drops\*.*", 0, 1
		{
			SplitPath, A_LoopFileFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt
			ini_insertKey(ini, "Item Prices", OutNameNoExt "=" . "")
		}
		updatePrices()
	
	ini_save(ini)
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

	price := ini_getValue(ini, "Item Prices", item)
	If (item = "Coins")
		price := 1

	output := price * quantity
	
	return output
}

updatePrices() {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving item prices..
	Loop, % A_ScriptDir "\res\img\drops\*.*", 0, 1
	{
		SplitPath, A_LoopFileFullPath, OutFileName, OutDir, OutExtension, OutNameNoExt
		
		item := OutNameNoExt
		itemId := getItemId(item)
		If (itemId)
		{
			file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now ".txt"
			UrlDownloadToFile, https://api.rsbuddy.com/grandExchange?a=guidePrice&i=%itemId%, % file
			FileRead, output, % file
			FileDelete, % file

			price := SubStr(output, 12)
			price := SubStr(price, 1, InStr(price, ",") - 1)
			
			ini_replaceValue(ini, "Item Prices", item, price)
		}
		If (item = "Coins")
			ini_replaceValue(ini, "Item Prices", item, 1)
	}
	ini_replaceValue(ini, "Settings", "lastPriceUpdate", A_Now)
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

guiLog(action = "") {
	static _btnSettings, _btnUndo, _btnTrip, _btnNewTrip, _btnLogKill, _logDisplay, _dropsDisplay, killsThisTrip, tripTimerRunning, tripStartTime
	
	autoOpenStats := ini_getValue(ini, "Settings", "autoOpenStats")
	guiLogX := ini_getValue(ini, "Window Positions", "guiLogX")
	guiLogY := ini_getValue(ini, "Window Positions", "guiLogY")
	
	DetectHiddenWindows, On
	
	If WinExist("Zulrah Logger") and (action = "refresh")
	{
		Gosub guiLog_refresh
		return
	}
	
	If WinExist("Zulrah Logger") and (action = "logKill")
	{
		Gosub guiLog_kill
		return
	}
	
	If !WinExist("Zulrah Logger")
	{
		; properties^
		Gui log: New, +LabelguiLog_
		Gui log: +LastFound
		Gui log: Margin, 5, 5
		
		; controls
		iconWidth = 25
		iconHeight = 25
		
		Gui log: add, button, w150 r2 section hwnd_btnTrip gguiLog_trip
		Gui log: add, button, x+5 w150 r2 section hwnd_btnNewTrip gguiLog_newTrip, New trip
		
		Gui log: add, edit, x5 w305 r20 ReadOnly hwnd_logDisplay
		
		Gui log: add, button, x5 w50 r1 hwnd_btnSettings gguiLog_settings, Settings
		Gui log: add, button, x+5 w50 r1 hwndg__guiLog_btnStats gguiLog_stats, Stats
		Gui log: add, button, x+5 w95 r1 hwnd_btnUndo gguiLog_undo, Undo
		Gui log: add, button, x+5 w95 r1 gguiLog_redo hwndg__guiLog_btnRedo Disabled, Redo
		
		Gui log: Add, Button, xs+155 ys w370 section r2 hwnd_btnLogKill gguiLog_kill, + Kill (enter)
		
		Gui log: Add, Tab2, xs w370 h268 section, Drop Table|Rare Drop Table
		
		Gui log: Tab, Drop Table
		
		Gui log: Add, Text, section, Misc
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Zul-andra teleport.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dragon bones.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Coconut.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Grapes.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Zulrah's scales.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Battlestaff.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Antidote++ (4).png"
		Gui log: Add, Text, xs+30 ys section
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Raw shark.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Mahogany plank.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Swamp tar.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Saradomin brew (4).png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Adamantite bar.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Clue scroll (elite).png"
		Gui log: Add, Text, xs+30 ys section
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Flax.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Snakeskin.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dragon bolt tips.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Magic logs.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Coal.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Runite ore.png"
		
		Gui log: Add, Text, xs+40 ys section, Seeds
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Magic seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Calquat tree seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Papaya tree seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Palm tree seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Toadflax seed.png"
		Gui log: Add, Text, xs+30 ys section
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Snapdragon seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dwarf weed seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Torstol seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Spirit seed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Crystal seed.png"
		
		Gui log: Add, Text, xs+40 ys section, Herbs
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Toadflax.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Snapdragon.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dwarf weed.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Torstol.png"
		
		Gui log: Add, Text, xs+40 ys section, Runes
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Law rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Death rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Chaos rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Pure essence.png"
		
		Gui log: Add, Text, xs+40 ys section, Rare
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Tanzanite fang.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Magic fang.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Serpentine visage.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Uncut onyx.png"
		Gui log: Add, Text, xs+30 ys section
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Jar of swamp.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Pet snakeling.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Tanzanite mutagen.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Magma mutagen.png"
		
		Gui log: Add, Text, xs+40 ys section, Gear
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dragon med helm.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\zulrah\Dragon halberd.png"
		
		Gui log: Tab, Rare Drop Table
		
		Gui log: Add, Text, section, Misc
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Coins.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Tooth half of key.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Loop half of key.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Shield left half.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Silver ore.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Runite bar.png"
		
		Gui log: Add, Text, xs+40 ys section, Gear
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Dragon med helm.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Dragon spear.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune spear.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune 2h sword.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune battleaxe.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune sq shield.png"
		Gui log: Add, Text, xs+30 ys section
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune kiteshield.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune arrow.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Steel arrow.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Adamant javelin.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Rune javelin.png"
		
		Gui log: Add, Text, xs+40 ys section, Runes
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Death rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Law rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Nature rune.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Chaos talisman.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Nature talisman.png"
		
		Gui log: Add, Text, xs+40 ys section, Gems
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Dragonstone.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Uncut diamond.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Uncut ruby.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Uncut emerald.png"
		Gui log: Add, Picture, w%iconWidth% h%iconHeight% AltSubmit 0x1000, % A_ScriptDir "\res\img\drops\rare drop table\Uncut sapphire.png"
		
		Gui log: Tab
		
		Gui log: Add, Edit, x315 y320 w316 r1 ReadOnly hwnd_dropsDisplay
		Gui log: Add, Button, x+5 yp-1 w50 gguiLog_clearDrops, Clear
		
		Gui log: Tab
	}
	
	; show
	If (guiLogX) and (guiLogY)
		Gui log: show, % "x" guiLogX " y" guiLogY " AutoSize", % "Zulrah Logger - " g_logFile
	else
		Gui log: show, AutoSize, % "Zulrah Logger - " g_logFile
	
	Gosub guiLog_refresh
	
	ControlSend, , ^{end}, % "ahk_id " _logDisplay
	
	If (autoOpenStats)
		Gosub guiLog_stats
	
	; close
	DetectHiddenWindows, Off
	WinWaitClose, % "Zulrah Logger - " g_logFile
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
			
			Gui log: show, NoActivate, % "Zulrah Logger - " g_logFile
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
			Gui log: show, NoActivate, % "Zulrah Logger - " g_logFile " - " TripTimeInSecondsFormatted " #" killsThisTrip
		else
			Gui log: show, NoActivate, % "Zulrah Logger - " g_logFile " - " TripTimeInSecondsFormatted
	return
	
	guiLog_close:
		WinGetPos, guiLogX, guiLogY, , , Zulrah Logger
		ini_replaceValue(ini, "Window Positions", "guiLogX", guiLogX)
		ini_replaceValue(ini, "Window Positions", "guiLogY", guiLogY)
		exitapp
	return
}

guiSettings() {
	static _autoOpenStatsCheckbox, _averageBaseScalesDisplay, _lastPriceUpdateDisplay
	
	autoOpenStats := ini_getValue(ini, "Settings", "autoOpenStats")
	guiSettingsX := ini_getValue(ini, "Window Positions", "guiSettingsX")
	guiSettingsY := ini_getValue(ini, "Window Positions", "guiSettingsY")
	
	; properties
	Gui settings: New, +LastFound
	Gui settings: Margin, 5, 5
	Gui settings: +LabelguiSettings_
	
	; controls
	Gui settings: Add, Checkbox, checked%autoOpenStats% hwnd_autoOpenStatsCheckbox, Show stats on startup
	
	Gui settings: Add, Text, xs w90 section, Average base scales drop
	Gui settings: Add, Edit, x+5 yp+5 w75 Number hwnd_averageBaseScalesDisplay
	Gui settings: Add, UpDown, Range0-999
	GuiControl settings: , % _averageBaseScalesDisplay, % ini_getValue(ini, "Settings", "averageBaseScales") ; updown control sets value to 0
	
	Gui settings: Add, Button, xs gguiSettings_updatePrices, Update prices
	If (ini_getValue(ini, "Settings", "lastPriceUpdate"))
		FormatTime, lastPriceUpdate_formatted, % ini_getValue(ini, "Settings", "lastPriceUpdate"), dd/MM/yyyy @ HH:mm:ss
	Gui settings: Add, Text, x+5 yp+5 w200 hwnd_lastPriceUpdateDisplay, % "Last updated: " lastPriceUpdate_formatted
	
	Gui settings: Add, Button, x250 y5 gguiSettings_resetLog, Reset log
	
	Gui settings: Add, Button, xs w300 gguiSettings_save, Save
	
	; show
	If (guiSettingsX) and (guiSettingsY)
		Gui settings: show, % "x" guiSettingsX " y" guiSettingsY " AutoSize", Zulrah Logger Settings
	else
		Gui settings: show, AutoSize, Zulrah Logger Settings
	
	; close
	WinWaitClose, Zulrah Logger Settings
	return
	
	guiSettings_updatePrices:
		Gui settings: +Disabled
		updatePrices()
		Gui settings: -Disabled
		
		FormatTime, lastPriceUpdate_formatted, % ini_getValue(ini, "Settings", "lastPriceUpdate"), dd/MM/yyyy @ HH:mm:ss
		GuiControl settings: , % _lastPriceUpdateDisplay, % "Last updated: " lastPriceUpdate_formatted
	return
	
	guiSettings_save:
		ControlGetText, averageBaseScales, , % "ahk_id " _averageBaseScalesDisplay
		ini_replaceValue(ini, "Settings", "averageBaseScales", averageBaseScales)
		
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
		WinGetPos, guiSettingsX, guiSettingsY, , , Zulrah Logger Settings
		ini_replaceValue(ini, "Window Positions", "guiSettingsX", guiSettingsX)
		ini_replaceValue(ini, "Window Positions", "guiSettingsY", guiSettingsY)
		Gui settings: Destroy
	return
}

guiStats(refresh = "") {
	static guiStats_lv, guiStats_miscLv, guiStats_miscLvSelectedRow
	
	If (refresh) and WinExist("Zulrah Logger Stats")
	{
		Gosub guiStats_refresh
		return
	}
	If (refresh) and !WinExist("Zulrah Logger Stats")
		return

	guiStatsX := ini_getValue(ini, "Window Positions", "guiStatsX")
	guiStatsY := ini_getValue(ini, "Window Positions", "guiStatsY")
	
	; properties
	Gui stats: default
	Gui stats: +LabelguiStats_
	Gui stats: Margin, 5, 5

	; controls
	Gui stats: Add, ListView, w160 r12 NoSortHdr vguiStats_lv, Description|Value
	Gui stats: Add, ListView, x+5 w630 r12 vguiStats_miscLv gguiStats_miscLv AltSubmit, Drop|Amount|Value|Drop rate|Kills since last drop|Shortest dry streak|Longest dry streak
	
	Gosub guiStats_refresh
	
	; show
	If (guiStatsX) and (guiStatsY)
		Gui stats: show, % "x" guiStatsX " y" guiStatsY " AutoSize NoActivate", Zulrah Logger Stats
	else
		Gui stats: show, AutoSize NoActivate, Zulrah Logger Stats
	return
	
	guiStats_miscLv:
		If (A_GuiEvent = "Normal") or (A_GuiEvent = "DoubleClick")
			guiStats_miscLvSelectedRow := A_EventInfo
	return
	
	guiStats_refresh:
		total_kills := 0
		total_trips := 0
		
		loop, parse, g_log, `n
		{
			If !(A_LoopField)
				break
				
			If InStr(A_LoopField, "Start Trip")
				total_trips++
			
			If !InStr(A_LoopField, "Trip")
			{
				total_kills++
				
				loop, parse, % string_cleanUp(SubStr(A_LoopField, InStr(A_LoopField, ". ") + 2)), `,
				{
					LoopField := string_cleanUp(A_LoopField)
					total_drops .= LoopField "`n"
					total_dropValue += priceLookup(LoopField)
				}
			}
				
			If InStr(A_LoopField, "Start Trip")
			{
				StringReplace, tripStart, A_LoopField, Start Trip -
				tripStart := string_cleanUp(tripStart)
				tripStart := ReFormatTime( tripStart, "DD MM YYYY HH MI SS", "/@:")
			}
			
			If InStr(A_LoopField, "End Trip")
			{
				StringReplace, tripEnd, A_LoopField, End Trip -
				tripEnd := string_cleanUp(tripEnd)
				tripEnd := ReFormatTime( tripEnd, "DD MM YYYY HH MI SS", "/@:")
			}
			
			If (tripStart) and (tripEnd)
			{
				EnvSub, tripEnd, tripStart, Seconds
				total_TripTimeInSeconds += tripEnd
				tripEnd := ""
				tripStart := ""
			}
		}
		
		currentTripTimeInSeconds := A_Now
		EnvSub, currentTripTimeInSeconds, tripStart, seconds
		total_TripTimeInSeconds += currentTripTimeInSeconds
		
		total_dropValue += total_kills * (priceLookup("Zulrah's scales") * ini_getValue(ini, "Settings", "averageBaseScales"))
		total_uniqueDrops := string_removeDuplicates(total_drops)
		
		average_killsPerTrip := total_kills / total_trips
		average_timePerTripInSeconds := total_TripTimeInSeconds / total_trips
		average_dropValue := total_dropValue / total_kills
		average_tripsPerHour := 3600 / average_timePerTripInSeconds
		average_killsPerHour := average_tripsPerHour * average_killsPerTrip
		average_dropValuePerHour := average_killsPerHour * average_dropValue
		
		total_TripTimeInSecondsFormatted := A_YYYY A_MM A_DD 00 00 00
		EnvAdd, total_TripTimeInSecondsFormatted, total_TripTimeInSeconds, Seconds
		FormatTime, total_TripTimeInSecondsFormatted, % total_TripTimeInSecondsFormatted, HH:mm:ss
		
		average_timePerTripInSecondsFormatted := A_YYYY A_MM A_DD 00 00 00
		EnvAdd, average_timePerTripInSecondsFormatted, average_timePerTripInSeconds, Seconds
		FormatTime, average_timePerTripInSecondsFormatted, % average_timePerTripInSecondsFormatted, HH:mm:ss
		
		Gosub guiStats_refreshLv
		Gosub guiStats_refreshMiscLv
	return
	
	guiStats_refreshLv:
		Gui stats: default
		Gui stats: Listview, guiStats_lv
		GuiControl stats: -Redraw, guiStats_lv
		LV_Delete()
		
		LV_Add(, "-- Total --")
		LV_Add(, "Kills", total_kills)
		LV_Add(, "Trips", total_trips)
		LV_Add(, "Time", total_TripTimeInSecondsFormatted)
		LV_Add(, "Drop value", ThousandsSep(Round(total_dropValue)))
		LV_Add(, "-- Average --")
		LV_Add(, "Kills per trip", Round(average_killsPerTrip, 2))
		LV_Add(, "Time per trip", average_timePerTripInSecondsFormatted)
		LV_Add(, "Drop value", ThousandsSep(Round(average_dropValue)))
		LV_Add(, "Kills/hour", Round(average_killsPerHour, 2))
		LV_Add(, "Trips/hour", Round(average_tripsPerHour, 2))
		LV_Add(, "Income/hour", ThousandsSep(Round(average_dropValuePerHour)))
		
		LV_ModifyCol(1, "AutoHDR")
		LV_ModifyCol(2, "AutoHDR")
		GuiControl stats: +Redraw, guiStats_lv
	return
	
	guiStats_refreshMiscLv:
		Gui stats: Listview, guiStats_miscLv
		GuiControl stats: -Redraw, guiStats_miscLv
		LV_Delete()
		
		loop, parse, total_uniqueDrops, `n
		{
			If !(A_LoopField)
				break
			; item
			item := A_LoopField
			
			; amount
			itemAmount := ""
			loop, parse, total_drops, `n
			{
				If !(A_LoopField)
					break
				If (A_LoopField = item)
					itemAmount++
			}
			
			; value
			value := itemAmount * priceLookup(item)
			
			; drop rate
			dropRate := Round(total_kills / itemAmount)
			
			; kills since last drop
			killsSinceLastDrop := ""
			loop, parse, g_log, `n
			{
				If !(A_LoopField)
					break
				
				If !InStr(A_LoopField, "trip")
				{
					If InStr(A_LoopField, item)
						killsSinceLastDrop := 0
					else
						killsSinceLastDrop++
				}
			}
			
			; dry streaks
			dryStreak := ""
			dryStreakOutput := ""
			itemFound := ""
			loop, parse, g_log, `n
			{
				If !(A_LoopField)
					break
				
				If !InStr(A_LoopField, "Trip")
				{
					If InStr(A_LoopField, item) and (itemFound)
					{
						If !(dryStreak)
							dryStreak := 0
						dryStreakOutput .= dryStreak "`n"
						dryStreak := 0
					}
					else
						dryStreak++
						
					If InStr(A_LoopField, item)
						itemFound := 1
				}
			}
			
			shortestDryStreak := ""
			Sort, dryStreakOutput, N ; low to high
			loop, parse, dryStreakOutput, `n
			{
				shortestDryStreak := A_LoopField
				break
			}
			
			dryStreaksOutput .= dryStreak "`n" ; add drystreak since most recent drop after shortest dry streak is retrieved
			
			Sort, dryStreakOutput, NR ; high to low
			
			longestDryStreak := ""
			loop, parse, dryStreakOutput, `n
			{
				longestDryStreak := A_LoopField
				break
			}
			
			LV_Add(, A_LoopField, itemAmount, value, dropRate, killsSinceLastDrop, shortestDryStreak, longestDryStreak)
		}
		
		LV_ModifyCol(1, "AutoHDR")
		LV_ModifyCol(2, "AutoHDR")
		LV_ModifyCol(3, "AutoHDR")
		LV_ModifyCol(4, "AutoHDR")
		LV_ModifyCol(5, "AutoHDR")
		LV_ModifyCol(6, "AutoHDR")
		LV_ModifyCol(7, "AutoHDR")
		
		LV_ModifyCol(2, "Integer")
		LV_ModifyCol(3, "Integer")
		LV_ModifyCol(4, "Integer")
		LV_ModifyCol(5, "Integer")
		LV_ModifyCol(6, "Integer")
		LV_ModifyCol(7, "Integer")
		
		LV_ModifyCol(3, "SortDesc")
		
		LV_Modify(guiStats_miscLvSelectedRow, "Vis")
		
		GuiControl stats: +Redraw, guiStats_miscLv
	return
	
	guiStats_close:
		WinGetPos, guiStatsX, guiStatsY, , , Zulrah Logger Stats
		ini_replaceValue(ini, "Window Positions", "guiStatsX", guiStatsX)
		ini_replaceValue(ini, "Window Positions", "guiStatsY", guiStatsY)
		Gui stats: Destroy
		GuiControl log: Enable, % g__guiLog_btnStats
	return
}

log(action, input = "") {
	static output_undone
	
	If (action = "append") and (input)
	{
		FileAppend, % input "`n", % g_logFile
		g_log .= input "`n"
		
		output_undone := ""
	}
	
	If (action = "undo") and (g_log)
	{
		loop, parse, g_log, `n
			If (A_LoopField)
				lines++
				
		loop, parse, g_log, `n
		{
			If !(A_LoopField)
				break
				
			If (A_Index = lines)
			{
				output_undone := A_LoopField "`n" output_undone
				break
			}
			
			output .= A_LoopField "`n"
		}
		g_log := output
		FileDelete, % g_logFile
		FileAppend, % g_log, % g_logFile
	}
	
	If (action = "redo") and (output_undone)
	{
		; redo undone line
		loop, parse, output_undone, `n
		{
			If !(A_LoopField)
				break
				
			FileAppend, % A_LoopField "`n", % g_logFile
			g_log .= A_LoopField "`n"
			break
		}
		
		; remove undone line from var
		loop, parse, output_undone, `n
		{
			If !(A_LoopField)
				break
			If !(A_Index = 1)
				output .= A_LoopField "`n"
		}
		
		output_undone := output
	}
	
	guiLog("refresh")
	guiStats("refresh")
	
	If (output_undone)
		GuiControl log: Enable, % g__guiLog_btnRedo
	else
		GuiControl log: Disable, % g__guiLog_btnRedo
}

IsTripOnGoing() {
	If !(g_log)
		return output := 0
	
	loop, parse, g_log, `n
	{
		If InStr(A_LoopField, "start")
			output := 1
		If InStr(A_LoopField, "end")
			output := 0
	}	
	return output
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
		If (priceLookup(input))
			ToolTip, % input " (" ThousandsSep(priceLookup(input)) ") "
		else
			ToolTip, % input
		oldInput := input
	}
}

WM_LBUTTONUP() {
	selectedItem := getItemUnderMouse()
	If !(selectedItem)
		return
	
	If !(IsTripOnGoing())
	{
		tooltip No trip started!
		return
	}
	
	ControlGetText, existingItems, Edit2, % "Zulrah Logger -" 
	
	If !(existingItems)
		ControlSetText, Edit2, % selectedItem, % "Zulrah Logger -" 
	else
	{
		ControlSetText, Edit2, % existingItems ", " selectedItem, % "Zulrah Logger -" 
		; guiLog("logKill") ; if expanding script to support multiple bosses create setting that will auto submit kill after x amount of drops have been selected
	}
}

getItemUnderMouse() {
	MouseGetPos, , , hwnd, control
	If !(control) or !InStr(control, "Static")
		return
	
	ControlGetText, output, % control, % "ahk_id " hwnd
	SplitPath, output, , , OutExt, OutNameNoExt
	If !(OutExt) ; something else besides an image was selected
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
		output := 3000
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

#IfWinActive, ahk_exe Notepad++.exe
~^s::reload