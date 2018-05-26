#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

#If RsActive()
	xbutton1::
	Send {shift down}
	
	loop, 4 {
		loop, 6 {
			click
			MouseMove, 0, 36, 0, R
		}
		MouseMove, 40, -216, 0, R
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
