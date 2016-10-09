#SingleInstance, force
#Persistent
OnExit, exitRoutine
Gosub loadSettings
; g_logFile := "e:\downloads\tet.txt"
guiIntro()
guiMain()
return

loadSettings:
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		Gosub writeIni
		ini_load(ini, iniFile)
	}
	
	iniWrapper_loadAllSections(ini)
	
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
	
	nullTime := A_YYYY A_MM A_DD "000000"
return

saveSettings:
	iniWrapper_saveAllSections(ini)
		
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
	
	ini_save(ini)
return

exitRoutine:
	If WinExist("ahk_id " _guiMain)
		WinGetPos(_guiMain, guiMainX, guiMainY)
	
	If WinExist("ahk_id " _guiIntro)
		WinGetPos(_guiIntro, guiIntroX, guiIntroY)
	
	If WinExist("ahk_id " _guiTime)
		WinGetPos(_guiTime, guiTimeX, guiTimeY)
	
	Gosub saveSettings
	
	exitapp
return

guiIntro() {
	; properties
	gui intro: default
	gui intro: margin, 5, 5
	gui intro: +LabelguiIntro_ +Hwnd_guiIntro
	
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
			msgbox, 36, , Overwrite selected file?
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
	global g_guiMain_display, g_guiMain_trips, g_guiMain_kills, g_guiMain_totalKillTime, g_guiMain_avgKillTime, g_guiMain_avgKillsPerTrip
	
	; properties
	gui main: default
	gui main: margin, 5, 5
	gui main: +LabelguiMain_ +Hwnd_guiMain
	
	; controls
	gui main: add, text, w145 r1, % g_logFile
	gui main: add, button, w70 r2 gguiMain_startTrip, Start Trip
	gui main: add, button, x+5 w70 r2 gguiMain_zulrahed, + Kill
	gui main: add, button, x5 w145 r1 gguiMain_undo, Undo
	
	gui main: add, edit, x5 w145 r10 vg_guiMain_display
	
	gui main: add, text, w145 r1, Trips:
	gui main: add, text, y+5 w145 r1 vg_guiMain_trips
	gui main: add, text, w145 r1, Kills:
	gui main: add, text, y+5 w145 r1 vg_guiMain_kills
	gui main: add, text, w145 r1, Total Kill Time:
	gui main: add, text, y+5 w145 r1 vg_guiMain_totalKillTime
	gui main: add, text, w145 r1, Average Kill Time:
	gui main: add, text, y+5 w145 r1 vg_guiMain_avgKillTime
	gui main: add, text, w145 r1, Average Kills Per Trip:
	gui main: add, text, y+5 w145 r1 vg_guiMain_avgKillsPerTrip
	
	Gosub guiMain_refresh
	
	; show
	If !(guiMainX = "") and !(guiMainY = "")
		gui main: show, % "x" guiMainX " y" guiMainY " AutoSize"
	else
		gui main: show, AutoSize
	
	; close
	WinWaitClose, % "ahk_id " _guiMain
	gui main: Destroy
	guiIntro()
	return
	
	guiMain_zulrahed:
		output := guiTime()
		If !(output)
			return
		FormatTime, outputFormatted, % output, mm:ss
		logToFile(outputFormatted)
		Gosub guiMain_refresh
	return
	
	guiMain_startTrip:
		logToFile("startTrip")
		Gosub guiMain_refresh
	return
	
	guiMain_undo:
		logToFileUndo()
		Gosub guiMain_refresh
	return
	
	guiMain_refresh:
		FileRead, input, % g_logFile
		GuiControl main:, g_guiMain_display, % input
		ControlSend, Edit1, ^{End}

		trips := ""
		killCount := ""
		avgKillCountPerTrip := ""
		totalKillTime := A_YYYY A_MM A_DD 00 00 00
		avgKillTime := A_YYYY A_MM A_DD 00 00 00
		avgKillTimeInSeconds := ""
		totalKillTimeSeconds := ""
		loop, parse, input, `n
		{
			If (A_LoopField = "")
				break
			LoopField := string_cleanUp(A_LoopField)
			
			If (LoopField = "startTrip")
				trips++
			If InStr(LoopField, ":")
			{
				killCount++
				loop, parse, LoopField, :
				{
					If (A_Index = 1)
						totalKillTimeSeconds += A_LoopField * 60
					If (A_Index = 2)
						totalKillTimeSeconds += A_LoopField
				}
			}
		}
		avgKillTimeInSeconds := Round(totalKillTimeSeconds / killCount)
		EnvAdd, avgKillTime, avgKillTimeInSeconds, Seconds
		FormatTime, avgKillTimeFormatted, % avgKillTime, mm:ss
		
		EnvAdd, totalKillTime, totalKillTimeSeconds, Seconds
		FormatTime, totalKillTimeFormatted, % totalKillTime, mm:ss
		
		avgKillCountPerTrip := Round(KillCount / trips, 2)
		
		; msgbox,
		; ( LTrim
			; trips = %trips%
			; killCount = %killCount%
			; totalKillTimeFormatted = %totalKillTimeFormatted%
			; avgKillCountPerTrip = %avgKillCountPerTrip%
			; avgKillTimeFormatted = %avgKillTimeFormatted%
		; )
		
		GuiControl main:, g_guiMain_trips, % trips
		GuiControl main:, g_guiMain_kills, % killCount
		GuiControl main:, g_guiMain_totalKillTime, % totalKillTimeFormatted
		GuiControl main:, g_guiMain_avgKillTime, % avgKillTimeFormatted
		GuiControl main:, g_guiMain_avgKillsPerTrip, % avgKillCountPerTrip
	return
	
	guiMain_close:
		WinGetPos(_guiMain, guiMainX, guiMainY)
		gui main: Destroy
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
	
	return output
	
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
		Gosub guiTime_close
	return
	
	guiTime_Escape:
	guiTime_close:
		WinGetPos(_guiTime, guiTimeX, guiTimeY)
		gui Time: Destroy
		output := ""
	return
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

~^s::reload