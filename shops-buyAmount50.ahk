#Persistent
#SingleInstance, force


#If WinClassActive("ahk_class SunAwtFrame")

; buy 50
{
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
}

#If

#IfWinActive, ahk_exe Code.exe
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return