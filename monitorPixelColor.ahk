#SingleInstance, force

; set relevant commands to the same coordinate mode
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

; set global vars
global g_color ; RGB format of selected pixel color
global g_colorX ; x coordinate of selected pixel color
global g_colorY ; y coordinate of selected pixel color
global g_capturePixelMode := false ; capture mouse mode

; setup hotkey for disabling mouse input
#If (g_capturePixelMode)
Hotkey, If, (g_capturePixelMode)
Hotkey, LButton, menuHandler
Hotkey, If
#If

Gosub setPixelColor

guiMain()

SetTimer, checkPixelColor, On
return

guiMain() {
	; properties
	gui guiMain: +labelguiMain_ +hwnd_guiMain
	gui guiMain: +ToolWindow +AlwaysOnTop +Resize
	
	; controls
	gui guiMain: Color, % g_color
	
	; show
	WinGetPos, rsX, rsY, rsWidth, rsHeight, ahk_exe RuneLite.exe
	If (rsX)
		gui guiMain: show, x%rsX% y%rsY% w100 h100 NoActivate, Pixel color
	else
		gui guiMain: show, w100 h100 NoActivate, Pixel color
	return
	
	guiMain_contextMenu:
		Menu, MyMenu, add
		Menu, MyMenu, DeleteAll
		
		Menu, MyMenu, add, Set pixel color, setPixelColor
		Menu, MyMenu, Show
	return
	
	guiMain_close:
		exitapp
	return
}

setPixelColor:
	SetTimer, showChoosePixelTooltip, 5
	
	; capture single mouseclick / prevent from sending to click location
	g_capturePixelMode := true
	KeyWait, LButton, D ; wait for mouse button down
	KeyWait, LButton ; wait for mouse button up
	MouseGetPos, g_colorX, g_colorY
	g_capturePixelMode := false

	PixelGetColor, g_color, % g_colorX, % g_colorY, RGB
	
	gui guiMain: Color, % g_color
	
	SetTimer, showChoosePixelTooltip, Off
	tooltip
return

checkPixelColor:
	PixelGetColor, output, % g_colorX, % g_colorY, RGB
	
	If !(output = g_color) ; pixel is currently not at the selected color
		gui guiMain: Color, Red
	else
		gui guiMain: Color, % g_color ; pixel is at the selected color
return

showChoosePixelTooltip:
	tooltip, Choose pixel
return

menuHandler:
return

~^s::reload