//Программа посадки беспилотного корабля на поверхность Кербина. v 1.0.
//http://kerbalspace.ru/user/Iavasdemsul/
//Формулы:
//Конечная высота h = h0 + v0*T + 0.5*a*T^2, равна 100 метров.
//Текущее ускорение a = F (тяги)/ M - g, или a = PWR * p - g.
//
clearscreen.
//
sas on.								//Обязательно нужен SAS.
set navmode to "SURFACE".			//переключение в режим Surface.
set sasmode to "STABILITYASSIST".	//Включение SAS в режиме стабилизации.
set PWR to 0.						//Начальная тяга двигателя.
set g to 9.81.						//Ускорение свободного падения для Кербина.
set lspeed to -1.					//Желаемая конечная вертикальная скорость после маневра торможения - с минусом, если скорость падения.
set T to 0.							//Начальное значение дельты времени для достижения необходимой скорости, при максимальной тяге.(для отладки - должно уменьшаться или быть постоянным).
set limit to 1.						//Начальное значение программного лимита тяги, для компенсации инертности алгоритма сброса скорости.
set TWRlimit to 2.					//Лимит TWR для установки лимита тяги. Экспериментально вычисленное оптимальное значение 2.
set h to 0.8.						//!!!!!!!Высота командного модуля корабля.
//
until ship:status = "LANDED" or ship:status = "SPLASHED" or ship:status = "PRELAUNCH"
	{
		Print "Grav.acc.(g)     " + g + " m/s^2" at (5,2).
		Print "Final speed      " + lspeed + " m/s" at (5,3).
		Print "Thrust Limit     " + round(limit*100) + " %" at (5,12).
		
		Print "Altitude         " + round(alt:radar) + " m" at (5,5).
		Print "Ship Velocity    " + round(ship:velocity:surface:mag) + " m/s" at (5,6).
		Print "Vertical Speed   " + round(ship:verticalspeed) + " m/s" at (5,7).
		
		Print "Thrust Power     " + round(PWR * 100, 2) + " %" at (5,9).
		Print "Engine Thrust    " + round(limit*ship:maxthrust * PWR, 2) + " kN" at (5,10).
		Print "Est.Time to Stop " + round(-1*T, 2) + " s" at (5,11).
		
		
		if ship:maxthrust <= 0 { hudtext("NO MORE FUEL. R.I.P.", 5, 2, 45, red, false). shutdown.}. 				//Проверка наличия топлива.
		if ship:verticalspeed < -1 { set sasmode to "RETROGRADE".}.													//Разворот корабля в ретрогрейд, при падении.
		
		set limit to TWRlimit*ship:mass*g/ship:maxthrust.															//Расчет программного лимита тяги, для компенсации инертности алгоритма сброса скорости. За опору берется TWRlimit=2.
		if limit > 1 {set limit to 1.}.																				//Для слабых двигателей.
		if limit >= 2 {hudtext("NOT ENOUGH THRUST. R.I.P.", 5, 2, 45, red, false). shutdown.}.						//Для очень слабых!
		
		set p to limit*ship:maxthrustat(1)/ship:mass.																//Промежуточная переменная p = max(F тяги)/ M, коэффициент максимальной тяги корабля.
		set deltav to lspeed - ship:verticalspeed.																	//Промежуточная переменная dV, характеризующая необходимый 
																													//прирост скорости в момент времени до окончания маневра.
			if ship:verticalspeed < -1 
			{
				
																													
				set PWR to (p-g)^2*(2*(h-1)-2*alt:radar-2*ship:verticalspeed*deltav/(p-g))/(p*deltav^2) + (g/p). 	//Расчет тяги, при след условиях:
																													//конечная высота h метров;
																													//вертикальная скорость отрицательна;
			}																										//T = dV/(p-g), минимальное время для достижения необходимой высоты h и скорости lspeed, при максимальной тяге.
			else {set PWR to 0.}.
		//
		if PWR < 0 {set PWR to 0.}.
		if PWR > 1 {set PWR to 1.}.
		set T to (deltav)/(PWR * p - g).
		lock throttle to PWR.
		
		WAIT 0.001.
		clearscreen.
	}.
set sasmode to "STABILITYASSIST".																			
hudtext("LANDED SUCCESSFULLY!", 5, 2, 45, green, false).
set ship:control:pilotmainthrottle to 0.
