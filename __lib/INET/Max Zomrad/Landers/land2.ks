// константы ================

set g0 to (constant():G * Earth:mass) / (Earth:radius^2).
set e to constant():e.
set pi to constant():pi.

// Функции ==================

function f_TfV {

	declare local parameter V.
	declare local parameter J.
	declare local parameter R.

	return J*ship:mass*1000*(1-e^(-V/J))/R.
}.

// текущий азимут. 
function f_Srf_RA{

	declare local east to vcrs(ship:up:vector, ship:north:vector).
	declare local trig_x to vdot(ship:north:vector, ship:srfprograde:vector).
	declare local trig_y to vdot(east, ship:srfprograde:vector).
	declare local Srf_RA to arctan2(trig_y, trig_x)+180.
	if Srf_RA > 360 { set Srf_RA to Srf_RA - 360.}
	
	return Srf_RA.
}.

function f_Roll {

	declare local parameter Dir.
		
	lock steering to Dir.
	
	until abs(Dir:pitch - facing:pitch) < 1 and abs(Dir:yaw - facing:yaw) < 1 { wait 1.	}
	
}.

function f_TtI {
	
	set a to (2*body:radius+orbit:apoapsis+orbit:periapsis)/2.
	set ec to orbit:eccentricity.
	
	set r0 to body:radius+ship:altitude.	
	set rL to r0 - alt:radar.
	
	set cosE0 to -(r0/a - 1)/ec.
	set E0 to arccos(cosE0).
	
	set cosEL to -(rL/a - 1)/ec.
	set EL to arccos(cosEL).
	
	set E0r to E0*pi/180.
	set ELr to EL*pi/180.
	
	set t0 to (a^1.5/sqrt(body:mu))*(E0r-ec*sin(E0)).
	set tL to (a^1.5/sqrt(body:mu))*(ELr-ec*sin(EL)).
		
	set tI to t0-tL.
	
}.

function f_Hb_calc{

		set Ht to alt:radar.		
		set Vv to ship:verticalspeed.
		set Vh to ship:groundspeed.	
		set Gt to (constant():G * body:mass) / ((body:radius+ship:altitude)^2).
		set Gk to (constant():G * body:mass) / ((body:radius+ship:altitude-alt:radar)^2).
		
		set Gcp to (Gt+Gk)/2.		
		set V to sqrt((Gcp*T+abs(Vv))^2+Vh^2).
		set T to f_TfV(V,J,R*0.9). // при расчёте максимальную тягу указываем в 90%.
		set Acpd to V/T.				
		set fi0 to vang(ship:up:vector, ship:srfprograde:vector)-90.
		set fi to fi0+((90-fi0)^(1/e)+sqrt(90-fi0))/2.		
		set Acp to Acpd*sin(fi) - Gcp.	
		
		return Vv^2/(2*Acp).
}

// инфо об аппарате ============== тут у меня аппарат массой около 13 тонн.

set isp to 311.				// удельная тяга [c].
set R to 92400.				// Тяга двигателя [H].

set J to isp*g0.			// удельный импульс [м/с].

set cH to 5.35.				// Высота аппарата [м].

// Начальные установки ===========

clearscreen.
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set tI to 0.
set T to 0.
set flagS to 0.
set cyclogram to 1.

set Hz to 200.				// Высота зависания [м]. Первая точка где аппарат должен почти остановиться.
set tH to 5.				// Высота конечная [м]. С этой высоты плавно пойдём на посадку.

rcs on.
f_Roll(retrograde).
lock steering to retrograde.
wait 2.

lock throttle to 0.0.
set Vstart to orbit:velocity:orbit:mag.
set cyclogram to 1.

// в РО нельзя запустить этот двигатель без предварительного создания микротяжести. Собственно сначала дуем РЦС, потом запускаем двигатель.
set ship:control:fore to 1.0.
wait 2.
set ship:control:fore to 0.
lock throttle to 1.0.



// Запуск циклограмм =============

