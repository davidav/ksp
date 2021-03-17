
Wait 1.
print "3".
Wait 1.
print "2".
Wait 1.
print "1".
Wait 1.
print ">>>POEHALI<<<".

// Твердотопливный ускоритель отрабатывает чисто вертикально.
LOCK Steering to Heading(90,90). 
LOCK Throttle to 1.
STAGE.
WAIT UNTIL STAGE:SOLIDFUEL<1.

//Вторая ступень отрабатывает тангаж от 90 до 40 градусов по мере расхода топлива.
//Апоапсис в результате получится около 75 км. Это чисто опытная подгонка (да, нубство, хехе)
STAGE.
SET MaxFuel to STAGE:OXIDIZER.
LOCK Steering to Heading(90,90-50*(1-STAGE:OXIDIZER/MaxFuel)).
WAIT UNTIL STAGE:OXIDIZER<1.
LOCK Steering to Heading(90,40).
LOCK Throttle to 0.
WAIT 1.
STAGE.

//Ждем апоапсиса
UNTIL ETA:Apoapsis<1
{
clearscreen.
print "ETA:Apo: " + ETA:Apoapsis.
}
//Начинаем циркуляризацию
STAGE.
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
WAIT 1.

clearscreen.
print "WE'RE ON ORBIT!".
WAIT 5.
print "Apoapsis: " + Ship:Orbit:Apoapsis.
WAIT 1.
print "Periapsis: " + Ship:Orbit:Periapsis.
WAIT 1.
print "Eccentricity: " + Ship:Orbit:Eccentricity.

print "Lets farm science on orbit".
ScienceExp("Goo1", FALSE).
ScienceExp("Therm1", FALSE).
ScienceExp("Bar1", FALSE).
ScienceExp("SC1", FALSE).
WAIT 30.

Set TTD to 20.
UNTIL TTD=0
{
clearscreen.
print "OK, science collected, get ready to deorbit".
print "Time to deorbit maneuver (sec): " +TTD.
WAIT 1.
Set TTD to TTD-1.
}

//Начинаем спуск с орбиты.
clearscreen.
print "DEORBIT BURN".

LOCK Steering to Retrograde.
WAIT 10.
LOCK Throttle to 1.
WAIT UNTIL STAGE:OXIDIZER<1.
LOCK Throttle to 0.
print "COMPLETE".
WAIT 1.
STAGE.
print "Good luck, Jeb, see ya on Kerbin".
LOCK Steering to -SHIP:VELOCITY:SURFACE. //Ориентация хитшилда против скорости
WAIT UNTIL ALT:RADAR <1000.
UNLOCK Steering.
WAIT UNTIL (STATUS = "LANDED") OR (STATUS = "SPLASHED").
print "Home, sweet home..".

print "Lets farm science on surface".
ScienceExp("Goo2", FALSE).
ScienceExp("Therm2", FALSE).
ScienceExp("Bar2", FALSE).

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
ScienceModule:TRANSMIT.
PRINT "Science data from " + SciBlockName + " transmitted to KSC".
}
ELSE PRINT "Science data stored in " + SciBlockName.
}