// Программа выведения для тандемных ДВУХСТУПЕНЧАТЫХ носителей.
// Max Zomrad
// http://youtube.com/maxzomrad

// Функции ==================

// Вычисление азимута прогрейда в орбитальной плоскости.
function f_Orbit_PA{

	declare local east to vcrs(ship:up:vector, ship:north:vector).
	declare local trig_x to vdot(ship:north:vector, ship:prograde:vector).
	declare local trig_y to vdot(east, ship:prograde:vector).
	declare local Orbit_PA to arctan2(trig_y, trig_x).
	if Orbit_PA < 0 { set Orbit_PA to Orbit_PA + 360.}
	
	return Orbit_PA.
}.

// Вычисление времени из дэльты.
function f_TfV {

	declare local parameter V.
	declare local parameter J.
	declare local parameter R.

	return J*ship:mass*1000*(1-constant():e^(-V/J))/R.
}.

// Вычисление дэльты из времени.
function f_VfT {
	declare local parameter T.
	declare local parameter J.
	declare local parameter R.

	return -J*ln(1-(R*T)/(ship:mass*1000*J)).
}.

// Вычисление конечной массы из дэльты.
function f_mfV {
	declare local parameter V.
	declare local parameter J.

	return ship:mass*1000/constant():e^(V/J).
}.

// Вычисление орбитальной скорости.
function f_V0 {
	
	return orbit:velocity:orbit:mag.
}.	

// Вычисление 1-й космической скорости на текущей высоте.
function f_Vorb {
	
	return sqrt((constant():G * body:mass) / (body:radius+ship:altitude)).
}.	

// Вычисление угла к горизонту.
function f_Fi{
	
	set g to (constant():G * body:mass) / ((body:radius+ship:altitude)^2).
	set dV2 to f_Vorb - f_V0 + g*t2*sinFi*0.9.			
	set t2 to f_TfV(dV2,J2,R2).			
	set dVg to f_Vorb - f_V0*cos(sin(ship:verticalspeed/f_V0)).			
	set sinFi to (g*(dVg/f_Vorb)*t2-ship:verticalspeed)/dV2.			
	if sinFi > 1 {set sinFi to 1.}
	if sinFi < -1 {set sinFi to -1.}
	
	return arcsin(sinFi).	
}.			

// Начальные установки ======

clearscreen. 
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.
set cyclogram to 1. 	// Начинаем с циклограммы 1 (старт).
set fFuel to 0. 		// Начальное кол-во топлива (окислителя) для относительного расчёта.

set J2 to isp2*9.807.	// удельный импульс двигателя 2-й ступени [м/с].

set pU1st to (90-kU1st)*0.4+kU1st.  // Промежуточный угол к горизонту для 1-й ступени [градус].

set targetPitch to 90.	// Начальный угол к горизонту (Зенит).
set targetHead to 90.	// Направление (Восток).

set Fi to 0.
set dV2 to 0.
set mX to 0.
set t2 to 0.
set sinFi to 0.

// Запуск циклограмм ========

until cyclogram = 0 { // Общая циклограмма программы.


    if cyclogram = 1 { // Старт
		Lock throttle to 1.0.
		print "CYCLOGRAM: " + cyclogram + "      " at (5,2).		
		wait 1.
		print "zajiganiye" + "      " at (10,4).
		stage.
		wait 1.
        stage.
		wait 2.
		lock steering to heading (targetHead,targetPitch).
		stage.
		print "START" + "        " at (10,4).
		wait 1.
        set cyclogram to 2.
    }

    else if cyclogram = 2 { // Вертикальный подъём.
			lock steering to heading (targetHead,targetPitch).
			if ship:airspeed > 100 { // подымаемся вертикально пока скорость меньше 100 м/c.
				set fFuel to FuelS1.
				set cyclogram to 3.
            }
    }
		
	else if cyclogram = 3 { // Начало поворота 1-ой ступени.
			set mT to (fFuel-FuelS1)/fFuel. // относительный расход топлива.			
			set targetPitch to (90-pU1st)*(1-mT)^2+pU1st. 
            lock steering to heading (targetHead,targetPitch).
		    if  ship:airspeed > 300 { // входим в зону МСН.
				set fFuel to FuelS1.
				set pU1st to targetPitch.				
				set cyclogram to 4.
			}
	}
		
	else if cyclogram = 4 { // Проходим зону максимального скоростного напора.
			set targetPitch to 90 - vang(ship:up:vector, ship:srfprograde:vector)+uA.
			set targetHead to 90.
			lock steering to heading (targetHead,targetPitch).
			if ship:airspeed > 600 {
				set fFuel to FuelS1.
				set pU1st to targetPitch.	
				set cyclogram to 5.
            }
    }
				
	else if cyclogram = 5 { // Продолжаем поворот первой ступени.	
			set mT to (fFuel-FuelS1)/fFuel.				
			set targetPitch to (pU1st-kU1st)*(1-mT)^2+kU1st.			
			set targetHead to f_Orbit_PA.
            lock steering to heading (targetHead,targetPitch).
		    if mT > 0.94{ 
				set cyclogram to 6.
			}
	}
		
	else if cyclogram = 6 { // Уменьшаем или нет, в зависимости от флага, угол атаки перед разделением.	Разделяем.
			set mT to (fFuel-FuelS1)/fFuel.				
			if flagS = 1 { set targetPitch to 90 - vang(ship:up:vector, ship:srfprograde:vector)-0.2.}
			else { set targetPitch to (pU1st-kU1st)*(1-mT)^2+kU1st.}
			set targetHead to f_Orbit_PA.
            lock steering to heading (targetHead,targetPitch).
		    if FuelS1 < 1{ 
				if flagRCS = 1 {rcs on.}
				wait 0.5.
				stage.							
				wait 1.
				set kU1st to targetPitch.	
				stage.					
				wait 1.5.
				rcs off.
				if flagDE = 1 {stage.}
				set fFuel to FuelS2.
				f_Fi.	
				lock mX to f_mfV(dV2,J2).
				set cyclogram to 7.
			}
	}
 
    else if cyclogram = 7 { // 1я фаза работы 2-ой ступени.	
			set mT to (fFuel-FuelS2)/fFuel.
			set Fi to f_Fi.
			set targetPitch to (1/(kd^2))*(kU1st-Fi)*(kd-mT)^2+Fi.
			set targetHead to f_Orbit_PA.
            lock steering to heading ( targetHead, targetPitch).			
		    if mT > kd {	
				set cyclogram to 8.
			}
	}
				
	else if cyclogram = 8 { // 2я фаза работы 2-oй ступени.		
			set Fi to f_Fi.
			set targetPitch to Fi.					
			set targetHead to f_Orbit_PA.			
			lock steering to heading ( targetHead, targetPitch).			
			if t2 <= 1 or FuelS2 <= 1 {
				set eccOld to Orbit:ECCENTRICITY + 0.001.	
				set cyclogram to 9.
			}
	}
		
	else if cyclogram = 9 { // Окончание работы 2-oй ступени.						
			set dV2 to f_Vorb - f_V0.	// для инфо					
			set targetHead to f_Orbit_PA.		
			lock steering to heading ( targetHead, targetPitch).			
			if Orbit:ECCENTRICITY > (eccOld-0.00001) or FuelS2 = 0 {
				Lock throttle to 0.0.
				set cyclogram to 0.
			}			
			set eccOld to Orbit:ECCENTRICITY.	
	}
		
	if flagF = 1 and SHIP:ALTITUDE > HsF { //Сброс Обтекателей.
			stage.
			set flagF to 0.
	}

// Цикличная печать инфо ===============
	
    print "CYCLOGRAM: " + cyclogram + "      " at (5,2).
	
	print "deltaV:    " + round(dV2) + "     " at (5,4).
	print "T:         " + round(t2) + "     " at (5,5).
	print "mX:        " + round(mX) + "     " at (5,6).
	print "Fi:        " + round(Fi,2) + "     " at (5,7).
	
	print "Pitch:     " + round(targetPitch,2) + "      " at (5,9). 
	print "Azymuth:   " + round(targetHead,2) + "      " at (5,10).
	
}
	
// Финализация ===============

if cyclogram = 0 { 
	SAS off.
	RCS off.
	unlock steering.
	unlock throttle.
	set ship:control:pilotmainthrottle to 0.
	wait 1.
}