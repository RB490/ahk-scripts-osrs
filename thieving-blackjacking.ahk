#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1


#IfWinActive, ahk_exe RS.exe
d::
	click right
	MouseMove, 0, 40, 0, R
	click
	MouseMove, 0, -40, 0, R
return

f::
	click right
	MouseMove, 0, 70, 0, R
	click
	MouseMove, 0, -70, 0, R
return
#IfWinActive, ahk_exe RS.exe

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive



f12::
	suspend
	SoundBeep
return
