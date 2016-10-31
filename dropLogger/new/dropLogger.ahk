#SingleInstance, force
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x202, "WM_LBUTTONUP")
OnExit, exitRoutine

global ini					; ini variable
global g_logFile			; log file path
global g_log				; log file contents
global g_mob				; selected boss
global g__guiLog_btnRedo	; global so log() can toggle button depending on if there are undone lines to be redone
global g__guiLog_btnStats	; global so guiStats can enable stats button in guiLog

loadSettings()
g_mob := "Abyssal Sire"
; getItemQuantity("Rune platebody")
guiLog()
; guiMain()
msgbox script end
return
#Include, %A_ScriptDir%\inc
#Include, guiMain.ahk
#Include, guiStats.ahk
#Include, guiLog.ahk
#Include, guiSettings.ahk

exitRoutine:
	If WinExist("Drop Logger Stats")
	{
		WinGetPos, guiStatsX, guiStatsY, , , Drop Logger Stats
		ini_replaceValue(ini, "Window Positions", "guiStatsX", guiStatsX)
		ini_replaceValue(ini, "Window Positions", "guiStatsY", guiStatsY)
	}

	ini_save(ini)
exitapp

loadSettings() {
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	; FileDelete, % iniFile
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		writeIni()
		ini_load(ini, iniFile)
	}
}

writeIni() {
	ini_insertSection(ini, "General")
		ini_insertKey(ini, "General", "mobList=")
		
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
	
	ini_insertSection(ini, "Drop Tables")
		ini_insertKey(ini, "Drop Tables", "rare drop table=45 x Law rune|45 x Death rune|67 x Nature rune|150 x Steel arrow|42 x Rune arrow|Uncut sapphire|Uncut emerald|Uncut ruby|Uncut diamond|Dragonstone|Runite bar|100 x Silver ore|3,000 x Coins|Chaos talisman|Nature talisman|Loop half of key|Tooth half of key|20 x Adamant javelin|5 x Rune javelin|Rune 2h sword|Rune battleaxe|Rune sq shield|Rune kiteshield|Dragon med helm|Rune spear|Shield left half|Dragon spear")

	ini_insertSection(ini, "Item Prices")
	
	updateMobList()
	ini_save(ini)
}

