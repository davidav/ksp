//вывод на  орбиту  183000  ...  с наклонением  более 85
// по факту 
set nameProgramm to "discoverer_13".
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 40.
SET TERMINAL:HEIGHT TO 15.
clearscreen. 
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.
set targetHead to -3.
set cyclogram to 1.
set maxTWR to 1.8.
set Horbop to 188000.
set GTstart to 3000.
set GTendAP to 65000.
set v45 to 550.
function nextstage{
  until ship:availablethrust > 0 {
    wait 1.
    stage.
  }
}
function CapTWR {
  parameter maxTWR is 3.0.
  local g0 to Kerbin:mu/Kerbin:radius^2.
  lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ).
}
function DisplayCyclogram{
	parameter namecyclogram.
	clearscreen.
    print "CYCLOGRAM: "+nameProgramm at(5,1).
    print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
}
function SetLinkTarget{
    parameter AntName.
    parameter BlockIndex. 
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
}
until cyclogram = 0 {
    if cyclogram = 1{
		DisplayCyclogram ("START").
        WAIT 1.
        lock throttle to 1.0.          
        WAIT 3.      
        local initialpos to ship:facing.
        lock steering to initialpos.
        nextstage().
        WAIT 1.  
        print "TAKE OFF" at(5,7).
        WAIT 3.        
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
		DisplayCyclogram ("LIFTING").
        lock steering to heading(targetHead,targetPitch).
		nextstage().
		CapTWR(maxTWR).
        if altitude > GTstart {
            set cyclogram to 3.
        }
    }
    else if cyclogram = 3{
		DisplayCyclogram ("GRAVITY_TURN").	 
        set GTStartSpd to velocity:surface:mag.
        set AP45 to apoapsis.
        set pitch to 0.        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).
        until altitude > Horbop {
			set vsm to velocity:surface:mag.
            if GTpitch >= 45 { 
                set Apo45 to apoapsis.
            } 
            if ( vsm < v45 ) {
                set pitchRaschet1 to min(90, 90 - arctan((vsm - GTStartSpd)/(v45 - GTStartSpd))).
                if pitch - pitchRaschet1 > 3 {
					set pitch to pitch-1.
					wait 3.
				} else {
					set pitch to pitchRaschet1.
				}
            } else {
                set pitchRaschet to max(0, 45*(apoapsis - GTendAP) / (AP45 - GTendAP)).
				if pitch - pitchRaschet > 3 {
					set pitch to pitch-1.
					wait 1.
				} else {
					set pitch to pitchRaschet.
				}
            }
            lock steering to heading(targetHead, pitch ).
            print "Pitch: " + round( pitch ) + " deg  " at (5,4).
			print "Apo: " + Round(Apoapsis) at (5,5).

			if apoapsis > Horbop {
                lock throttle to 0.
                set cyclogram to 4.
                break.
            }
            nextstage().
			CapTWR(maxTWR). 
        }
    }
    else if cyclogram = 4{
		DisplayCyclogram ("FREE_FLIGHT").
        LOCK Steering to PROGRADE.	 	
		wait 5.
        until ETA:Apoapsis<1 {
            if altitude > 71000 {
                AG5 ON.
            }
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            }	
        wait 0.5.
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
		DisplayCyclogram ("OUTPUT_ORBIT").
        LOCK Steering to PROGRADE.
        lock throttle to 0.5.
        until Periapsis > 80000 { 
                wait 0.1.
            }
		lock throttle to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
        unlock throttle.        
		unlock steering.
		wait 1.
		print "ON ORBIT!" at(5,10).
 		wait 5.
		set cyclogram to 6.    
	}
		else if cyclogram = 6{
 		DisplayCyclogram ("COMMUNICATION").           
        SetLinkTarget("longAntenna",0).
		wait 1.		
		SetLinkTarget("longAntenna",1).
        wait 1.
        set cyclogram to 0.
    }
}
    if cyclogram = 0 {
		DisplayCyclogram ("FINALIZATION").        
        wait 1.
        SAS off.
        RCS off.
        unlock throttle.
        set ship:control:pilotmainthrottle to 0.
        print "NO ERROR." at(5,10).
        wait 1.
		clearscreen.  
    }