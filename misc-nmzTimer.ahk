/*
Add features:
	Gui which shows time passed since last overload and rapidheal
*/

#Persistent
#SingleInstance, force
CoordMode, ToolTip, Screen

OnMessage( 0x200, "WM_MOUSEMOVE" ) 

Gosub loadSettings
OnExit, exitRoutine

nullTime := A_YYYY A_MM A_DD "000000"

SetTimer, Timer_Clock, On
return

WM_MOUSEMOVE( wparam, lparam, msg, hwnd )
{
	if wparam = 1 ; LButton
		PostMessage, 0xA1, 2,,, A
}

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
return

saveSettings:
	iniWrapper_saveAllSections(ini)
		
	ini_save(ini, iniFile)
return

writeIni:
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "guiDisplayX=" . "")
		ini_insertKey(ini, "Settings", "guiDisplayY=" . "")
	
	ini_save(ini)
return
exitRoutine:
	WinGetPos(_guiDisplay, guiDisplayX, guiDisplayY)
	
	Gosub saveSettings
	
	exitapp
return

Timer_Clock:
	Clock_now:=a_now
	
	if (Clock_prev_now = Clock_now) ; check if time has changed since last cycle
	  return

	FormatTime, Clock_now_formatted , % Clock_now, % l_digitsFormat ; convert current time into readable format

	Clock_prev_now:=Clock_now ; store current time to check if time has changed since last timer cycle
	
	; GuiControl time:, t_digits, % Clock_now_formatted ; update gui
	; tooltip % Clock_now_formatted, 0, 0
	
	Gosub warnTimers
return

warnTimers:
	{ ; Overload
		If (lastOverload = "")
			lastOverload := Clock_now
		
		Overload_passedTime := Clock_now
		EnvSub, Overload_passedTime, % lastOverload, seconds
		
		{ ; time passed since last cycle
			timeSinceLastOverload_a := nullTime
			EnvAdd, timeSinceLastOverload_a, Overload_passedTime, Seconds
			FormatTime, timeSinceLastOverload_formatted, % timeSinceLastOverload_a, HH:mm:ss
		}
		
		If (Overload_passedTime = 300) ; reset
		{
			lastOverload := Clock_now
			
			SoundBeep, 200, 400
		}
	}
	
	{ ; rapidheal
		If (lastRapidheal = "")
			lastRapidheal := Clock_now
		
		rapidHeal_passedTime := Clock_now
		EnvSub, rapidHeal_passedTime, % lastRapidheal, seconds
		
		{ ; time passed since last cycle
			timeSinceLastRapidheal_a := nullTime
			EnvAdd, timeSinceLastRapidheal_a, rapidHeal_passedTime, Seconds
			FormatTime, timeSinceLastRapidheal_formatted, % timeSinceLastRapidheal_a, HH:mm:ss
		}
		
		If (rapidHeal_passedTime = 50) ; reset
		{
			lastRapidheal := Clock_now
			
			SoundBeep, 200, 400
			WinActivate, ahk_exe OSBuddy.exe
		}
	}
	
	; guiDisplay(timeSinceLastRapidheal_formatted, timeSinceLastOverload_formatted)
return

guiDisplay(input1, input2) {
	global
	
	If !WinExist("ahk_id " _guiDisplay)
	{
		; properties
		gui display: Default
		gui display: Margin, 5, 5
		gui display: +Hwnd_guiDisplay +LabelguiDisplay_ +AlwaysOnTop +LastFound -Caption +ToolWindow
		
		WinSet, Transparent, 100
		gui display: color, 000000
		
		; controls
		gui display: font, s15 verdana
		
		gui display: add, text, cWhite vguiDisplay_a, % input1
		gui display: add, text, cWhite vguiDisplay_b, % input2
		
		gui motherlode: font
		
		; show
		If !(guiDisplayX = "") and !(guiDisplayY = "")
			gui Display: show, % "x" guiDisplayX " y" guiDisplayY " AutoSize NoActivate"
		else
			gui Display: show, AutoSize
		
		; close
		
	}
	else
	{
		GuiControl display:, guiDisplay_a, % input1
		GuiControl display:, guiDisplay_b, % input2
	}
}

~f1::reload
#IfWinActive, ahk_class Notepad++
; ~^s::reload
