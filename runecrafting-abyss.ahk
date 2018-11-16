#Persistent
#SingleInstance, force


#If RsActive()

; misc
{
	r::f5 ; equipment
	
	f::
		send {escape}
		send {f1}
	return
	
	g::f4 ; magic tab
}

; pouches
{
	q::
		click right
	return
	
	w::
		MouseMove, 0, 38, 0, R
	return
	
	e::
		click
	return
}

; banking
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
}

; zamorak mage
{
	z::
		click right
	return
	
	x::
		MouseMove, 0, 60, 0, R
	return
	
	c::
		click
	return
}

#If

#IfWinActive, ahk_exe Notepad++
~^s::reload
#IfWinActive

~f12::
	suspend
	SoundBeep
return
