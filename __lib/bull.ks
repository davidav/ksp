//Bull sub-orbital
//
//

set nameProgram to "Bull - Sub-orbital".

set maxTWR to 1.3.
set targetHead to 90.
set targetPitch to 90.

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set cyclogram to 1.

until cyclogram = 0 {
    if cyclogram = 1{
		system["displayNameCyclogram"]("PRELUNCH").
        system["timer"](10, "Left before launch program ", 1).
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
        stage.        
        set cyclogram to 3.
    }  
    else if cyclogram = 3{
		system["displayNameCyclogram"]("LIFTING").
        wait 3.
        vessel["orientation"](targetPitch, targetHead).
		vessel["CapTWR"](maxTWR).
        wait until ship:verticalspeed < 0. {
            unlock throttle.            
            set cyclogram to 4.
        }
    }
    else if cyclogram = 4{
    	system["displayNameCyclogram"]("FREE_FLIGHT").
        wait until alt:radar < 2000. 
            vessel["deployChutes"]().
        wait until alt:radar < 1000. 
            AG1 ON.
        set cyclogram to 0.               
       
        wait 0.5.
    }
}
if cyclogram = 0 {
	system["displayNameCyclogram"]("FINALIZATION").
    rcs on.
    sas on.
    sound["beepOK"]().    
}