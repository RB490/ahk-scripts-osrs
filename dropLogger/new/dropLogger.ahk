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
global itemsObj				; items object. contains item ids & prices from: https://rsbuddy.com/exchange/summary.json

loadSettings()
guiMain()
return
#Include, %A_ScriptDir%\inc
#Include, guiMain.ahk
#Include, guiStats.ahk
#Include, guiLog.ahk
#Include, guiSettings.ahk
#Include, guiDigitInputBox.ahk

exitRoutine:
	If WinExist("Drop Logger Stats")
	{
		WinGetPos, guiStatsX, guiStatsY, , , Drop Logger Stats
		ini_replaceValue(ini, "Window Positions", "guiStatsX", guiStatsX)
		ini_replaceValue(ini, "Window Positions", "guiStatsY", guiStatsY)
	}

	ini_save(ini)
exitapp

loadSettings(loadItemsObj = "") {
	If (loadItemsObj) {
		FileRead, itemsJson, % A_ScriptDir "\res\itemIds.json"
		itemsObj := Jxon_Load( itemsJson )
		return
	}

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
		ini_insertKey(ini, "General", "mobList=Aberrant spectre|Abhorrent spectre|Abyssal Sire|Abyssal demon|Al-Kharid warrior|Ankou|Aviansie|Baby blue dragon|Baby green dragon|Balfrug Kreeyath|Banshee|Barbarian|Basilisk|Bat|Black Knight|Black bear|Black demon|Black dragon|Black unicorn|Bloodveld|Blue dragon|Bree|Brine rat|Bronze dragon|Callisto|Catablepon|Cave abomination|Cave bug|Cave crawler|Cave horror|Cave kraken|Cave slime|Cerberus|Chaos Elemental|Chaos Fanatic|Chaos druid|Chaos dwarf|Chasm Crawler|Choke devil|Chronozon|Cockatrice|Commander Zilyana|Corporeal Beast|Crawling Hand|Crazy archaeologist|Crocodile|Crushing Hand|Cyclops|Dagannoth (Lighthouse)|Dagannoth Prime|Dagannoth Rex|Dagannoth Supreme|Dark beast|Demonic gorilla|Desert Lizard|Deviant spectre|Dust devil|Earth warrior|Elder Chaos druid|Fever spider|Fire giant|Fiyr Shade|Flaming pyrelord|Flesh Crawler|Flight Kilisa|Flockleader Geerin|Gangster|Gargoyle|General Graardor|Ghoul|Giant Mole|Giant bat|Giant rockslug|Glod|Gnome guard|Gorak|Greater Nechryael|Greater abyssal demon|Greater demon|Green dragon|Growler|Guard dog|Harpie Bug Swarm|Hellhound|Hill giant|Hobgoblin|Ice troll grunt|Icefiend|Infernal Mage|Insatiable Bloodveld|Insatiable mutated Bloodveld|Jogre|K'ril Tsutsaroth|Kalphite Queen|King Black Dragon|King Scorpion|King kurask|Knight of Saradomin|Kraken|Kree'arra|Kurask|Lava dragon|Lesser demon|Lizard|Lizardman|Lizardman brute|Magic axe|Malevolent Mage|Mammoth|Marble gargoyle|Minotaur|Mogre|Molanisk|Monkey Guard|Moss giant|Mountain troll|Mutated Bloodveld|Nechryael|Nechryarch|Night beast|Nuclear smoke devil|Ogre|Otherworldly being|Phrin Shade|Pyrefiend|Red dragon|Repugnant spectre|Riyl Shade|Rockslug|Salarin the Twisted|Scorpia|Scorpion|Screaming banshee|Sea Snake Young|Seagull|Sergeant Grimspike|Sergeant Steelwill|Sergeant Strongstack|Skeletal Wyvern|Smoke devil|Spiritual mage|Spiritual ranger|Spiritual warrior|Starlight|Suqah|Terror dog|Thermonuclear smoke devil|Tree spirit|Tstanon Karlak|Turoth|Twisted Banshee|Unicow|Vampire|Venenatis|Vet'ion|Vitreous Jelly|Wall beast|Warped Jelly|Waterfiend|Werewolf|Wingman Skree|Yak|Zakl'n Gritch|Zamorak wizard|Zombie (random event)|Zulrah|Zygomite")
		ini_insertKey(ini, "General", "lastItemDatabaseUpdate=" . "")
		ini_insertKey(ini, "General", "lastMobListUpdate=" . "20161031123901")
		ini_insertKey(ini, "General", "lastDropTableUpdate=" . "20161031142734")
		
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "autoOpenStats=" . "0")
	
	ini_insertSection(ini, "Window Positions")
		ini_insertKey(ini, "Window Positions", "guiLogX=" . "")
		ini_insertKey(ini, "Window Positions", "guiLogY=" . "")
		ini_insertKey(ini, "Window Positions", "guiStatsX=" . "")
		ini_insertKey(ini, "Window Positions", "guiStatsY=" . "")
		ini_insertKey(ini, "Window Positions", "guiSettingsX=" . "")
		ini_insertKey(ini, "Window Positions", "guiSettingsY=" . "")
	
	ini_insertSection(ini, "Drop Tables")
		FileRead, dropTables, % A_ScriptDir "\inc\dropTables.txt"
		ini .= dropTables
	
	updateItemDatabase()
	ini_save(ini)
}