updatePrices(updateMissingPrices = "") {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving item prices..
	Loop, parse, % ini_getAllKeyNames(ini, "Item Prices"), `,
	{
		item := A_LoopField
		
		If (updateMissingPrices) and (ini_getValue(ini, "Item Prices", item)) {
			; do nothing
		}
		else
		{
			itemId := getItemId(item)
			
			If (itemId)
			{
				file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now A_TickCount ".txt"
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
	}
	If !(updateMissingPrices)
		ini_replaceValue(ini, "General", "lastPriceUpdate", A_Now)
	SplashTextOff
}

updateMobList() {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving mobs..
	
	loop, parse, % "http://2007.runescape.wikia.com/wiki/Category:Bosses,http://2007.runescape.wikia.com/wiki/Category:Slayer_Monsters", `,
	{
		input := urlToVar(A_LoopField)
		
		output := SubStr(input, InStr(input, "mw-pages"))
		output := SubStr(output, 1, InStr(output, "</tr></table></div>"))
		
		loop, parse, output, `n
			If InStr(A_LoopField, "title") and !InStr(A_LoopField, "/Strategies") and !InStr(A_LoopField, "Boss")
				MobList .= StringBetween(SubStr(A_LoopField, InStr(A_LoopField, "title=")), """", """") "`n"
	}
	Sort, MobList, CU ; c=case insensitive alphabetical u=remove duplicates
	
	output := ""
	loop, parse, MobList, `n
		output .= A_LoopField "|"
	output := RTrim(output, "|")
	
	ini_replaceValue(ini, "general", "mobList", output)
	
	SplashTextOff
}

updateMobDropTable(input) {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving mob drop table..

	StringReplace, inputUrl, input, % A_Space, _

	output := urlToVar("http://2007.runescape.wikia.com/wiki/" inputUrl)
	
	output := SubStr(output, InStr(output, "<dl><dd><table"))
	output := SubStr(output, 1, InStr(output, "</table></dd></dl>", , -1))
	
	If InStr(output, "Rare drop table</span></h3>")
	{
		output := SubStr(output, 1, InStr(output, "Rare drop table</span></h3>"))
		output_dropTable .= "rare drop table" "`n"
	}
	
	loop, parse, output, `n
	{
		If (itemFound)
			count++
		
		If InStr(A_LoopField, "link-internal")
		{
			drop := SubStr(A_LoopField, InStr(A_LoopField, "title"))
			drop := SubStr(drop, 1, InStr(drop, "<"))
			drop := StringBetween(drop, """", """")
			
			If InStr(drop, "&#39;")
				StringReplace, drop, drop, &#39;, `'
			
			getItemImg(drop)
			
			If !InStr(ini_getAllKeyNames(ini, "Item Prices"), drop)
				ini_insertKey(ini, "Item Prices", drop "=")
			
			itemFound := 1
		}
		
		If (count = 2)
		{
			itemFound := ""
			count = ""
			
			StringReplace, dropQuantity, A_LoopField, % "</td><td> "
			StringReplace, dropQuantity, dropQuantity, % " (noted)"
			
			If !(drop = "Rare drop table")
			{
				If InStr(dropQuantity, ";") or InStr(dropQuantity, "–")
					output_dropTable .= "custom x " drop "`n"
				else If (dropQuantity > 1)
					output_dropTable .= dropQuantity " x " drop "`n"
				else
					output_dropTable .= drop "`n"
			}
		}
	}
	
	output := ""
	loop, parse, output_dropTable, `n
		output .= A_LoopField "|"
	output := RTrim(output, "|")
	
	ini_replaceValue(ini, "Drop Tables", input, output)
	
	SplashTextOff, 200, 50, % A_ScriptName, Retrieving mob drop table..
}

getItemImg(input) {
	If FileExist(A_ScriptDir "\res\img\drops\" input ".gif")
		return
	
	file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now A_TickCount ".gif"
	
	itemId := getItemId(input)
	If (itemId)
	{
		UrlDownloadToFile, http://services.runescape.com/m=itemdb_oldschool/1477667736648_obj_big.gif?id=%itemId%, % file
		FileMove, % file, % A_ScriptDir "\res\img\drops\" input ".gif"
	}
	else
	{
		StringReplace, item, input, % A_Space, _
		output := urlToVar("http://2007.runescape.wikia.com/wiki/File:" item ".png")
		
		loop, parse, output, `n
			If InStr(A_LoopField, "og:image")
			{
				UrlDownloadToFile, % StringBetween(SubStr(A_LoopField, InStr(A_LoopField, "Content=")), """", """"), % file
				break
			}
		FileMove, % file, % A_ScriptDir "\res\img\drops\" input ".gif"
	}
}

