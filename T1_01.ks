//Test SuicideBurn
//
//

set nameProgram to "T1-01".

set maxTWR to 1.8.
set targetHead to 88.
set targetPitch to 88.

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set cyclogram to 1.

until cyclogram = 0 {
    if cyclogram = 1{
		system["displayNameCyclogram"]("PRELUNCH").
        system["timer"](1, "Left before launch ", 1).
        set cyclogram to 2.
    }
    if cyclogram = 2{
		system["displayNameCyclogram"]("START").
        lock throttle to 1.0.
        lock steering to ship:facing.
        print "ZEMLYA - BORT" at(5,4).
        sound["link"]().
        wait 1.
        print "ZAZHIGANIE" at(5,5).
        wait 1.
        stage.
        print "TAKE OFF" at(5,6).
        wait 1.
        set cyclogram to 3.
    }
    else if cyclogram = 3{
		system["displayNameCyclogram"]("LIFTING").
        wait 3.
        vessel["orientation"](targetPitch, targetHead).
		vessel["CapTWR"](maxTWR).
        until altitude > 10000 {
            wait 0.5.
        }
            unlock throttle.
            set cyclogram to 4.
    }
    
    else if cyclogram = 4{
    	system["displayNameCyclogram"]("FREE_FLIGHT").
        wait until ship:verticalspeed < 0. {
            wait 0.5.
        }

            vessel["deployFairings"]().
            set navmode to "SURFACE".			//переключение в режим Surface.
            set sasmode to "STABILITYASSIST".   //Включение SAS в режиме стабилизации.
            OS_Boot["CopyAndRunFile"]("suicide_burn").
            wait 0.5.
    set cyclogram to 0.
    }
}

if cyclogram = 0 {
	system["displayNameCyclogram"]("FINALIZATION").
    rcs on.
    sas on.
    sound["beepOK"]().
}
