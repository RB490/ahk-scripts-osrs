#Persistent
#SingleInstance, force
SetBatchLines -1

#If WinClassActive("ahk_class SunAwtFrame")
;; withdraw all
	a::
		click right
	return

	s::
		MouseMove, 0, 70, 0, R
	return

	d::
		click
	return
	
;; withdraw custom

	q::
		click right
	return

	w::
		MouseMove, 0, 85, 0, R
	return

	e::
		click
	return
	
;; hotkeys
r::
	send {escape}
	send {f1}
return
f::
	send {escape}
	send {f4}
return
v::
	send {escape}
	send {f12}
return

#If

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