getItemId(input) {
	static itemIdList
	If !(itemIdList)
	{
		FileRead, itemIdList, % A_ScriptDir "\res\itemIds.json" ; https://rsbuddy.com/exchange/summary.json
		If (ErrorLevel)	
		{
			msgbox Error reading item id list file! Closing..
			exitapp
		}
	}
	
	; make changes to input to match json file
	StringReplace, input, input, ', \u0027, All ; replace backticks with \u0027
	If InStr(input, "(")
	{
		loop, parse, input
			If A_LoopField is number
				containsNumber := 1
		
		If (containsNumber)
			StringReplace, input, input, % " (", (, All ; remove space in for example Saradomin brew (4)
	}
	
	loop, parse, itemIdList, `n
	{
		If (match) and InStr(A_LoopField, "id")
		{
			StringReplace, output, A_LoopField, "id": ,
			output := string_cleanUp(output)
			output := RTrim(output, ",")
			break
		}
		else If InStr(A_LoopField, """" input """")
			match := "found"
	}
	return output
}

urlToVar(url) {
	file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now ".txt"
	UrlDownloadToFile, % url, % file
	FileRead, output, % file
	FileDelete, % file
	
	If InStr(output, "was not found")
	{
		msgbox urlToVar(): Invalid url specified: %url% `n`nNote: wiki urls are case sensitive`n`nClosing..
		exitapp
	}
	
	return output
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

priceLookupNew(input) {
	static itemIdList
	If !(itemIdList)
	{
		FileRead, itemIdList, % A_ScriptDir "\res\itemIds_New2.json" ; https://rsbuddy.com/exchange/summary.json
		If (ErrorLevel)	
		{
			msgbox Error reading item id list file! Closing..
			exitapp
		}
	}
	
	; make changes to input to match json file
	StringReplace, input, input, ', \u0027, All ; replace backticks with \u0027
	If InStr(input, "(")
	{
		loop, parse, input
			If A_LoopField is number
				containsNumber := 1
		
		If (containsNumber)
			StringReplace, input, input, % " (", (, All ; remove space in for example Saradomin brew (4)
	}
	
	loop, parse, itemIdList, `n
	{
		If (match) and InStr(A_LoopField, "sell_average")
		{
			StringReplace, output, A_LoopField, "sell_average": ,
			output := string_cleanUp(output)
			output := RTrim(output, ",")
			break
		}
		else If InStr(A_LoopField, """" input """")
			match := "found"
	}
	return output
}

selectLogFile() {
	FileSelectFile, g_logFile, 11, , Select Log File, (*.txt)
	If (g_logFile = "")
		return
	SplitPath, g_logFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
	g_logFile := OutDir "\" OutNameNoExt ".txt"
	
	If !FileExist(g_logFile)
		FileAppend, , % g_logFile
	FileRead, g_log, % g_logFile
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
	selectedItem := getItemUnderMouse()
	If !(selectedItem)
		return
	
	If !(IsTripOnGoing())
	{
		tooltip No trip started!
		return
	}
	
	ControlGetText, existingItems, Edit2, % "Drop Logger -" 
	
	If !(existingItems)
		ControlSetText, Edit2, % getItemQuantity(selectedItem), % "Drop Logger -" 
	else
		ControlSetText, Edit2, % existingItems ", " getItemQuantity(selectedItem), % "Drop Logger -" 
}

getItemQuantity(input) {
	gui log: +OwnDialogs
	CoordMode, Mouse, Screen
	
	GuiControlGet, selectedTab, , SysTabControl321, % "Drop Logger -" 
	
	If (selectedTab = "Drop Table")
	{
		loop, parse, % ini_getValue(ini, "Drop Tables", g_mob), |
		{
			LoopField := A_LoopField
			
			If InStr(LoopField, "custom x ")
			{
				MouseGetPos, xx, yy
				xx -= 50
				yy -= 50
				InputBox, OutputVar, % A_ScriptName, , , 100, 103, % xx, % yy
				; InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default]
				
				If !(OutputVar)
					return
				If OutputVar is not integer
					return
				StringReplace, LoopField, LoopField, custom, % OutputVar
				return LoopField
			}
			else
			{
				If InStr(LoopField, " x ")
					LoopField := SubStr(LoopField, InStr(LoopField, " x ") + 3)
					
				If (LoopField = input)
					return A_LoopField
			}
			
		}
	}
	If (selectedTab = "Rare Drop Table")
	{
		loop, parse, % ini_getValue(ini, "Drop Tables", "rare drop table"), |
		{
			LoopField := A_LoopField
			If InStr(LoopField, " x ")
				LoopField := SubStr(LoopField, InStr(LoopField, " x ") + 3)
				
			If (LoopField = input)
				return A_LoopField
		}
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
	
	return OutNameNoExt
}

~^s::reload