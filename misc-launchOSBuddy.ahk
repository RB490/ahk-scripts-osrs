#Persistent
#SingleInstance, force

Gosub loadSettings

If (osbuddyPath = "")
{
	InputBox, osbuddyPath, Locate OSBuddy.exe
	If (osbuddyPath = "")
		exitapp
	
	Gosub saveSettings
}

If WinExist("ahk_exe OSBuddy.exe") ; check if an instance of osbuddy is running
{
	If (countWindows("OSBuddy") = 2) ; if so, check if two instances are running
		exitapp 
	else
		run % osbuddyPath ; open an additional instance if not
}
else
{
	run % osbuddyPath
	sleep 100 ; prevent error that occurs when launching osbuddy rapidly in succession
	run % osbuddyPath
}

WinWait OSBuddy Loader
WinWaitClose OSBuddy Loader

loop,
{
	If (countWindows("OSBuddy") = 2)
	{
		sleep 100 ; wait until both windows are fully loaded
		break
	}
	sleep 100
}

Gosub positionWindows

exitapp
return

loadSettings:
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		Gosub writeIni
		ini_load(ini, iniFile)
	}
	
	iniWrapper_loadAllSections(ini)
return

saveSettings:
	iniWrapper_saveAllSections(ini)
		
	ini_save(ini, iniFile)
return

writeIni:
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "osbuddyPath=" . "")
	
	ini_save(ini)
return

countWindows(input) {
	WinGet windowsList, List
	Loop %windowsList%
	{
		id := windowsList%A_Index%
		WinGetTitle wt, ahk_id %id%
		r .= wt . "`n"
		
		If InStr(wt, input)
			count++
	}
	
	return count
}

positionWindows:
	WinGet windowsList, List
	Loop %windowsList%
	{
		id := windowsList%A_Index%
		WinGetTitle wt, ahk_id %id%
		r .= wt . "`n"
		
		If InStr(wt, "OSBuddy")
		{
			count++
			
			If (count = 1)
				WinMovePos(id, "TopRight")
			else
				WinMovePos(id, "BottomRight")
				
		}
	}
return

~^s::
	reload
return