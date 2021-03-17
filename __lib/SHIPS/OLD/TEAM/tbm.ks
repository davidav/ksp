//вывод на  орбиту  Т=0.5 час (238 601 м) TEAM_base_module
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearscreen.

copypath("0:/dock", "").
copypath("0:/del", "").

set SatelliteAngle to 0.
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

//Считает угол к горизонту в апоцентре при циркуляризации.
FUNCTION ApoBurn
{
	set Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.	//Считаем горизонтальную скорость
	set Vz to ship:verticalspeed. // это вертикальная скорость
	set Rad to ship:Body:radius+ship:altitude. // Радиус орбиты.
	set Vorb to sqrt(ship:Body:Mu/Rad). //Это 1я косм. на данной высоте.
	set g_orb to ship:Body:Mu/Rad^2. //Ускорение своб. падения на этой высоте.
	set ThrIsp to EngThrustIsp. //EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
	if Throttle>0
		set AThr to ThrIsp[0]*Throttle/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
	else
		set AThr to ThrIsp[0]/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
	set ACentr to Vh^2/Rad. //Центростремительное ускорение.
	set DeltaA to g_orb-ACentr-Max(Min(Vz,2),-2). //Уск своб падения минус центр. ускорение с поправкой на гашение вертикальной скорости.
	set Fi to arcsin(DeltaA/AThr). // Считаем угол к горизонту так, чтобы держать вертикальную скорость = 0.
	set dVh to Vorb-Vh. //Дельта до первой косм.
	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).	//Возвращаем лист с данными.
}

//EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
FUNCTION EngThrustIsp
{
	//создаем пустой лист ens
  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
  set ens_fuelflow to 0.
  //запихиваем все движки в лист myengines
  list engines in myengines.
	
	//забираем все активные движки из myengines в ens.
  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }
	//собираем суммарную тягу и Isp по всем активным движкам
  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
    set ens_fuelflow to ens_fuelflow + en:fuelflow.
	}
  //Тягу возвращаем суммарную, а Isp средний.
  RETURN LIST(ens_thrust, ens_isp/ens:length, ens_fuelflow).
}

