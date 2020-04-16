#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

return

#If WinClassActive("ahk_class SunAwtFrame")
	
	; build
	{
		q::
			click right
		return
		
		w::
			MouseMove, 0, 50, 0, R
		return
		
		e::
			click
		return
		
		r::
			MouseMove, 0, -50, 0, R
		return
		
		t::4
	}
	
	; remove
	{
		
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
		
		g::1
	}
	
	; butler
	{
		z::1
		
		x::space
	
	}
#If

~f12::
	suspend
	SoundBeep
return

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive
