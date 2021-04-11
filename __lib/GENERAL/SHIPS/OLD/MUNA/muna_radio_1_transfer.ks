








//Начинаем циркуляризацию
LOCK Throttle to 1.
set StopBurn to false.
until StopBurn
{
	Set CirkData to ApoBurn. //Достаем данные по тангажу и прочее из функции ApoBurn

	if CirkData[4]<0
		set StopBurn to true.	//Если достигли 1й космической, то стоп.
	else if CirkData[4]<100		//Если дельта до 1й космической менее 100м/с, то начинаем плавно снижать тягу.
		LOCK Throttle to Max(CirkData[4]/100, 0.01).

	LOCK Steering to Heading(90, CirkData[0]). //Угол тагажа выставляем по данным, возвращенным функцией.

// Чего возвращает ApoBurn
//				0	1	2   3     4    5 			
//	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).	
	
	clearscreen.
	print "Fi: "+CirkData[0].	
	print "Vh: "+CirkData[1].
	print "Vz: "+CirkData[2].	
	print "Vorb: "+CirkData[3].	
	print "dVh: "+CirkData[4].		
	print "DeltaA: "+CirkData[5].	
}

//Мы на орбите, выключаем тягу.
LOCK Throttle to 0.
Set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
unlock steering.

WAIT 1.

clearscreen.
print "WE'RE ON ORBIT!".
WAIT 5.

print "Time to patch Orbit.".
WAIT 5.

PatchOrbit(true).
clearscreen.
clearvecdraws().
WAIT 1.

print "Apoapsis: " + Ship:Orbit:Apoapsis.
WAIT 1.
print "Periapsis: " + Ship:Orbit:Periapsis.
WAIT 1.
print "Eccentricity: " + Ship:Orbit:Eccentricity.

WAIT 5.

LOCK Steering TO PROGRADE.

print "Calculating munar angle...".
WAIT 10.

UNTIL CheckMunAngle
{
	WAIT 1.
	clearscreen.
}

print "Transfer start!".

SET Man_point TO PROGRADE.
LOCK Steering TO Man_point.
WAIT 10.
set the_mun to body("Mun").
UNTIL ORBIT:Apoapsis>the_mun:Altitude
{
	if (orbit:Apoapsis/the_mun:Altitude<0.9)
	{
		Lock Throttle to 1.
	}
	else{
		Lock Throttle to 0.1.
	}	
}

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
set Throttle to 0. WAIT 1.

print "Transfer burn complete, We're on the way to Mun!".

UNTIL (Ship:Body=the_mun) and (Ship:Altitude<1000000)
{
	WAIT 10.
}
print "Deploy antenna".
TOGGLE LIGHTS.
WAIT 10.


print "Lets farm science from Mun high orbit".
ScienceExp("Goo1", TRUE).
ScienceExp("Therm1", TRUE).
ScienceExp("Bar1", TRUE).
ScienceExp("SC1", TRUE).

UNTIL (Ship:Body=the_mun) and (Ship:Altitude<12000)
{
	WAIT 10.
}

print "Lets farm science from Mun low orbit".
ScienceExp("Goo2", TRUE).
ScienceExp("Therm2", TRUE).
ScienceExp("Bar2", TRUE).
print "FAREWELL..".

function CalculateMunAngle
{
	SET A1 to (2*body("Kerbin"):radius + body("Mun"):altitude + ship:altitude)/2.
	SET A2 to body("Kerbin"):radius+body("Mun"):altitude.
	return 180*(1 - (A1/A2)^1.5).
}

FUNCTION CheckMunAngle
{
	set VecS to Ship:position-body("Kerbin"):position.
	set VecM to body("Mun"):position-body("Kerbin"):position.
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

//Считает угол к горизонту в апоцентре при циркуляризации.
FUNCTION ApoBurn
{
	set Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.	//Считаем горизонтальную скорость
	set Vz to ship:verticalspeed. // это вертикальная скорость
	set Rad to ship:body:radius+ship:altitude. // Радиус орбиты.
	set Vorb to sqrt(ship:body:Mu/Rad). //Это 1я косм. на данной высоте.
	set g_orb to ship:body:Mu/Rad^2. //Ускорение своб. падения на этой высоте.
	set ThrIsp to EngThrustIsp. //EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
	set AThr to ThrIsp[0]*Throttle/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
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
  }
  //Тягу возвращаем суммарную, а Isp средний.
  RETURN LIST(ens_thrust, ens_isp/ens:length).
}


// Эта функция активирует науч модуль с указанным именем
FUNCTION ScienceExp 
{
PARAMETER SciBlockName. // Принимаем имя термометра
PARAMETER Transmit. //Транслировать или сохранить данные эксперимента.
set SciBlock to ship:partsTagged(SciBlockName)[0]. // Находим соотв. деталь корабля и помещаем в переменную gradusnik
set ScienceModule to SciBlock:GetModule("ModuleScienceExperiment"). // Находим внутри этой части модуль, отвечающий за "науку".
ScienceModule:DEPLOY. // Активируем его.
IF Transmit {
WAIT UNTIL ScienceModule:HASDATA.
if ADDONS:RT:HASCONNECTION(SHIP){
	ScienceModule:TRANSMIT.
	PRINT "Science data from " + SciBlockName + " transmitted to KSC".}
else {
	PRINT "!!! NO CONNECTION !!!".
}
	
}
ELSE PRINT "Science data stored in " + SciBlockName.
}



FUNCTION PatchOrbit
{
DECLARE PARAMETER DoPatch IS FALSE.
set StopBurn to false.
	UNTIL StopBurn
	{
		set ThrIsp to EngThrustIsp. //EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
		set AThr to ThrIsp[0]/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 

		set V1 to ship:velocity:orbit.		
		set V2 to VXCL(Ship:UP:vector, ship:velocity:orbit):NORMALIZED*sqrt(ship:body:Mu/(ship:body:radius+ship:altitude)).
		set vecCorrection to V2-V1.
		clearscreen.	
		print "Correction: " + vecCorrection:MAG.
		
		SET CV TO VECDRAWARGS(V(0,0,0), vecCorrection:NORMALIZED*10, RGB(1,0,0), "Delta: "+vecCorrection:MAG + " m/s" , 1.0, TRUE, 0.2).
		if DoPatch
		{ 
			if SAS TOGGLE SAS.
			LOCK Steering to vecCorrection.
			if VANG(vecCorrection, ship:facing:forevector)<1
				if AThr>0
					LOCK Throttle to  min(max(vecCorrection:MAG/(AThr*5), 0.0001),1).	
			else
				LOCK Throttle to 0.
		}	
		
		print "Apoapsis: " + Ship:Orbit:Apoapsis.
		print "Periapsis: " + Ship:Orbit:Periapsis.
		print "Eccentricity: " + Ship:Orbit:Eccentricity.	
		if (vecCorrection:MAG<0.001) OR (NOT DoPatch)
			{
				set StopBurn to true.
			}
	}
	LOCK Throttle to 0.
	Set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
	UNLOCK Steering.
}