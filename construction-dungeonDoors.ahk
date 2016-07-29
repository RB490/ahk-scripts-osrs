#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

return

#IfWinActive ahk_exe RS.exe
	
	; build door
	{
		q::
			click right
			
			; Gosub RefreshStats
		return
		
		w::
			MouseMove, 0, 50, 0, R
		return
		
		e::
			click
		return
	}
	
	; remove door
	{
		
		a::
			click right
		return
		
		s::
			MouseMove, 0, 100, 0, R
		return

		d::
			click
		return
		
		f::1
	}
	
	; butler interaction
	{
		z::1
		
		x::space
	
	}
#IfWinActive

~f12::
	suspend
	SoundBeep
return

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive
