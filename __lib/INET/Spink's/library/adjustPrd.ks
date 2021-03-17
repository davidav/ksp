//adjustPrd.ks
@lazyglobal off.
require("control.ks").

function adjustPeriod{
	parameter tPrd.
	parameter tError is 0.25.
	local rm is 1.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	notify("Adjusting period to " + tPrd).
	if approx(tPrd,ship:orbit:period,tError){
		set rm to 0.   
	}
	else{
		set rm to 1.
	}
	until rm = 0{
		if rm = 1{
			if ship:orbit:period < tPrd{
				set hWork to prograde.
				if align(prograde) < 15{
					set rm to 2.
				}
			}
			else if ship:orbit:period > tPrd{
				set hWork to retrograde.
				if align(retrograde) < 15{
					set rm to 3.
				}
			}
		}
		else if rm = 2{
			if ship:orbit:period > tPrd{
				set tWork to 0.
				set rm to 0.
			}
			set tWork to setThrottle(ship:orbit:period,tPrd,.1).
		}
		else if rm = 3{
			if ship:orbit:period < tPrd{
				set tWork to 0.
				set rm to 0.
			}
			set tWork to setThrottle(ship:orbit:period,tPrd,.1).
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Adjust period    " at (1,1).
		print "curr prd: " + round(ship:orbit:period,2) + "    " at (1,8).
		print "tgt prd: " + round(tPrd,2) + "    " at (1,9).

	}
	lock throttle to 0.
	lock steering to hLock.
	clearscreen.
	return true.
}