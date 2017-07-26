#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

#If RsActive()
	a::
		Send {shift down}
		click
		Send {shift up}
	return

	s::
		MouseMove, 0, 36, 0, R
	return

	d::
		Send {shift down}
		click
		Send {shift up}
	return

	f::
		MouseMove, 0, 36, 0, R
	return
	
	q::
		MouseMove, 0, -180, 0, R
	return
	
	w::
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

RsActive() {
	WinGet, WIN, ProcessName, A
	If InStr(WIN, "JagexLauncher.exe") or InStr(WIN, "OSBuddy.exe") or InStr(WIN, "RS.exe")
		return true
	else
		return false
}

f12::
	suspend
	SoundBeep
return
