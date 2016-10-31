guiTarget() {
	global g_target_h
	global g_target_m
	global g_target_s
	
	; properties
	gui target: new
	gui target: margin, 5, 5
	gui target: +LabelguiTarget_ +Hwnd_guiTarget +AlwaysOnTop -Caption

	; controls
	gui target: font, s15 verdana
	gui target: add, edit, w30 Number Right Disabled section
	gui target: font
	
	gui target: add, text, x+5 yp+20, h
	
	gui target: font, s15 verdana
	gui target: add, edit, x+5 ys w30 Number Right Disabled
	gui target: font
	
	gui target: add, text, x+5 yp+20, m
	
	gui target: font, s15 verdana
	gui target: add, edit, x+5 ys w30 Number Right gguiTarget_refresh
	gui target: font
	
	gui target: add, text, x+5 yp+20, s
	
	; hotkeys
	hotkey, IfWinActive, % "ahk_id " _guiTarget
	hotkey, enter, guiTarget_submit
	hotkey, IfWinActive
	
	; show
	WinGetPos, X, Y, W, H, Stopwatch
	gui target: show, % "x" x + 4 " y" y+30
	ControlFocus, edit3, % "ahk_id " _guiTarget
	
	; close
	WinWaitClose, % "ahk_id " _guiTarget
	return output
	
	guiTarget_refresh:
		SetControlDelay, -1
		
		ControlGetText, inputEdit1, Edit1
		ControlGetText, inputEdit2, Edit2
		ControlGetText, inputEdit3, Edit3
		
		If StrLen(inputEdit3) < StrLen(oldInputEdit3) ; remove input
		{
			If (StrLen(inputEdit1))
			{
				ControlSetText, Edit1, % SubStr(inputEdit1, 2, 2)
				ControlSetText, Edit3, % oldInputEdit3
			}
			else if (StrLen(inputEdit2))
			{
				ControlSetText, Edit2, % SubStr(inputEdit2, 2, 2)
				ControlSetText, Edit3, % oldInputEdit3
			}
			else if (StrLen(inputEdit3))
				ControlSetText, Edit3, % SubStr(oldInputEdit3, 2, 2)
		}
		else ; add input
		{
			If (StrLen(inputEdit3) = 3)
			{
				newDigit := SubStr(inputEdit3, 1, 1)
				ControlSetText, Edit3, % SubStr(inputEdit3, 2)
				
				ControlGetText, input, Edit2
				ControlSetText, Edit2, % input newDigit
				
			}
			
			ControlGetText, inputEdit2, Edit2
			If (StrLen(inputEdit2) = 3)
			{
				newDigit := SubStr(inputEdit2, 1, 1)
				ControlSetText, Edit2, % SubStr(inputEdit2, 2)
				
				ControlGetText, input, Edit1
				ControlSetText, Edit1, % input newDigit
				
			}
			
			ControlGetText, inputEdit1, Edit1
			If (StrLen(inputEdit1) = 3)
			{
				ControlSetText, Edit1, % SubStr(inputEdit1, 2)
			}
		}
		ControlGetText, oldInputEdit3, Edit3
		ControlSend, Edit3, ^{end}
	return
	
	guiTarget_setControls:
	
	return
	
	guiTarget_submit:
		loop, parse, % "g_target_h,g_target_m,g_target_s", `,
		{
			ControlGetText, %A_LoopField%, Edit%A_Index%
			
			If (A_LoopField = "g_target_h")
			{
				If (%A_LoopField% > 23)
					%A_LoopField% := 23
			}
			else
				If (%A_LoopField% > 59)
					%A_LoopField% := 59
			
			If (StrLen(%A_LoopField%) = 1)
				%A_LoopField% := 0 %A_LoopField%
			If !(StrLen(%A_LoopField%))
				%A_LoopField% := 00
		}
		output := A_YYYY A_MM A_DD g_target_h g_target_m g_target_s
		gui target: destroy
	return
	
	guiTarget_escape:
	guiTarget_close:
		output := ""
		gui target: destroy
	return
}