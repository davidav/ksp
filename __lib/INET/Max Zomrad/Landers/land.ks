// Программа посадки на Луну №1.
// Max Zomrad
// http://youtube.com/maxzomrad

// константы ================ тут думаю всё ясно

set g0 to (constant():G * Earth:mass) / (Earth:radius^2).
set e to constant():e.
set pi to constant():pi.

// Функции ==================

// время из дельты
function f_TfV {

	declare local parameter V.
	declare local parameter J.
	declare local parameter R.

	return J*ship:mass*1000*(1-e^(-V/J))/R.
}.

// ждёт пока аппарат довернёт в указанную параметром точку
function f_Roll {

	declare local parameter Dir.
		
	lock steering to Dir.
	
	until abs(Dir:pitch - facing:pitch) < 1 and abs(Dir:yaw - facing:yaw) < 1 { wait 1.	}
	
}.

// время до столкновения с поверхностью. служит "спусковым крючком" для возможности включения двигателя. Кеплер рулит ))
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

// очередная "моя прелесть" на уровне средней школы )), собственно функция вычисления высоты, на которой нужно запускать двигло. по сути суицид бёрн, но с подвыподвертом.
function f_Hb_calc{

		set Ht to alt:radar.	// тут внимательно. для луны в РСС не работает корректно выше 50 км.
								// Да и вообще сажать желательно над поверхностями без сильных перепадов, иначе будет плохо.
								// Если брать высоту над поверхностью именно в точке столкновения (через мод траектории я думаю это реально), то будет усё работать, как часы.		
		set Vv to ship:verticalspeed.
		set Vh to ship:groundspeed.	
		set Gt to (constant():G * body:mass) / ((body:radius+ship:altitude)^2).
		set Gk to (constant():G * body:mass) / ((body:radius+ship:altitude-alt:radar)^2).
		
		set Gcp to (Gt+Gk)/2.				
		set V to sqrt((Gcp*T+abs(Vv))^2+Vh^2). // Можно конечно не опускаться до уровня ср. школы и посчитать из функции выше. Но так было изначально и так прикольней ))
		set T to f_TfV(V,J,R).
		set Acpd to V/T.				
		set fi0 to vang(ship:up:vector, ship:srfprograde:vector)-90.
		
		// средний угол к поверхности за время торможения. лажа в том, что считается от текущей высоты. из-за этого и нужен спусковой крючок.
		// т.к. при малых значениях ср. угла, высота зажигания уходит в минус бесконечность, потом через бесконечность к правильному значению.	
		// формула получена методом моделирования
		set fi to fi0+((90-fi0)^(1/e)+sqrt(90-fi0))/2.
				
		set Acp to Acpd*sin(fi) - Gcp.
		
		return Vv^2/(2*Acp).
}

// инфо об аппарате ============== тут у меня небольшой посадочный аппарат массой 300кг

set isp to 281.7.			// удельная тяга [c].
set R to 1820.				// Тяга двигателя [H].

set J to isp*g0.			// удельный импульс [м/с].

set cH to 0.5.				// Высота аппарата [м]. ! берётся вручную с помощью кОС на грунте, ну и + ещё немного для перестраховки !
set tH to 1.5.				// Высота конечная [м]. Нагло тормозим в ноль на 1.5м от поверхности )

// Начальные установки ===========

clearscreen.
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set tI to 0.
set T to 0.
set flagS to 0.

set cyclogram to 1.

// Погнали =======================

//разворачиваем в ретрогрейд
f_Roll(retrograde).
lock steering to retrograde.
wait 3.

lock throttle to 0.0.
set Vstart to orbit:velocity:orbit:mag. // запоминаем текущую скорость.
lock throttle to 1.0.

// Запуск циклограмм =============

until cyclogram = 0 {

	if cyclogram = 1 {

		set Hb to f_Hb_calc().	// чисто для отладки через принт. тут не нужна на самом деле.
		
		// сходим с орбиты. убираем треть орбитальной скорости (можно четверть).
		if V < Vstart*2/3 {
			lock throttle to 0.0.
			lock steering to srfretrograde.
			set cyclogram to 2.
		}
		
		
	}	
		
	else if cyclogram = 2 {
		
		set Hb to f_Hb_calc().
		
		// проверяем спусковой крючек. если время для торможения в ноль равно времени до столкновения - даём разрешение на запуск двигателя.
		if flagS = 0 {
			f_TtI.
			if T > tI {set flagS to 1.}
		}		
		
		// если высота равна высоте суицид бёрна и есть разрешение на пуск двигателя - запускаем
		if Ht < Hb and flagS = 1 {
			Lock throttle to 1.0.
			rcs on.
			set cyclogram to 3.			
		}	
		
	}
		
	else if cyclogram = 3 {	
	
		set Hb to f_Hb_calc().
		
		
		// регулируем торможение через РЦС. Если спускаемся быстро - добавляем РЦС трастерами. Если медленно - РЦС выкл.
		// Если разница текущей высоты и высоты суицид бёрна в пределах +- 5% от скорости(!)(это для плавного уменьшения погрешности) - регулируем тягу РЦС пропорционально. 
		if Ht < Hb + V/20 + cH + tH {
			if Ht < Hb - V/20 + cH + tH {set ship:control:fore to 1.0.}
			else if Ht > Hb - V/20 + cH + tH {set ship:control:fore to (Hb-Ht+V/20)/(V/10).}
		} 
		else { set ship:control:fore to 0.0.}
		
		// если вертикальная близка к нулю или текущая высота меньше нулевой высоты + 0.1м ) - к завершающей циклограмме
		if Vv > -0.5 or Ht < cH + 0.1 {	
			set ship:control:fore to 0.0.
			Lock steering to Up.
			Lock throttle to 0.0.
			set cyclogram to 4.
		}
		
		// если переусердствовали с торможением или изменилась высота ландшафта и текущая в полтора раза уже превышает высоту суицид бёрна, то выкл. двигатель и опять ждём когда можно.
		if Hb*1.5 < Ht and Ht > 10 + cH {
			rcs off.
			Lock throttle to 0.0.
			set cyclogram to 2.
		}
			
	}

	// тут просто пытаемся мягко опуститься. 
	else if cyclogram = 4 {	
		
		set Ht to alt:radar.
		set Vv to ship:verticalspeed.
				
		if Vv < -1 {set ship:control:fore to 1.0.}
		else {
			if Vv < -0.5 {set ship:control:fore to ((0.5-Vv)/0.5).}
			else {set ship:control:fore to 0.}
		}
		
		if Ht < (cH+0.1) {
			set ship:control:fore to 0.
			wait 3.		
			rcs off.
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