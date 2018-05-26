#Persistent
#SingleInstance, force


#If RsActive()

q::f1	; inventory
w::f2	; combat options
e::f3	; prayers
r::f4	; magic
t::f5	; equipment

z::f1	; inventory
x::f2	; combat options
c::f3	; prayers
v::f4	; magic
b::f5	; equipment

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
	
	f::
		send {escape}
		; send {f1}
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