updateMobList() {
	SplashTextOn, 200, 50, % A_ScriptName, Retrieving mobs..
	
	loop, parse, % "http://2007.runescape.wikia.com/wiki/Category:Monsters,http://2007.runescape.wikia.com/wiki/Category:Slayer_Monsters,http://2007.runescape.wikia.com/wiki/Category:Bosses,http://2007.runescape.wikia.com/wiki/Category:Demons", `,
	{
		input := urlToVar(A_LoopField)
		
		output := SubStr(input, InStr(input, "mw-pages"))
		output := SubStr(output, 1, InStr(output, "</tr></table></div>"))
		
		loop, parse, output, `n
			If InStr(A_LoopField, "title") and !InStr(A_LoopField, "/Strategies") and !InStr(A_LoopField, "Boss")
			{
				mob := StringBetween(SubStr(A_LoopField, InStr(A_LoopField, "title=")), """", """")
				StringReplace, mobNoSpaces, mob, % A_Space, _
				output := urlToVar("http://2007.runescape.wikia.com/wiki/" mobNoSpaces)
				loop, parse, output, `n
					If InStr(A_LoopField, "Drops</span>") and InStr(A_LoopField, "mw-headline")
					{
						MobList .= mob "`n"
						break
					}
			}
	}
	Sort, MobList, CU ; c=case insensitive alphabetical u=remove duplicates
	
	output := ""
	loop, parse, MobList, `n
		output .= A_LoopField "|"
	output := RTrim(output, "|")
	
	ini_replaceValue(ini, "general", "mobList", output)
	
	ini_replaceValue(ini, "General", "lastMobListUpdate", A_Now)
	
	SplashTextOff
}

updateMobListDropTables() {
	loop, parse, % ini_getValue(ini, "General", "mobList"), |
		updateMobDropTable(A_LoopField)
	
	ini_replaceValue(ini, "General", "lastDropTableUpdate", A_Now)
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
	If (input = "Abyssal Sire")
		loop, parse, % "Abyssal head|Abyssal orphan|Abyssal dagger|Abyssal whip|Bludgeon claw|Bludgeon spine|Bludgeon axon|Jar of miasma", |
		{
			output_dropTable .= A_LoopField "`n"
			getItemImg(A_LoopField)
		}
	
	; remove output_dropTable duplicates
	loop, parse, output_dropTable, `n
	{
		quantity := 1
		item := A_LoopField
		If InStr(A_LoopField, " x ")
		{
			quantity := SubStr(A_LoopField, 1, InStr(A_LoopField, " x ") - 1)
			item := SubStr(A_LoopField, InStr(A_LoopField, " x ") + 3)
		}
		existsInOutput := ""
		loop, parse, output_new, `n
			If (SubStr(A_LoopField, InStr(A_LoopField, " x ") + 3) = item)
				existsInOutput := 1
		If !(existsInOutput)
			output_new .= A_LoopField "`n"
	}
	output_dropTable := output_new

	; format output_dropTable
	output := ""
	loop, parse, output_dropTable, `n
		output .= A_LoopField "|"
	output := RTrim(output, "|")
	
	If !InStr(ini_getAllKeyNames(ini, "Drop Tables"), input "=" )
		ini_insertKey(ini, "Drop Tables", input "=")
	ini_replaceValue(ini, "Drop Tables", input, output)
	
	SplashTextOff, 200, 50, % A_ScriptName, Retrieving mob drop table..
}

getItemImg(input) {
	If FileExist(A_ScriptDir "\res\img\items\" input ".gif")
		return
	
	file := A_Temp "\_" A_ScriptName A_ScriptHwnd A_Now A_TickCount ".gif"
	
	itemId := getItemId(input)
	If (itemId)
	{
		UrlDownloadToFile, http://services.runescape.com/m=itemdb_oldschool/1477667736648_obj_big.gif?id=%itemId%, % file
		FileMove, % file, % A_ScriptDir "\res\img\items\" input ".gif"
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
		FileMove, % file, % A_ScriptDir "\res\img\items\" input ".gif"
	}
}

getItemId(input) {
	If InStr(input, " (") ; change to input to match json file: remove space in for example Saradomin brew (4)
	{
		loop, parse, input
		{
			If A_LoopField is integer
			{
				StringReplace, input, input, % " (", (, All
				break
			}
		}
	}
	for itemId in itemsObj {
		If (itemsObj[itemId].name = input)
			return itemsObj[itemId].id
	}
}

priceLookup(input) {
	quantity := 1
	item := input
	If InStr(input, " x ")
	{
		quantity := SubStr(input, 1, InStr(input, " x ") - 1)
		item := SubStr(input, InStr(input, " x ") + 3)
	}
	
	If InStr(input, " (") ; change to input to match json file: remove space in for example Saradomin brew (4)
	{
		loop, parse, input
		{
			If A_LoopField is integer
			{
				StringReplace, input, input, % " (", (, All
				break
			}
		}
	}
	for itemId in itemsObj {
		If (itemsObj[itemId].name = item)
		{
			price := itemsObj[itemId].sell_average
			break
		}
	}
	If (item = "Coins")
		price := 1

	output := price * quantity
	
	return output
}

updateItemDatabase() {
	SplashTextOn, 200, 50, % A_ScriptName, Updating item database..

	FileDelete, % A_ScriptDir "\res\itemIds.json" 
	FileAppend, % urlToVar("https://rsbuddy.com/exchange/summary.json"), % A_ScriptDir "\res\itemIds.json" 
	
	ini_replaceValue(ini, "General", "lastItemDatabaseUpdate", A_Now)
	
	SplashTextOff
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
		ToolTip, % getItemQuantity(input)
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
	
	selectedItem := getItemQuantity(selectedItem)
	If InStr(selectedItem, "custom x ")
	{
		MouseGetPos, , , WhichWindow, WhichControl
		ControlGetPos, xCtrl, yCtrl, , , %WhichControl%, ahk_id %WhichWindow%
		WinGetPos, xWin, yWin, , , ahk_id %WhichWindow%
		xx := xWin + xCtrl + 1
		yy := yWin + yCtrl + 1
		output := guiDigitInputBox(xx, yy)
		If !(output)
			return
		StringReplace, selectedItem, selectedItem, custom, % output
	}
	
	If !(existingItems)
		ControlSetText, Edit2, % selectedItem, % "Drop Logger -" 
	else
		ControlSetText, Edit2, % existingItems ", " selectedItem, % "Drop Logger -" 
}

getItemQuantity(input) {
	GuiControlGet, selectedTab, , SysTabControl321, % "Drop Logger -" 
	
	If (selectedTab = "Drop Table")
	{
		loop, parse, % ini_getValue(ini, "Drop Tables", g_mob), |
		{
			output := A_LoopField
			If InStr(A_LoopField, " x ")
				output := SubStr(A_LoopField, InStr(A_LoopField, " x ") + 3)
			If (output = input)
			{
				output := A_LoopField
				break
			}
		}
	}
	If (selectedTab = "Rare Drop Table")
	{
		loop, parse, % ini_getValue(ini, "Drop Tables", "rare drop table"), |
		{
			output := A_LoopField
			If InStr(A_LoopField, " x ")
				output := SubStr(A_LoopField, InStr(A_LoopField, " x ") + 3)
			If (output = input)
			{
				output := A_LoopField
				break
			}
		}
	}
	
	return output
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

#IfWinActive, ahk_exe Notepad++.exe
~^s::reload