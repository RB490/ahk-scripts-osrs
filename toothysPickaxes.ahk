#Persistent
#SingleInstance, force
SetBatchLines -1

#If RsActive()
;; men
	a::
		click right
	return

	s::
		MouseMove, 0, 90, 0, R
	return

	d::
		click
	return

	f::
		MouseMove, 0, -90, 0, R
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
	
g::escape
#If

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
