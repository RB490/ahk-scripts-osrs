#Persistent
#SingleInstance, force
SetBatchLines -1

#If WinClassActive("ahk_class SunAwtFrame")
;; men
	a::
		click right
	return

	s::
		MouseMove, 0, 55, 0, R
	return

	d::
		click
	return

	f::
		MouseMove, 0, -55, 0, R
	return
	
;; ham

	q::
		click right
	return

	w::
		MouseMove, 0, 40, 0, R
	return

	e::
		click
	return

	r::
		MouseMove, 0, -40, 0, R
	return
	
	LButton::
		Send {Shift down}
		click
		Send {Shift up}
	return
#If

#IfWinActive, ahk_exe Code.exe
	~^s::reload
#IfWinActive

WinClassActive("ahk_class SunAwtFrame") {
	WinGet, WIN, ProcessName, A
	If InStr(WIN, "JagexLauncher.exe") or InStr(WIN, "OSBuddy.exe")
		return true
	else
		return false
}

~f12::
	suspend
	status !=: status
	SoundBeep
	tooltip, % status,0,0
return
