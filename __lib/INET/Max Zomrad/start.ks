// Sputnik 1 Программа выведения.
// Max Zomrad
// http://youtube.com/maxzomrad

// Функции ==================

// Вычисление азимута прогрейда орбитальной плоскости.
function f_Orbit_PA{

	declare local east to vcrs(ship:up:vector, ship:north:vector).
	declare local trig_x to vdot(ship:north:vector, ship:prograde:vector).
	declare local trig_y to vdot(east, ship:prograde:vector).
	declare local Orbit_PA to arctan2(trig_y, trig_x).
	if Orbit_PA < 0 { set Orbit_PA to Orbit_PA + 360.}
	
	return Orbit_PA.
}.

// 1-я ступень ==============

set kU1st to 34.3. 				    // Конечный угол к горизонту 1-ой ступени [градус].
set uA to -0.7.						// Угол атаки во время прохождения зоны МСН [градус].

set pU1st to (90-kU1st)*0.4+kU1st.  // Промежуточный угол к горизонту 1-ой ступени [градус].

// 2-я ступень ==============

set kU2st to 0. 				    // Конечный угол к горизонту 2-ой ступени [градус].
set flagF to 1.   					// флаг сброса CAC/Обтекателей (если 1 - будет произведён сброс, 0 -нет).
set HsF to 80000.					// Высота сброса CAC/Обтекателей.

// Начальные установки ===========
clearscreen. 
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set targetPitch to 90.	// Начальный угол к горизонту (Зенит).
set targetHead to 90.	// Направление (Восток).
set fFuel to 0. 		// Начальное кол-во топлива (окислителя) для относительного расчёта.


set cyclogram to 1. // Начинаем с циклограммы 1 (старт).

// Запуск циклограмм ========

