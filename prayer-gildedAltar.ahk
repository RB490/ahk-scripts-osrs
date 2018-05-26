#Persistent
#SingleInstance, force
CoordMode, Mouse, Relative
SetBatchLines -1
SetKeyDelay -1

return

#If RsActive()
	
	{
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
	
		t::
			send {f5} ; Equipment tab
		return
	}
	
	{
		/*
		
		a::
			click right
		return
		
		s::
			MouseMove, 0, 70, 0, R
		return

		d::
			click
		return
		
		*/
		
		a::
			MouseMove, -180, 0, 0, R
		return
		
		s::
			click
		return

		d::
			MouseMove, 180, 0, 0, R
		return
		
		f::
		return
	}
	
	{
		z::
			click right
		return
		
		x::
			MouseMove, 0, 70, 0, R
		return
		
		c::
			click
		return
		
		v::escape
	}
	
	j::
		click right
	return
	
	k::
		MouseMove, 0, 50, 0, R
	return
	
	l::
		click
	return
	
#If

~f12::
	suspend
	SoundBeep
return

#IfWinActive, ahk_class Notepad++
~^s::reload
#IfWinActive
