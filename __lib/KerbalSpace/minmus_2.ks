//вывод на  орбиту  100000 наклонение 6
// включение 2 антенн

set nameProgramm to "minmus_2".

CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 40.
SET TERMINAL:HEIGHT TO 15.
clearscreen. 




set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.
set targetHead to 80.
set cyclogram to 1.
set maxTWR to 1.8.
set Horbop to 100000.//высота опорной орбиты

set GTstart to 3000.// высота начала разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов
set StageTimePause to 0.//пауза после отработки боковых ускорителей первой ступени перед  их отводом 

//set firstStage to "FIRST". // тэг для отделения первых отработавших боковых ускорителей первой ступени
//set seсondStage to "SECOND". // тэг для отделения вторых отработавших боковых ускорителей первой ступени


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

function DisplayCyclogram{
	parameter namecyclogram.
	clearscreen.
    print "CYCLOGRAM: "+nameProgramm at(5,1).
    print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
}

function SetLinkTarget{
    parameter AntName. // Принимаем имя антенны
    parameter BlockIndex. 
    parameter LinkTarget. //Цель для антенны.
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", LinkTarget).
}

until cyclogram = 0 {

    if cyclogram = 1{
		DisplayCyclogram ("START").
        WAIT 1.
        print "ZEMLYA - BORT" at(5,4).
        WAIT 1.
        print "PUSK" at(5,5).
        lock throttle to 1.0.          
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
        set GTStartSpd to velocity:surface:mag. // при какой скорости начали разворот
        set AP45 to apoapsis. // апоцентр при тангаже 45 градусов
        set pitch to 0.        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).//угол от горизонтали до курса
        until altitude > Horbop {
			set vsm to velocity:surface:mag. // величина скорости относительно поверхности 
            if GTpitch >= 45 { 
                set Apo45 to apoapsis. // какой апоцентр был при тангаже 45 градусов
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
        until ETA:Apoapsis<2 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            }	
        wait 0.5.
        set cyclogram to 6. 
    }
    else if cyclogram = 5{
		DisplayCyclogram ("CIRCULARIZE_BASIC_ORBIT").
        local th to 0. // в этой переменной будет необходимый уровень тяги
        local Vcircdir to vxcl( up:vector, velocity:orbit ):normalized. // направление круговой скорости такое же, как у горизонтальной компоненты орбитальной скорости
        local Vcircmag to sqrt(body:mu / body:position:mag). // mu - это гравитационный параметр планеты, произведение массы на гравитационную постоянную
        local Vcirc to Vcircmag*Vcircdir.
        local deltav to Vcirc - velocity:orbit.
        // начинаем прожиг, поворачивая ракету постоянно в сторону маневра
        lock steering to lookdirup( deltav, up:vector).
        wait until vang( facing:vector, deltav ) < 1. // убеждаемся, что прожиг начинается в нужной ориентации
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
		unlock steering.
		wait 1.
		print "ON ORBIT!" at(5,10).
        LOCK Steering to PROGRADE.
		wait 5.
		set cyclogram to 0.    
	}

		else if cyclogram = 6{
 		DisplayCyclogram ("COMMUNICATION").           
        SetLinkTarget("HighGainAntenna5",0,"Molniya_60").//mediumDishAntenna
		print "ANTENNA #1 IS TUNED TO MOLNIYA_60" at(5,5).
		wait 1.		
		SetLinkTarget("HighGainAntenna5",1,"Molniya_180").//HighGainAntenna5
		print "ANTENNA #2 IS TUNED TO MOLNIYA_180" at(5,7).
        set cyclogram to 5.
    }
	
}
    if cyclogram = 0 {
		DisplayCyclogram ("FINALIZATION").        
        wait 1.
        SAS off.
        RCS off.
        unlock throttle.
        LOCK Steering to PROGRADE.
        set ship:control:pilotmainthrottle to 0.
        print "NO ERROR." at(5,10).
        wait 1.
		clearscreen.  
    }