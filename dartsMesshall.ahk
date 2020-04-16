#Persistent
#SingleInstance, force


#If WinClassActive("ahk_class SunAwtFrame")


f1::send {2 down}
f2::send {2 up}

; take x
{
	q::
		click right
	return
	
	w::
		MouseMove, 0, 85, 0, R
	return
	
	e::
		click
	return
	
	r::
		MouseMove, 0, -85, 0, R
	return
}

; inventory darts style
{
	a::
		click
	return
	
	s::
		MouseMove, 0, 30, 0, R
	return
	
	d::
		click
	return
	
	f::
		MouseMove, 0, -30, 0, R
	return
}

; amounts
{
	z::1
	
	x::3
	
	c::send {enter}
	
	v::send {escape}
}

#If

~^s::reload

~f12::
	suspend
	SoundBeep
return
