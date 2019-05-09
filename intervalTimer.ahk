#SingleInstance, force

global g_nullTime := A_YYYY A_MM A_DD 00 00 00
global g_interval := 13 ; interval time in seconds
global g_timerRunning := true ; interval time in seconds
global g_startTime ; timer start time

InputBox, g_interval, Interval timer, Choose interval time in seconds`n`n13 For broad arrows
If !(g_interval)
	exitapp
	
SetTimer, intervalTimer, On
return

intervalTimer:
	If !(g_startTime) ; set start time
		g_startTime := A_Now

	passedSeconds := A_Now
	EnvSub, passedSeconds, g_startTime, Seconds ; calculate amount of seconds passed since start

	If (passedSeconds = g_interval) { ; interval has been reached
		g_startTime := "" ; reset start time so the interval starts over
		
		SoundBeep, 2750, 100  ; Play a higher pitch for half a second.
		SoundBeep, 2750, 100  ; Play a higher pitch for half a second.
		
		; SoundBeep, 750, 500  ; Play a higher pitch for half a second.
	}
	guiDisplay(g_interval - passedSeconds)
	; tooltip % passedSeconds
return


guiDisplay(input) {
	static _guiDisplay
	
	displayTime := g_nullTime
	EnvAdd, displayTime, input, Seconds
	FormatTime, displayTime, % displayTime, s
	
	If (_guiDisplay) { ; guiDisplay exists, update it
		GuiControl guiDisplay: Text, Static1, % displayTime
		
		; repaint gui based on time left
		If (input <= 6)
			gui guiDisplay: Color, Yellow
		If (input <= 3)
			gui guiDisplay: Color, Red
		If (input > 6)
			gui guiDisplay: Color, Default
		return
	}
	
	; properties
	gui guiDisplay: +labelguiDisplay_ +hwnd_guiDisplay
	gui guiDisplay: margin, 15 , 15
	gui guiDisplay: +ToolWindow +AlwaysOnTop
	
	; controls
	gui guiDisplay: font, s25
	gui guiDisplay: add, text, Center, 99 ; create text control wide enough for double digits
	GuiControl guiDisplay: Text, Static1, % displayTime ; set current time
	
	; show
	WinGetPos, rsX, rsY, rsWidth, rsHeight, ahk_exe RuneLite.exe
	If (rsX)
		gui guiDisplay: show, x%rsX% y%rsY% NoActivate, Interval
	else
		gui guiDisplay: show, NoActivate, Interval
	return
	
	guiDisplay_ContextMenu:
		Menu, MyMenu, Add
		Menu, MyMenu, DeleteAll
		
		Menu, MyMenu, Add, Interval timer, guiDisplay_toggleTimer
		If (g_timerRunning)
			Menu, MyMenu, Check, Interval timer
		Menu, MyMenu, Add ; Add a separator line.
		Menu, MyMenu, Add, Reset, guiDisplay_resetTimer  ; Add a separator line.
		
		Menu, MyMenu, Show
	return
	
	guiDisplay_toggleTimer:
		If (g_timerRunning) {
			g_timerRunning := false
			SetTimer, intervalTimer, Off
		}
		else {
			g_timerRunning := true
			SetTimer, intervalTimer, On
		}
	return
	
	guiDisplay_resetTimer:
		g_timerRunning := true
		g_startTime := A_Now
		SetTimer, intervalTimer, On
	return
	
	guiDisplay_close:
		exitapp
	return
}



~^s::reload