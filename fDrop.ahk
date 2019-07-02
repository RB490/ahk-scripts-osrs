#Persistent
#SingleInstance, force
; SetBatchLines -1
; SetMouseDelay -1

#If RsActive()
RButton::
f::
	Send +{Click}
	; Send {shift down}
	; click
	; Send {shift up}
return
#If

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive

f12::
	suspend
	SoundBeep
return
