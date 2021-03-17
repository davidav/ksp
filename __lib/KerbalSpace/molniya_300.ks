// molniya_300 - спутник связи на геостационарной орбите 300 гр от ЦУП
//вывод на  опорную орбиту  80000 
//включение антены на Кербин
//расчет и занятие требуемого угла
//трансфер на геостационарную орбиту 2 863 330 000


CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 50.
SET TERMINAL:HEIGHT TO 15.
clearscreen. 


set nameProgramm to "molniya_300".

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set SatelliteAngle to 300.//положение спутника относительно ЦУП
set Horbop to 80000.//высота опорной орбиты
set GTstart to 3000.// высота начала разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов

set KSCLNG to SHIP:GEOPOSITION:LNG+SatelliteAngle.
set targetPitch to 90.
set targetHead to 90.
set cyclogram to 1.
set maxTWR to 1.8.

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
    print "PROGRAMM: "+nameProgramm at(5,1).
    print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
}
function SetLinkTarget{
    parameter AntName. 
    parameter BlockIndex. 
    parameter LinkTarget. 
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", LinkTarget).
}
function EnableDevice{
    parameter deviceName.
    parameter blockIndex.
    parameter moduleName.
    parameter actionName.
    SET p TO SHIP:partsnamed(deviceName)[blockIndex].
    SET m TO p:GETMODULE(moduleName).
    m:DOEVENT(actionName).
}

until cyclogram = 0 {
    if cyclogram = 1{
		DisplayCyclogram ("START").
        WAIT 1.
        lock throttle to 1.0. 
        print "ZEMLYA - BORT" at(5,4).
        //stage.
        WAIT 1.
        print "PUSK" at(5,5).
        WAIT 1.
        print "ZAZHIGANIE" at(5,6).
        WAIT 1.        
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
            lock steering to heading( targetHead, pitch ).
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
		wait 5.
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
        }
        wait 0.5.
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
		DisplayCyclogram ("CIRCULARIZE_BASIC_ORBIT").
        local th to 0.
        local Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.        
        local Vcircmag to sqrt(body:mu / body:position:mag). 
        local Vcirc to Vcircmag*Vcircdir.
        local deltav to Vcirc - velocity:orbit.       
        lock steering to lookdirup( deltav, up:vector).
        wait until vang( facing:vector, deltav ) < 1. 
        lock throttle to th.
        until deltav:mag < 0.05 {
            set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
            set Vcircmag to sqrt(body:mu / body:position:mag).
            set Vcirc to Vcircmag*Vcircdir.
            set deltav to Vcirc - velocity:orbit.
            if vang( facing:vector, deltav ) > 5 { 
              set th to 0. // если сильно не туда смотрим, надо глушить двигатель
            }
            else {
              set th to min( 1, deltav:mag * ship:mass / max( ship:availablethrust, 0.001 ) ). // снижаем тягу, если приращение скорости нужно небольшое
            }
            wait 0.1.
            nextstage().
        }

		lock throttle to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
        unlock throttle.        
		wait 1.
		print "BASIC ORBIT" at(5,15).
		wait 5.
        set cyclogram to 6. 
    }
        else if cyclogram = 6{
 		DisplayCyclogram ("COMMUNICATION").
        SetLinkTarget("mediumDishAntenna",0,"Kerbin").
		wait 1.
		print "ANTENNA #1 IS TUNED TO REPEATER Kerbin" at(5,5).
		wait 1.     
        set cyclogram to 7.
    }    
    else if cyclogram = 7{
		DisplayCyclogram ("CALCULATING ...").
		wait 3.
		set DayLen to SHIP:Body:ROTATIONPERIOD.
		set ksoR to (sqrt(SHIP:Body:MU)*DayLen/(2*constant():pi))^(2/3).
		set ksoH to ksoR - SHIP:Body:Radius.
		set A1 to (Ship:Body:radius + ship:altitude + ksoR)/2.
		set A2 to ksoR.
		set t_angle to 180*(1 - (A1/A2)^1.5).
		print "Transfer angle: " + t_angle at(5,7).
		wait 1.
		set cyclogram to 8.
	}    
	else if cyclogram = 8{
 		DisplayCyclogram ("WATING POSITION").   
		set CTAngle to false.		
		until CTAngle {
			set cur_angle to KSCLNG-SHIP:GEOPOSITION:LNG.
			if cur_angle<0{
				set cur_angle to cur_angle+360.
			}	
			print "Transfer angle: " + Round(t_angle) at(5,4).
			print "Current angle: " + Round(cur_angle) at(5,5).
			if ABS(cur_angle - t_angle) < 6
				set kuniverse:timewarp:warp to 0.
			set CTAngle to ABS(cur_angle - t_angle) < 3.    
			wait 1.
	}
		lock steering to heading(targetHead,0).
		wait 1.
		set cyclogram to 9.    
    }
    else if cyclogram = 9{
 		DisplayCyclogram ("TRANSFER").       
		lock steering to heading(targetHead,0).
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
		set cyclogram to 10.
	}
    else if cyclogram = 10{
 		DisplayCyclogram ("FREE_FLIGHT").        
		until (ETA:Apoapsis<50){
			print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,4).
			If ETA:Apoapsis<100 set kuniverse:timewarp:warp to 0.
			wait 1.
		}
        set cyclogram to 11.
	}
    else if cyclogram = 11{
 		DisplayCyclogram ("CIRCULARIZE TARGET ORBIT").            
        local th to 1. 
        local Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
        local Vcircmag to sqrt(body:mu / body:position:mag). 
        local Vcirc to Vcircmag*Vcircdir.
        local deltav to Vcirc - velocity:orbit.
        lock steering to lookdirup( deltav, up:vector).
        wait until vang( facing:vector, deltav ) < 1. 
        lock throttle to th.
        until deltav:mag < 0.05 {
            set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
            set Vcircmag to sqrt(body:mu / body:position:mag).
            set Vcirc to Vcircmag*Vcircdir.
            set deltav to Vcirc - velocity:orbit.
            if vang( facing:vector, deltav ) > 5 { 
              set th to 0. 
            }
            else {
              set th to min( 1, deltav:mag * ship:mass / max( ship:availablethrust, 0.001 ) ). 
            }
            wait 0.1.
        }

		lock throttle to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
        unlock throttle.        
		unlock steering.
		wait 1.
		print "WE'RE ON ORBIT!" at(5,15).
		wait 5.
        set cyclogram to 0. 
    }

}
    if cyclogram = 0 {
		DisplayCyclogram ("FINALIZATION").        
        wait 1.
        SAS off.
        RCS off.
        unlock steering.
        unlock throttle.
        set ship:control:pilotmainthrottle to 0.
        print "PROGRAM SUCCESSFULLY FINISHED. NO ERROR." at(5,10).
        wait 1.
		clearscreen.  
    }