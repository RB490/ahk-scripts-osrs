debug:
    mainGui.Setup() ; show main gui
    ; Gosub menuChooseMode_TimerUntil
    

    return
    ; debugging - timer
    loop, 3 {
        timer.Start()
        sleep 1000
        timer.Pause()
    }


    ; debugging - stopwatch
    ; loop, 3 {
    ;     stopwatch.Start()
    ;     sleep 1000
    ;     stopwatch.Pause()
    ; }
    ; stopwatch.Stop()
    ; stopwatch.Start()
return