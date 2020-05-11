#Persistent
#SingleInstance, force
; SetBatchLines -1
; SetMouseDelay -1

#If WinClassActive("ahk_class SunAwtFrame")
LButton::
WheelLeft::
WheelRight::
f::
	Send +{Click}
	; Send {shift down}
	; click
	; Send {shift up}
return
#If

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive

f12::
	suspend
	SoundBeep
return
