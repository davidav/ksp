//V_spasatel
//два места
//расчет и ожидание окна запуска ()
//вывод на  опорную орбиту  80000 (Horbop)
//трансфер на орбиту муны 11 400 000 и 10гр справа
//включение антен
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 40.
SET TERMINAL:HEIGHT TO 15.
clearscreen. 

//set target to vessel("Craft1").//Устанавливаем цель
set RequestDistance to 280000.//Требуемая дальность

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.
set targetHead to 90.
set cyclogram to 2.
set maxTWR to 2.0.
set Horbop to 80000.//высота опорной орбиты
set GTstart to 3000.// высота начала разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов




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
    print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
}


until cyclogram = 0 {
    if cyclogram = 1{
		DisplayCyclogram ("WAITING...").
        lock DistanceTarget to (Target:POSITION-SHIP:POSITION):MAG.
        until DistanceTarget < RequestDistance{
            wait 1.
            print "Distance Target: " +DistanceTarget at(5,5).
        }
        set cyclogram to 2.
    } 

    if cyclogram = 2{
		DisplayCyclogram ("START").
        WAIT 1.
        print "ZEMLYA - BORT" at(5,4).
        //stage.
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
        set cyclogram to 3.
    }  
    else if cyclogram = 3{
		DisplayCyclogram ("LIFTING").
        lock steering to heading(targetHead,targetPitch).
		nextstage().
		CapTWR(maxTWR).
        if altitude > GTstart {
            set cyclogram to 4.
        }
    }
    else if cyclogram = 4{
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
            lock steering to heading( 90, pitch ).
            print "Pitch: " + round( pitch ) + " deg  " at (5,4).
			print "Apo: " + Round(Apoapsis) at (5,5).

			if apoapsis > Horbop {
                lock throttle to 0.
                set cyclogram to 5.
                break.
            }
            nextstage().
			CapTWR(maxTWR). 
        }
    }
    else if cyclogram = 5{
		DisplayCyclogram ("FREE_FLIGHT").
        LOCK Steering to PROGRADE.	 	
		wait 5.
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).

        }
        wait 0.5.
        set cyclogram to 6. 
    }
    else if cyclogram = 6{
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
        LOCK Steering to PROGRADE.        
		wait 1.
		print "ORBIT" at(5,7).
		wait 5.
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