until cyclogram = 0 {
    if cyclogram = 1{
        set namecyclogram to "START".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
            PRINT "..." + countdown at(5,4).
            WAIT 1.
        }
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
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
        clearscreen.
        set namecyclogram to "LIFTING".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
        set GTstart to 15000.// высота начала разворота
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
        set GTStartSpd to velocity:surface:mag. // при какой скорости начали разворот
        set AP45 to apoapsis. // апоцентр при тангаже 45 градусов
        set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
        set v45 to 500. // скорость, при которой угол тангажа должен быть 45 градусов
        set pitch to 0.        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).//угол от горизонтали до курса
		set Horbop to 80000.//высота опорной орбиты
        until altitude > Horbop {
			set vsm to velocity:surface:mag. // величина скорости относительно поверхности 
            if GTpitch >= 45 { 
                set Apo45 to apoapsis. // какой апоцентр был при тангаже 45 градусов
            } 
            if ( vsm < v45 ) {
                set pitch to min(90, 90 - arctan((vsm - GTStartSpd)/(v45 - GTStartSpd))).
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
		wait 5.
		lights on.//сброс обтекателя
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
        }
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
        clearscreen.
        set namecyclogram to "CIRCULARIZE REFERENCE ORBIT".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		lock throttle to 1.
		set OLDLAT to 0.
		set StopBurn to false.
		until StopBurn{
			set CirkData to ApoBurn. //Достаем данные по тангажу и прочее из функции ApoBurn
			if CirkData[4]<0
				set StopBurn to true.	//Если достигли 1й космической, то стоп.
			else if CirkData[4]<100		//Если дельта до 1й космической менее 100м/с, то начинаем плавно снижать тягу.
				lock throttle to Max(CirkData[4]/100, 0.01).
			set LATVEL to SHIP:GEOPOSITION:LAT-OLDLAT.		
			lock steering to Heading(90+(SHIP:GEOPOSITION:LAT*250)+(LATVEL*120000), CirkData[0]). 
			set OLDLAT to SHIP:GEOPOSITION:LAT.
			print "Fi: "+Round(CirkData[0],2) at(5,4).	
			print "Vh: "+Round(CirkData[1],4) at(5,5).
			print "Vz: "+Round(CirkData[2],4) at(5,6).	
			print "Vorb: "+Round(CirkData[3],4) at(5,7).	
			print "dVh: "+Round(CirkData[4],4) at(5,8).		
			print "DeltaA: "+Round(CirkData[5],4) at(5,9).	
			print "LAT: " + Round(SHIP:GEOPOSITION:LAT,5) at(5,10).
			print "LATVEL: " + Round(LATVEL,5) at(5,11).
		}
		lock throttle to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		unlock steering.
		wait 1.
		print "WE'RE ON ORBIT!" at(5,15).
		wait 5.
		print "Apoapsis: " + Round(Ship:Orbit:Apoapsis) at(5,16).
		wait 1.
		print "Periapsis: " + Round(Ship:Orbit:Periapsis) at(5,17).
		wait 1.
		print "Eccentricity: " + Round(Ship:Orbit:Eccentricity,6) at(5,18).
		wait 1.
		print "Inclination: " + Round(Ship:Orbit:Inclination,3) at(5,19).
		wait 5.
		set cyclogram to 6.    
	}
	else if cyclogram = 6{ 
		clearscreen.
		set namecyclogram to "CALCULATING".
		print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		print "Calculating transfer angle..." at(5,4).
		wait 3.
		set DayLen to SHIP:Body:ROTATIONPERIOD/9.//период обращения на требуемой орбите ( 0.5 час)
		set ksoR to (sqrt(SHIP:Body:MU)*DayLen/(2*constant():pi))^(2/3).// радиус требуемой орбиты
		set ksoH to ksoR - SHIP:Body:Radius.// высота требуемой орбиты
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
        set cyclogram to 10.
	}
    else if cyclogram = 10{ 
        clearscreen.
        set namecyclogram to "CIRCULARIZE TARGET ORBIT".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
		lock steering to Heading(90,0).
		wait 30.
		lock throttle to 0.3.
		wait 1.
		set StopBurn to false.
		until StopBurn{
			set CirkData to ApoBurn.
			if Ship:ORBIT:SEMIMAJORAXIS>ksoR
				set StopBurn to true.
			else if CirkData[4]<100		
				lock throttle to min(Max(1-ORBIT:SEMIMAJORAXIS/ksoR, 0.001),1).
			lock steering to Heading(90, CirkData[0]).
			print "Fi: "+Round(CirkData[0],2) at(5,4).	
			print "Vh: "+Round(CirkData[1],4) at(5,5).
			print "Vz: "+Round(CirkData[2],4) at(5,6).	
			print "Vorb: "+Round(CirkData[3],4) at(5,7).	
			print "dVh: "+Round(CirkData[4],4) at(5,8).		
			print "DeltaA: "+Round(CirkData[5],4) at(5,9).	
			print "LAT: " + Round(SHIP:GEOPOSITION:LAT,5) at(5,10).
			print "LNG: " + Round(SHIP:GEOPOSITION:LNG,5) at(5,11).
			print "SemiMajor Axis: "+Round(Ship:ORBIT:SEMIMAJORAXIS) at(5,12).	
		}
		lock throttle to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		lock steering to retrograde.
        set cyclogram to 11.		
	}		
    else if cyclogram = 11{ 
        clearscreen.    
        set namecyclogram to "SOLAR PANNELS".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2). 
        GEAR ON.
        wait 5.		
        print "SOLAR PANNELS ARE DEPLOYED" at(5,5).
        set cyclogram to 12.
        wait 3.        
    }
    else if cyclogram = 12{ 
        clearscreen.    
        set namecyclogram to "COMMUNICATION".
        print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2). 
        SetDishTarget("HighGainAntenna5",0,"Molniya102").
		wait 1.
		print "ANTENNA #1 IS TUNED TO REPEATER Molniya102" at(5,5).
		wait 1.		
		SetDishTarget("HighGainAntenna5",1,"Molniya104").
		print "ANTENNA #2 IS TUNED TO Molniya104" at(5,6).
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
    wait 3.
}

run del.

