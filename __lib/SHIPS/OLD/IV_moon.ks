//вывод на  опорную орбиту  80000, трансфер к муне, возврат IV_moon
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 40.
SET TERMINAL:HEIGHT TO 25.
clearscreen. 

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.
set targetHead to 90.
set cyclogram to 1.
set maxTWR to 2.0.
set SatelliteAngle to 5.

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
function SetDishTarget{//"HighGainAntenna5",1,"Molniya104"
    parameter DishBlockName.
    parameter BlockIndex. 
    parameter DishTarget.
    set p to ship:partsnamed(DishBlockName)[BlockIndex].
    set m to p:getmodule("ModuleRTAntenna").
    m:doevent("Activate").
    m:setfield("target", DishTarget).
}

function ApoBurn//Считает угол к горизонту в апоцентре при циркуляризации.
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
	set Fi to max (1, arcsin(DeltaA/AThr)). // Считаем угол к горизонту так, чтобы держать вертикальную скорость = 0.

	set dVh to Vorb-Vh. //Дельта до первой косм.
	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).	//Возвращаем лист с данными.
}

//EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
function EngThrustIsp
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
function DisplayCyclogram{
	parameter namecyclogram.
	clearscreen.
    print "CYCLOGRAM: "+cyclogram+" - "+namecyclogram at(5,2).
}

FUNCTION CheckMunAngle
{
	set VecS to Ship:position-body("Kerbin"):position.
    set NeedPosition to body("Mun"):GEOPOSITION:LNG-SatelliteAngle.
	set VecM to NeedPosition-body("Kerbin"):position.
	set VecHV to VXCL(ship:up:vector, ship:velocity:orbit).
	set VecSM to body("Mun"):position-Ship:position.
	set m_angle to CalculateMunAngle.
	set cur_angle to VANG(VecM,VecS).
	if VANG(VecHV,VecSM)>90
		set cur_angle to -cur_angle.
	print "Munar angle: " + m_angle.
	print "Current angle: " + cur_angle.
	return ABS(cur_angle - m_angle) < 3.
}

function CalculateMunAngle
{
	SET A1 to (2*body("Kerbin"):radius + body("Mun"):altitude + ship:altitude)/2.
	SET A2 to body("Kerbin"):radius+body("Mun"):altitude.
	return 180*(1 - (A1/A2)^1.5).
}


until cyclogram = 0 {
    if cyclogram = 1{
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
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
		DisplayCyclogram ("LIFTING").
        set GTstart to 3000.// высота начала разворота
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
        set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
        set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов
        set pitch to 0.        
        lock GTpitch to 90 - vang( up:vector, velocity:surface ).//угол от горизонтали до курса
		set Horbop to 80000.//высота опорной орбиты
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
        set Obtekatel to 1.
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            if (altitude > 70000 and Obtekatel){
                stage.//LIGHTS ON.
                set Obtekatel to 0.
            }	
        }
        stage.
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
		DisplayCyclogram ("CIRCULARIZE_BASIC_ORBIT").		
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
		set cyclogram to 6.    
	}
    else if cyclogram = 6{
		DisplayCyclogram ("Calculating munar angle...").				
        WAIT 5.
        LOCK Steering TO PROGRADE.
        UNTIL CheckMunAngle {
            WAIT 1.
            clearscreen.
        }
        set cyclogram to 7.
    }
    else if cyclogram = 7{ 
		DisplayCyclogram ("Transfer start!").	
        SET Man_point TO PROGRADE.
        LOCK Steering TO Man_point.
        WAIT 10.
        set the_mun to body("Mun").
        UNTIL ORBIT:Apoapsis>the_mun:Altitude{
            nextstage().
            if (orbit:Apoapsis/the_mun:Altitude<0.9){
                Lock Throttle to 1.
            }else{
                Lock Throttle to 0.1.
            }	
        }
        set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
        set Throttle to 0. 
        WAIT 1.

        print "Transfer burn complete, We're on the way to Mun!"at(5,7).

        set cyclogram to 0.
        wait 3.        
    }
    else if cyclogram = 8{ 
		DisplayCyclogram ("COMMUNICATION").		
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