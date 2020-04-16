#Persistent
#SingleInstance, force
SetBatchLines -1

#If WinClassActive("ahk_class SunAwtFrame")
;; withdraw all
	a::
		click right
	return

	s::
		MouseMove, 0, 100, 0, R
	return

	d::
		click
	return

	f::
		MouseMove, 0, -100, 0, R
	return
	
;; withdraw custom

	q::
		click right
	return

	w::
		MouseMove, 0, 80, 0, R
	return

	e::
		click
	return

	r::
		MouseMove, 0, -80, 0, R
	return
	
;; hotkeys
g::escape

#If

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
