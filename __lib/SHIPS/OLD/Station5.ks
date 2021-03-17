//вывод на  целевую орбиту (Т=1час) станция 2

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
set begin to time.

clearscreen. 
set SatelliteAngle to 240.

set KSCLNG to SHIP:GEOPOSITION:LNG+SatelliteAngle.
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.
set targetHead to 90.
set cyclogram to 1.
set maxTWR to 2.0.
function nextstage{
  until ship:availablethrust > 0 {
    wait 0.5.
    stage.
  }
}
function CapTWR {
  parameter maxTWR is 3.0.
  local g0 to Kerbin:mu/Kerbin:radius^2.
  lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ).
}
function SetDishTarget{
    parameter DishBlockName.
    parameter BlockIndex. 
    parameter DishTarget.
    set p to ship:partsnamed(DishBlockName)[BlockIndex].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("Activate").
    m:setfield("target", DishTarget).
}

until cyclogram = 0 {
    if cyclogram = 1{
        set namecyclogram to "START".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
            PRINT "..." + countdown at(10,4).
            WAIT 1.
        }
        print "ZEMLYA - BORT" at(10,4).
        //stage.
        WAIT 1.
        print "PUSK" at(10,5).
        lock throttle to 1.0.          
        WAIT 1.
        print "ZAZHIGANIE" at(10,6).
        WAIT 1.        
        local initialpos to ship:facing.
        lock steering to initialpos.
        nextstage().
        WAIT 1.  
        print "TAKE OFF" at(10,7).
        WAIT 3.        
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
        clearscreen.
        set namecyclogram to "LIFTING".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        set GTstart to 4000.
        lock steering to heading(targetHead,targetPitch).
		nextstage().
		CapTWR(maxTWR).
        if altitude > GTstart {
            set cyclogram to 3.
        }
    }
    else if cyclogram = 3{
        set namecyclogram to "GRAVITY_TURN".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        set GTStartSpd to velocity:surface:mag.
        set AP45 to apoapsis.
        set GTendAP to 60000.
        set v45 to 500.
        set pitch to 0.        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).
        until altitude > body:atm:height {
            set vsm to velocity:surface:mag. 
            if GTpitch >= 45 { 
                set Apo45 to apoapsis.
            } 
            if ( vsm < v45 ) {
                set pitch to 90 - arctan( (vsm - GTStartSpd)/(v45 - GTStartSpd) ).
            }
            else {
                set pitch to max(0, 45*(apoapsis - GTendAP) / (AP45 - GTendAP) ).
            }
            lock steering to heading( 90, pitch ).

            print " Pitch: " + round( pitch ) + " deg  " at (5,4).
			print "Apo: " + Round(Apoapsis) at (5,5).
            if apoapsis > 80000 {
                lock throttle to 0.
                lock steering to prograde.
                wait 1.
                set cyclogram to 4.
                break.
            }
            nextstage().
			CapTWR(maxTWR).
        }
    }
    else if cyclogram = 4{
        clearscreen.
        set namecyclogram to "FREE_FLIGHT".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        //stage.//отстыковка второй
        until altitude > apoapsis - 500 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
			if altitude>70000 stage.//сброс обтекателя  
			
        }
		set Checkcircul to 0.
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
	    set namecyclogram to "CIRCULARIZE".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		set Checkcircul to Checkcircul+1.
        set th to 0.
        set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
        set Vcircmag to sqrt(body:mu / body:position:mag).
        set Vcirc to Vcircmag*Vcircdir.
        set deltav to Vcirc - velocity:orbit.
        lock steering to lookdirup( deltav, up:vector).
        wait until vang( facing:vector, deltav ) < 1.
        lock throttle to th.
        until deltav:mag < 0.05 {
            set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
            set Vcircmag to sqrt(body:mu / body:position:mag).
            set Vcirc to Vcircmag*Vcircdir.
            set deltav to Vcirc - velocity:orbit.
            nextstage().
            if vang( facing:vector, deltav ) > 5 { 
                set th to 0.
            }
            else {
                set th to min( 1, 2*deltav:mag * ship:mass / ship:availablethrust ).
            }
            wait 0.1.
            print "deltaV " + deltav:mag at(5,5).
            print "Vcirc " + Vcirc:mag at(5,6).
            print "th " + th at(5,7).
        }
        set th to 0.
        set ship:control:pilotmainthrottle to 0.
        unlock throttle.
		if Checkcircul = 1 {
			set cyclogram to 6.
		}else if Checkcircul = 2 {
			set cyclogram to 10.			
		}
    }
    else if cyclogram = 6{ 
		clearscreen.
		set namecyclogram to "CALCULATING".
		print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		print "Calculating transfer angle..." at(5,4).
		wait 3.
		set DayLen to SHIP:Body:ROTATIONPERIOD/6.
		set ksoR to (sqrt(SHIP:Body:MU)*DayLen/(2*constant():pi))^(2/3).
		set ksoH to ksoR - SHIP:Body:Radius.
		set A1 to (Ship:Body:radius + ship:altitude + ksoR)/2.
		set A2 to ksoR.
		set t_angle to 180*(1 - (A1/A2)^1.5).
		print "Transfer angle: " + t_angle at(5,7).
		wait 1.
		set cyclogram to 7.
    }    
    else if cyclogram = 7{ 
		clearscreen.
		set namecyclogram to "WATING POSITION".
		print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		set CTAngle to false.		
		until CTAngle {
			set cur_angle to KSCLNG-SHIP:GEOPOSITION:LNG.
			if cur_angle<0{
				set cur_angle to cur_angle+360.
			}	
			print "Transfer angle: " + t_angle at(5,4).
			print "Current angle: " + cur_angle at(5,5).
			if ABS(cur_angle - t_angle) < 6
				set kuniverse:timewarp:warp to 0.
			set CTAngle to ABS(cur_angle - t_angle) < 3.    
			wait 1.

		}
		lock steering to heading(90,0).
		wait 1.
		set cyclogram to 8.    
    }
    else if cyclogram = 8{ 
		clearscreen.
		set namecyclogram to "TRANSFER".
		print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		print "Transfer start!" at(5,4).
		lock steering to heading(90,0).
		wait 5.
		until orbit:apoapsis>ksoH {
			lock throttle to min(2*max(1-orbit:apoapsis/ksoH, 0.001),1).
			print "Apo: " + Round(Apoapsis) at(5,7).
			print "Target Apo: " + Round(ksoH) at(5,8).
			print "Apo Delta: " + Round(ksoH-Apoapsis) at(5,9).	
		}
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set throttle to 0. 
		wait 1.
		set cyclogram to 9.
	}
    else if cyclogram = 9{ 
        clearscreen.
        set namecyclogram to "FREE_FLIGHT".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		until (ETA:Apoapsis<50){
			print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,4).
			If ETA:Apoapsis<100 set kuniverse:timewarp:warp to 0.
			wait 1.
		}
        set cyclogram to 5. 
	}	
    else if cyclogram = 10{ 
        clearscreen.    
        set namecyclogram to "SOLAR PANNELS".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2). 
        GEAR ON.
        wait 5.		
        print "SOLAR PANNELS ARE DEPLOYED" at(5,5).
        set cyclogram to 11.
        wait 3.        
    }
    else if cyclogram = 11{ 
        clearscreen.    
        set namecyclogram to "COMMUNICATION".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2). 
        SetDishTarget("HighGainAntenna5",0,"Molniya102").
		wait 1.
		print "ANTENNA #1 IS TUNED TO REPEATER Molniya102" at(5,5).
		wait 1.		
		SetDishTarget("HighGainAntenna5",1,"Kerbin").
		print "ANTENNA #2 IS TUNED TO FLIGHT CONTROL CENTER" at(5,6).
        wait 3.      		
        set cyclogram to 0.
    }
}
    if cyclogram = 0 {
        set namecyclogram to "FINALIZATION".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        wait 1.
        clearscreen.
        SAS off.
        RCS off.
        unlock steering.
        unlock throttle.
        set ship:control:pilotmainthrottle to 0.
        print "PROGRAM SUCCESSFULLY FINISHED. NO ERROR." at(5,10).
        wait 1.
    }
    
set end to time.
log begin to begin1.txt.
log end to end1.txt.