until cyclogram = 0 {


	
	if cyclogram = 1 {

		set Hb to f_Hb_calc().		
		
		if V < Vstart*2/3 {
			lock throttle to 0.0.
			lock steering to srfretrograde.
			set cyclogram to 2.
		}
		
	}	
		
	else if cyclogram = 2 {
		
		set Hb to f_Hb_calc().
		
		if flagS = 0 {
			f_TtI.
			if T > tI {set flagS to 1.}
		}
		
		// тут тоже ухищрение для предварительной тяги в 2.5 сек РЦС перед запуском двигателя.
		if (Ht-Hz) < Hb - Vv*2.5 and flagS = 1 {set ship:control:fore to 0.5.} //else {set ship:control:fore to 0.0.} 
		
		if (Ht-Hz) < Hb and flagS = 1 {
			Lock throttle to 1.0.
			set cyclogram to 3.			
		}	
		
	}
		
	else if cyclogram = 3 {	
	
		set Hb to f_Hb_calc().
		
		// работа дросселем двигателя
		if Ht < Hb + Hz + V/20 {
			if Ht < Hb+Hz-V/20 {lock throttle to 1.0.}
			else if Ht > Hb+Hz-V/20 { lock throttle to 0.8+(Hb+Hz-Ht+V/20)/(V/2).}
		} 
		else { lock throttle to 0.8.}
		
		// работа трастерами РЦС
		if Ht < Hb + Hz {
			if Ht < Hb+Hz-V/10 {set ship:control:fore to 1.0.}
			else if Ht > Hb+Hz-V/10 { set ship:control:fore to (Hb+Hz-Ht)/(V/10).}			
		} 
		else { set ship:control:fore to 0.}
		
		// тут по идее мы должны быть на первой точке "зависания", но скорость предусмотренна в 5 м/с 
		if Vv > -5 {		
			set ship:control:fore to 0.
			Lock throttle to 0.01. // хитрожопо не отключаю двигатель полностью, чтобы потом не мучатся с предварительной продувкой РЦС
			toggle Gear.
			set LHead to f_Srf_RA. // запоминаем азимут
			set cyclogram to 4.
		}
		
		if Hb*1.5 < Ht-Hz {
			Lock throttle to 0.01. // хитрожопо не отключаю двигатель полностью, чтобы уменьшить кол-во зажиганий, в РО у двигателя может быть ограничено кол-во запусков.
			set ship:control:fore to 0.
			set cyclogram to 2.
		}
			
	}

	// падаем от первой точки
	else if cyclogram = 4 {
		
		set Hb to f_Hb_calc().
		
		if (Ht-cH-tH) < Hb {
			lock throttle to 1.0.
			set cyclogram to 5.			
		}	
		
	}
		
	else if cyclogram = 5 {	
	
		set Hb to f_Hb_calc().
		
		if (Ht-tH-cH) < Hb {
			set ship:control:fore to 0.5.
			lock throttle to 1.0.
		} 
		else {
			lock throttle to 0.8.
			set ship:control:fore to 0.
		}
		
		if Vv > -2 or (Ht-1) < cH {		
			Lock steering to Heading (LHead,90). // держим старый азимут, чтоб аппарат не крутило вдоль вертикальной оси в ноль.
			set ship:control:fore to 0.
			set cyclogram to 6.
		}
		
		if Hb*1.5 < (Ht-tH) and (Ht-tH) > cH {
			set ship:control:fore to 0.
			Lock throttle to 0.01.
			set cyclogram to 4.	
		}
			
	}
	
	// пытаемся плавно сесть
	else if cyclogram = 6 {	
		
		set Ht to alt:radar.
		set Vv to ship:verticalspeed.
		set Gt to (constant():G * body:mass) / ((body:radius+ship:altitude)^2).
		set Ad to R/(ship:mass*1000).
		set Thr to Gt/Ad.
		
		if vV < -2 {Lock throttle to Thr+0.1.} 
		else if vV < -0.5 { Lock throttle to Thr.}
			 else { Lock throttle to 0.02.}
		
		if hT < (cH+0.2) {
			Lock throttle to 0.02.
			rcs off.
			wait 1.
			Lock throttle to 0.
			set cyclogram to 0.
		}
		
	}

    print "CYCLOGRAM: " + cyclogram + "     " at (5,2).
	
	print "Ht:      " + round(Ht, 0)  + "     " at (5,4).
	print "Hb:      " + round(Hb, 0)  + "     " at (5,5).
	print "T:       " + round(T, 1)   + "     " at (5,6).
	print "Acp:     " + round(Acp, 2) + "     " at (5,7).
	print "fi:      " + round(Fi,2)   + "     " at (5,8).
	print "Gcp:     " + round(Gcp,2)  + "     " at (5,9).
	print "V:       " + round(V, 1)   + "     " at (5,10).
	print "Acpd:    " + round(Acpd, 2)+ "     " at (5,11).
	print "tI  :    " + round(tI, 1)  + "     " at (5,13).
	
}

// Финал ======================

if cyclogram = 0 {
	clearscreen.
	set ship:control:pilotmainthrottle to 0.
	unlock throttle.
	wait 1.
}