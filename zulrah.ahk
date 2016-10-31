#Persistent
#SingleInstance, force


#IfWinActive, ahk_exe RS.exe

q::f1
w::f2
e::f3
r::f4
t::f5

z::f1
x::f2
c::f3
v::f4
b::f5

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
		send {f1}
	return
}

#IfWinActive

#IfWinActive, ahk_exe OSBuddy.exe

q::f1
w::f2
e::f3
r::f4
t::f5

z::f1
x::f2
c::f3
v::f4
b::f5

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
		send {f1}
	return
}

#IfWinActive

#IfWinActive, ahk_exe Notepad++
~^s::reload
#IfWinActive

f12::
	suspend
	SoundBeep
return
