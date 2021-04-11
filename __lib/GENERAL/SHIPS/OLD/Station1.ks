//вывод на низкую орбиту станция1
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").


clearscreen. 
set Horb to body:atm:height + 10000.//высота орбиты
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.	// Ќачальный угол к горизонту («енит).
set targetHead to 90.	// Ќаправление (¬осток).
set cyclogram to 1. // Ќачинаем с циклограммы 1 (старт).
set maxTWR to 2.5.

function nextstage{
  until ship:availablethrust > 0 {
    wait 0.5.
    stage.
  }
}

function CapTWR {
  parameter maxTWR is 3.0.
  local g0 to Kerbin:mu/Kerbin:radius^2. // TWR считается относительно веса на уровне моря
  lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ). // без max() будет деление на ноль при пропадании тяги
}

function SetDishTarget{
    parameter DishBlockName. // ѕринимаем им¤ антенны
    parameter BlockIndex. 
    parameter DishTarget. //÷ель дл¤ антенны.
    set p to ship:partsnamed(DishBlockName)[BlockIndex].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("Activate").
    m:setfield("target", DishTarget).
}

// «апуск циклограмм ========

until cyclogram = 0 {

    if cyclogram = 1{
        set namecyclogram to "START".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
            PRINT "..." + countdown at(10,4).
            WAIT 1.
        }
        print "ZEMLYA - BORT" at(10,4).
        //stage.//кабель-мачта
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
        set GTstart to 1000. // высота начала разворота        
        lock steering to heading(targetHead,targetPitch).
		nextstage().
		CapTWR(maxTWR).
        if altitude > GTstart {//если подн¤лись на высоту разворота
            set cyclogram to 3.
        }
    }
     
    else if cyclogram = 3{
        set namecyclogram to "GRAVITY_TURN".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        
        set GTStartSpd to velocity:surface:mag. // при какой скорости начали разворот
        set AP45 to apoapsis. // апоцентр при тангаже 45 градусов
        set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
        set v45 to 500. // скорость, при которой угол тангажа должен быть 45 градусов
        

        set pitch to 0.        
        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).//угол от горизонтали до курса
        until altitude > body:atm:height {
            set vsm to velocity:surface:mag. // величина скорости относительно поверхности 

            if GTpitch >= 45 { 
                set Apo45 to apoapsis. // какой апоцентр был при тангаже 45 градусов
            } 
            if ( vsm < v45 ) {
                set pitch to 90 - arctan( (vsm - GTStartSpd)/(v45 - GTStartSpd) ). // мен¤ем тангаж
            }
            else {
                set pitch to max(0, 45*(apoapsis - GTendAP) / (AP45 - GTendAP) ). // линейно мен¤ем тангаж, на GTendAP укладываем ракету горизонтально
            }
            lock steering to heading( 90, pitch ).

            print " Pitch: " + round( pitch ) + " deg  " at (10,4).

            if apoapsis > Horb {
                lock throttle to 0.
                lock steering to prograde.
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
        until altitude > apoapsis - 500 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).  
        }
        set cyclogram to 5. 
        
    }
    else if cyclogram = 5{    
        set namecyclogram to "CIRCULARIZE".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        set th to 0. // в этой переменной будет необходимый уровень т¤ги
        set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized. // направление круговой скорости такое же, как у горизонтальной компоненты орбитальной скорости
        set Vcircmag to sqrt(body:mu / body:position:mag). // mu - это гравитационный параметр планеты, произведение массы на гравитационную посто¤нную
        set Vcirc to Vcircmag*Vcircdir.
        set deltav to Vcirc - velocity:orbit.

        // начинаем прожиг, поворачива¤ ракету посто¤нно в сторону маневра
        lock steering to lookdirup( deltav, up:vector).
        wait until vang( facing:vector, deltav ) < 1. // убеждаемс¤, что прожиг начинаетс¤ в нужной ориентации
        lock throttle to th.
        until deltav:mag < 0.05 {

            set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
            set Vcircmag to sqrt(body:mu / body:position:mag).
            set Vcirc to Vcircmag*Vcircdir.
            set deltav to Vcirc - velocity:orbit.

            nextstage().

            if vang( facing:vector, deltav ) > 5 { 
                set th to 0. // если сильно не туда смотрим, надо глушить двигатель
            }
            else {
                set th to min( 1, deltav:mag * ship:mass / ship:availablethrust ). // снижаем т¤гу, если приращение скорости нужно небольшое
            }
            wait 0.1.
            
            print "deltaV " + deltav:mag at(5,5).
            print "Vcirc " + Vcirc:mag at(5,6).
            print "th " + th at(5,7).

        }
        set th to 0.
        set ship:control:pilotmainthrottle to 0.
        unlock throttle.
        set cyclogram to 6.    
    }
    else if cyclogram = 6{    
        set namecyclogram to "COMMUNICATION".
        clearscreen.
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2). 
        SetDishTarget("HighGainAntenna5",0,"Molniya102").
        set cyclogram to 0.
        wait 3.        
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
