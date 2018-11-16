#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

#If RsActive()
	xbutton1::
	Send {shift down}
	
	verticalPixels := 36
	verticalRows := 7
	
	loop, 4 {
		loop, % verticalRows {
			click
			MouseMove, 0, % verticalPixels, 0, R
		}
		MouseMove, 40, -verticalPixels * verticalRows, 0, R
	}
	
	Send {shift up}
	return
#If

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
