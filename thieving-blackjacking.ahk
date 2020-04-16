#Persistent
#SingleInstance, force
SetBatchLines -1

#If WinClassActive("ahk_class SunAwtFrame")
;; men
	a::
		click right
	return

	s::
		MouseMove, 0, 70, 0, R
	return

	d::
		click
	return

	f::
		MouseMove, 0, -70, 0, R
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
#If

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
