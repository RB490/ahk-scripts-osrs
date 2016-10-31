guiStats(refresh = "") {
	static guiStats_lv, guiStats_miscLv, guiStats_miscLvSelectedRow
	
	If (refresh) and WinExist("Drop Logger Stats")
	{
		Gosub guiStats_refresh
		return
	}
	If (refresh) and !WinExist("Drop Logger Stats")
		return

	guiStatsX := ini_getValue(ini, "Window Positions", "guiStatsX")
	guiStatsY := ini_getValue(ini, "Window Positions", "guiStatsY")
	
	; properties
	Gui stats: default
	Gui stats: +LabelguiStats_
	Gui stats: Margin, 5, 5

	; controls
	Gui stats: Add, ListView, w160 r12 NoSortHdr vguiStats_lv, Description|Value
	Gui stats: Add, ListView, x+5 w630 r12 vguiStats_miscLv gguiStats_miscLv AltSubmit, Drop|Amount|Value|Drop rate|Kills since last drop|Shortest dry streak|Longest dry streak
	
	Gosub guiStats_refresh
	
	; show
	If (guiStatsX) and (guiStatsY)
		Gui stats: show, % "x" guiStatsX " y" guiStatsY " AutoSize NoActivate", Drop Logger Stats
	else
		Gui stats: show, AutoSize NoActivate, Drop Logger Stats
	return
	
	guiStats_miscLv:
		If (A_GuiEvent = "Normal") or (A_GuiEvent = "DoubleClick")
			guiStats_miscLvSelectedRow := A_EventInfo
	return
	
	guiStats_refresh:
		total_kills := 0
		total_trips := 0
		
		loop, parse, g_log, `n
		{
			If !(A_LoopField)
				break
				
			If InStr(A_LoopField, "Start Trip")
				total_trips++
			
			If !InStr(A_LoopField, "Trip")
			{
				total_kills++
				
				loop, parse, % string_cleanUp(SubStr(A_LoopField, InStr(A_LoopField, ". ") + 2)), `,
				{
					LoopField := string_cleanUp(A_LoopField)
					total_drops .= LoopField "`n"
					total_dropValue += priceLookup(LoopField)
				}
			}
				
			If InStr(A_LoopField, "Start Trip")
			{
				StringReplace, tripStart, A_LoopField, Start Trip -
				tripStart := string_cleanUp(tripStart)
				tripStart := ReFormatTime( tripStart, "DD MM YYYY HH MI SS", "/@:")
			}
			
			If InStr(A_LoopField, "End Trip")
			{
				StringReplace, tripEnd, A_LoopField, End Trip -
				tripEnd := string_cleanUp(tripEnd)
				tripEnd := ReFormatTime( tripEnd, "DD MM YYYY HH MI SS", "/@:")
			}
			
			If (tripStart) and (tripEnd)
			{
				EnvSub, tripEnd, tripStart, Seconds
				total_TripTimeInSeconds += tripEnd
				tripEnd := ""
				tripStart := ""
			}
		}
		
		currentTripTimeInSeconds := A_Now
		EnvSub, currentTripTimeInSeconds, tripStart, seconds
		total_TripTimeInSeconds += currentTripTimeInSeconds
		
		total_dropValue += total_kills * (priceLookup("Drop's scales") * ini_getValue(ini, "Settings", "averageBaseScales"))
		total_uniqueDrops := string_removeDuplicates(total_drops)
		
		average_killsPerTrip := total_kills / total_trips
		average_timePerTripInSeconds := total_TripTimeInSeconds / total_trips
		average_dropValue := total_dropValue / total_kills
		average_tripsPerHour := 3600 / average_timePerTripInSeconds
		average_killsPerHour := average_tripsPerHour * average_killsPerTrip
		average_dropValuePerHour := average_killsPerHour * average_dropValue
		
		total_TripTimeInSecondsFormatted := A_YYYY A_MM A_DD 00 00 00
		EnvAdd, total_TripTimeInSecondsFormatted, total_TripTimeInSeconds, Seconds
		FormatTime, total_TripTimeInSecondsFormatted, % total_TripTimeInSecondsFormatted, HH:mm:ss
		
		average_timePerTripInSecondsFormatted := A_YYYY A_MM A_DD 00 00 00
		EnvAdd, average_timePerTripInSecondsFormatted, average_timePerTripInSeconds, Seconds
		FormatTime, average_timePerTripInSecondsFormatted, % average_timePerTripInSecondsFormatted, HH:mm:ss
		
		Gosub guiStats_refreshLv
		Gosub guiStats_refreshMiscLv
	return
	
	guiStats_refreshLv:
		Gui stats: default
		Gui stats: Listview, guiStats_lv
		GuiControl stats: -Redraw, guiStats_lv
		LV_Delete()
		
		LV_Add(, "-- Total --")
		LV_Add(, "Kills", total_kills)
		LV_Add(, "Trips", total_trips)
		LV_Add(, "Time", total_TripTimeInSecondsFormatted)
		LV_Add(, "Drop value", ThousandsSep(Round(total_dropValue)))
		LV_Add(, "-- Average --")
		LV_Add(, "Kills per trip", Round(average_killsPerTrip, 2))
		LV_Add(, "Time per trip", average_timePerTripInSecondsFormatted)
		LV_Add(, "Drop value", ThousandsSep(Round(average_dropValue)))
		LV_Add(, "Kills/hour", Round(average_killsPerHour, 2))
		LV_Add(, "Trips/hour", Round(average_tripsPerHour, 2))
		LV_Add(, "Income/hour", ThousandsSep(Round(average_dropValuePerHour)))
		
		LV_ModifyCol(1, "AutoHDR")
		LV_ModifyCol(2, "AutoHDR")
		GuiControl stats: +Redraw, guiStats_lv
	return
	
	guiStats_refreshMiscLv:
		Gui stats: Listview, guiStats_miscLv
		GuiControl stats: -Redraw, guiStats_miscLv
		LV_Delete()
		
		loop, parse, total_uniqueDrops, `n
		{
			If !(A_LoopField)
				break
			; item
			item := A_LoopField
			
			; amount
			itemAmount := ""
			loop, parse, total_drops, `n
			{
				If !(A_LoopField)
					break
				If (A_LoopField = item)
					itemAmount++
			}
			
			; value
			value := itemAmount * priceLookup(item)
			
			; drop rate
			dropRate := Round(total_kills / itemAmount)
			
			; kills since last drop
			killsSinceLastDrop := ""
			loop, parse, g_log, `n
			{
				If !(A_LoopField)
					break
				
				If !InStr(A_LoopField, "trip")
				{
					If InStr(A_LoopField, item)
						killsSinceLastDrop := 0
					else
						killsSinceLastDrop++
				}
			}
			
			; dry streaks
			dryStreak := ""
			dryStreakOutput := ""
			itemFound := ""
			loop, parse, g_log, `n
			{
				If !(A_LoopField)
					break
				
				If !InStr(A_LoopField, "Trip")
				{
					If InStr(A_LoopField, item) and (itemFound)
					{
						If !(dryStreak)
							dryStreak := 0
						dryStreakOutput .= dryStreak "`n"
						dryStreak := 0
					}
					else
						dryStreak++
						
					If InStr(A_LoopField, item)
						itemFound := 1
				}
			}
			
			shortestDryStreak := ""
			Sort, dryStreakOutput, N ; low to high
			loop, parse, dryStreakOutput, `n
			{
				shortestDryStreak := A_LoopField
				break
			}
			
			dryStreaksOutput .= dryStreak "`n" ; add drystreak since most recent drop after shortest dry streak is retrieved
			
			Sort, dryStreakOutput, NR ; high to low
			
			longestDryStreak := ""
			loop, parse, dryStreakOutput, `n
			{
				longestDryStreak := A_LoopField
				break
			}
			
			LV_Add(, A_LoopField, itemAmount, value, dropRate, killsSinceLastDrop, shortestDryStreak, longestDryStreak)
		}
		
		LV_ModifyCol(1, "AutoHDR")
		LV_ModifyCol(2, "AutoHDR")
		LV_ModifyCol(3, "AutoHDR")
		LV_ModifyCol(4, "AutoHDR")
		LV_ModifyCol(5, "AutoHDR")
		LV_ModifyCol(6, "AutoHDR")
		LV_ModifyCol(7, "AutoHDR")
		
		LV_ModifyCol(2, "Integer")
		LV_ModifyCol(3, "Integer")
		LV_ModifyCol(4, "Integer")
		LV_ModifyCol(5, "Integer")
		LV_ModifyCol(6, "Integer")
		LV_ModifyCol(7, "Integer")
		
		LV_ModifyCol(3, "SortDesc")
		
		LV_Modify(guiStats_miscLvSelectedRow, "Vis")
		
		GuiControl stats: +Redraw, guiStats_miscLv
	return
	
	guiStats_close:
		WinGetPos, guiStatsX, guiStatsY, , , Drop Logger Stats
		ini_replaceValue(ini, "Window Positions", "guiStatsX", guiStatsX)
		ini_replaceValue(ini, "Window Positions", "guiStatsY", guiStatsY)
		Gui stats: Destroy
		GuiControl log: Enable, % g__guiLog_btnStats
	return
}