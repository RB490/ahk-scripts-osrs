1::click
2::mousemove,0,35,0,R
3::click
4::mousemove,0,-35,0,R

#Persistent
#SingleInstance, force
SetBatchLines -1
SetKeyDelay -1

return

#If WinClassActive("SunAwtFrame")
	
	; darts
	{
		a::
			click
		return
		
		s::
			MouseMove, 35, 0, 0, R
		return
		
		d::
			click
		return
		
		f::
			MouseMove, -35, 0, 0, R
		return
	}
	
	; darts
	{
		j::
			MouseMove, -35, 0, 0, R
		return
		
		k::
			click
		return
		
		l::
			MouseMove, 35, 0, 0, R
		return
		
		`;::
			click
		return
	}
#If

~f12::
	suspend
	SoundBeep
return

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive
