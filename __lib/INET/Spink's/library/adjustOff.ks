//adjustOff.ks
@lazyglobal off.
require("control.ks").
require("adjustPrd.ks").
require("navigation.ks").

function adjustOffset{
	parameter tObject.
	parameter tOffset.
	parameter tError is 2.
	local rm is 1.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	notify("Adjusting offset to " + tOffset).
	if approx(targetAngle(tObject),tOffset,tError){
		set rm to 0.   
	}
	else{
		set rm to 1.
	}
	local tWait is 0.
  local tSecs is 0.
	local aOrbits is 0.
	local aSecs is 0.
	local tAngle to tOffset - targetAngle(tObject).
	if ship:altitude < 500000 and tAngle < -15{
		set tAngle to tAngle + 360. 
	}
	set tSecs to tAngle * (tObject:orbit:period/360).
	until rm = 0{
		if rm = 1{
			local frac is .1.
			if ship:altitude < 500000 and tSecs < 0{
				set frac to .005.
			}
			set aOrbits to max(1,round(abs(tSecs) / (ship:orbit:period * frac))).
			set aSecs to tSecs / aOrbits.
			if tSecs > 0{
				set hWork to prograde.
				set tWork to 0.
			}
			else{
				set hWork to retrograde.
				set tWork to 0.			
			}
			set rm to 2.
		}
		else if rm = 2{
			adjustPeriod(tObject:orbit:period + aSecs).
			set rm to 3.
			set tWait to time:seconds + (aOrbits * ship:orbit:period) - 180.
			setAlarm(tWait).
		}
		else if rm = 3{
			if time:seconds > tWait{
				set rm to 4.
			}	
		}
		else if rm = 4{
			notify("Circularize").
			adjustPeriod(tObject:orbit:period).
			set rm to 0.
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Adjust offset   " at (1,1).
		print "curr Offset: " + round(targetAngle(tObject),2) + "    " at (1,10).
		print "tgt Offset : " + round(tOffset,2) + "    " at (1,11).
		print "Adj Angle : " + round(tAngle,2) + "    " at (1,12).
		print "adj tSecs : " + round(tSecs,2) + "    " at (1,13).
		print "adj aSecs : " + round(aSecs,2) + "    " at (1,14).
		print "adj orbits : " + round(aOrbits) + "    " at (1,15).
	}
	lock throttle to 0.
	lock steering to hLock.
	clearscreen.
	return true.
}