until cyclogram = 0 { // Общая циклограмма программы.


    if cyclogram = 1 { // Старт
		Lock throttle to 1.0.       
		print "CYCLOGRAM: " + cyclogram + "      " at (5,2).
		print "START" + "      " at (10,4).
		wait 0.5.
        stage.
		wait 2.0.
		stage.
		lock steering to heading (targetHead,targetPitch).
		wait 0.2.
		set fFuel to stage:LqdOxygen.
        set cyclogram to 2.
    }

    else if cyclogram = 2 { // Вертикальный подъём.
			lock steering to heading (targetHead,targetPitch).
			if ship:airspeed > 100 { // подымаемся вертикально пока скорость не превысит 100 м/c.
				set fFuel to stage:LqdOxygen.
				set cyclogram to 3.
            }
    }
		
	else if cyclogram = 3 { // Начало поворота 1-ой ступени.
			set mT to (fFuel-stage:LqdOxygen)/fFuel. // относительный расход топлива.			
			set targetPitch to (90-pU1st)*(1-mT)^2+pU1st. 
			set targetHead to 90.
            lock steering to heading (targetHead,targetPitch).
		    if  ship:airspeed > 300 { // входим в зону МСН.
				set fFuel to stage:LqdOxygen.
				set pU1st to targetPitch.				
				set cyclogram to 4.
			}
	}
		
	else if cyclogram = 4 { // Проходим зону максимального скоростного напора.
			set targetPitch to 90 - vang(ship:up:vector, ship:srfprograde:vector)+uA.
			set targetHead to 90.
			lock steering to heading (targetHead,targetPitch).
			if ship:airspeed > 600 {
				set fFuel to stage:LqdOxygen.
				set pU1st to targetPitch.	
				set cyclogram to 5.
            }
    }
				
	else if cyclogram = 5 { // Продолжаем поворот первой ступени.
			set mT to (fFuel-stage:LqdOxygen)/fFuel. // относительный расход топлива.			
			set targetPitch to 1.02*(pU1st-kU1st)*(0.99-mT)^2+kU1st.	
			set targetHead to f_Orbit_PA().			
            lock steering to heading (targetHead,targetPitch).
		    if mT > 0.93 { 
				set cyclogram to 6.
			}
	}
	
	else if cyclogram = 6 { // Уменьшаем угол атаки перед разделением.
	
			set mT to (fFuel-stage:LqdOxygen)/fFuel.				
			set targetPitch to 90 - vang(ship:up:vector, ship:srfprograde:vector)-0.5.
			set targetHead to f_Orbit_PA().
            lock steering to heading (targetHead,targetPitch).
		    if mT > 0.99{ 
				set cyclogram to 7.
			}
	}
	
	else if cyclogram = 7 { // Дожиг топлива и разделение
		    if stage:LqdOxygen < 1 {
				rcs on.
				set ship:control:fore to 1.0.
				wait 0.5.				
				stage.
				wait 1.2.
				stage.	
				set ship:control:fore to 0.0.
				wait 0.3.
				RCS off.
				set kU1st to 90 - vang(ship:up:vector, ship:srfprograde:vector)-0.5.
				set fFuel to stage:IWFNA.
				set cyclogram to 8.
			}
	}
 
    else if cyclogram = 8 { // Поворот 2-ой ступени.
			set mT to (fFuel-stage:IWFNA)/fFuel. // относительный расход топлива.
			set targetPitch to 1.02*(kU1st-kU2st)*(0.99-mT)^2+kU2st.
			set targetHead to f_Orbit_PA().
            lock steering to heading ( targetHead, targetPitch).
		    if mT > 0.989 {
				set cyclogram to 9.
			}
	}
	
	else if cyclogram = 9 { // Конец работы двигателя 2-ой ступени.
		    if stage:IWFNA < 1 {
				wait 0.5.
				RCS on.				
				Lock throttle to 0.0.
				set eng to ship:partsnamed("SXTAJ10")[0].	// Лочу джимбал двигателю,
				set eg to eng:GETMODULE("ModuleGimbal").	// чтобы не дёргался
				set eg:lock to true.						// (раздражает).
				wait 3.				
				set cyclogram to 10.
			}
	}
			
	else if cyclogram = 10 { // Варп времени до апоцентра.
		    if ETA:APOAPSIS > 70 {
				if WARP = 0 {   
					wait 1.         
					SET WARP TO 2.  
				}
			}	
		else 	if ETA:APOAPSIS < 70 {
					SET WARP to 0.	
					set targetPitch to 0.
					set targetHead to f_Orbit_PA().				
					lock steering to heading ( targetHead, targetPitch).
					set cyclogram to 11.					
				}
	}	
		
	else if cyclogram = 11 { // Подготовка и старт 3-ей ступени.
			set targetHead to f_Orbit_PA().				
			lock steering to heading ( targetHead, targetPitch).
		    if ETA:APOAPSIS <= 7 {
				clearscreen.
				print "CYCLOGRAM: " + cyclogram + "      " at (5,2).
				print "BS Start : 5" + "      " at (5,4).
				wait 1.
				print "BS Start : 4" + "      " at (5,4).
				wait 1.
				print "BS Start : 3" + "      " at (5,4).
				wait 1.
				print "BS Start : 2" + "      " at (5,4).
				wait 1.
				stage.
				print "BS Start : 1" + "      " at (5,4).
				wait 1.
				RCS off.
				print "BS Start : START" + "      " at (5,4).
				stage.
				set cyclogram to 0.
			}
	}
		
	if flagF = 1 and SHIP:ALTITUDE>HsF { //Сброс обтекателей и активация антенны.
			stage.
			wait 0.2.
			toggle AG8. // Активация группы [8] (обычно вешаю туда антенну).
			set flagF to 0.
	}

// Цикличная печать инфо ===============
	
    print "CYCLOGRAM: " + cyclogram + "      " at (5,2).
	
    print "ALTITUDE:  " + round(SHIP:ALTITUDE) + "      " at (5,4).
    print "APOAPSIS:  " + round(SHIP:APOAPSIS) + "      " at (5,5).
    print "PERIAPSIS: " + round(SHIP:PERIAPSIS) + "      " at (5,6).
    print "ETA to AP: " + round(ETA:APOAPSIS) + "      " at (5,7).
	
	print "PITCH:     " + round(targetPitch,1) + "      " at (5,9). 
	print "AZYMUTH:   " + round(targetHead,1) + "      " at (5,10).
	
}

// Финализация ===============

if cyclogram = 0 {
	wait 1.
	clearscreen.
	SAS off.
	RCS off.
	unlock steering.
	unlock throttle.
	set ship:control:pilotmainthrottle to 0.
	wait 1.
}