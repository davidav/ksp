//descent.ks
@lazyglobal off.
require("control.ks").

function MunDescent{
	parameter tLat is 0.
	parameter tLng is 0.
	parameter lStg is 0.
	parameter lLead is 5.

	local tLand is LATLNG(tLat,tLng).
	local tStart is LATLNG(tLat * -1,mod(tLng - 180,180)).
	if tlng < 0{
		set tStart to LATLNG(tLat * -1,mod(tLng + 180,180)).
	}

	local tPeri is 10000.
	local lDescend is tStart:LNG - lLead.

	local rm is 1.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork.
	lock throttle to tLock.
	lock steering to hLock.

	local kP1 is 0.05.	// 0.05
	local kI1 is 0.5.	// 0.5
	local kD1 is 0.001.	// 0.01
	local aPID is pidloop(kP1,kI1,kD1,0,1).
	set aPID:setpoint to 0.
	gear off.
	gear on.
	gear off.


	if ship:periapsis < tPeri{
		set tWork to 0.
		set rm to 4.
	}
	until rm = 0{
		if rm = 1{
			set tWork to 0.
			set hWork to retrograde.
			// if approx(ship:geoposition:LAT,tStart:LAT,1) and
			if approx(ship:geoposition:LNG,tStart:LNG,.1){
				set rm to 2.
			}
		}
		if rm = 2{
			notify("INITIATING DE-ORBIT BURN").
			set hWork to retrograde.
			if align(retrograde) < 25{
				set rm to 3.
			}
		}
		else if rm = 3{
			set hWork to ship:retrograde.
			if ship:periapsis < tPeri{
				set tWork to 0.
				setAlarm(time:seconds + eta:periapsis - 360).
				set rm to 4.
			}
			else{
				set tWork to 0.25.
			}
		}
		else if rm = 4{
			if approx(ship:geoposition:LNG,lDescend,.1){
				set rm to 5.
			}
			set hWork to ship:retrograde.
			set tWork to 0.
		}
		else if rm = 5{
			if groundspeed < 2{
				if stage:number > lStg{
					stage.
				}
				set rm to 6.
			}
			set hWork to ship:retrograde.
			set tWork to 1.0.
		}
		else if rm = 6{
			if alt:radar < 5 and approx(verticalspeed,0,1){
				set tWork to 0.
				set rm to 0.
			}
			else if alt:radar > 5000{
				set aPID:setpoint to -100.
				lights on.
			}
			else if alt:radar > 500{
				set aPID:setpoint to -50.
				lights on.
			}
			else if alt:radar > 100{
				set aPID:setpoint to -10.
			}
			else if alt:radar > 50{
				set aPID:setpoint to -5.
			}
			else{
				set aPID:setpoint to -2.
				gear on.
			}
			lock steering to descent_vector().
			set tWork to aPID:update(time:seconds,verticalspeed).
		}

		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Descent   " at (1,1).
		print "CURR: " + round(ship:geoposition:LAT,2) + "  " at (1,10).
		print round(ship:geoposition:LNG,2) + "  " at (16,10).
		print "STRT: " + round(tStart:LAT,2) + "  " at (1,11).
		print round(tStart:LNG,2) + "  " at (16,11).
		print "TGT : " + round(tLand:LAT,2) + "  " at (1,12).
		print round(tLand:LNG,2) + "  " at (16,12).
		print round(tLand:Heading,2) + "  " at (1,13).
		print round(tLand:Distance,2) + "  " at (16,13).

	}
	notify("LANDED").
	clearscreen.
	shutdown.
}

function g{
	return body:mu / ((ship:altitude + body:radius)^2).
}
function descent_vector{
	if vang(srfretrograde:vector,up:vector) > 90 return unrotate(up).
	return unrotate(up:vector * g() - velocity:surface).
}
function unrotate{
	parameter v.
	if v:typename <> "Vector" set v to v:vector.
	return lookdirup(v,ship:facing:topvector).
}
