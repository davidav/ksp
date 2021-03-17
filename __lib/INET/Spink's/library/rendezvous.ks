@lazyglobal off.
require("control.ks").

function rendezvous{
	parameter tObject.
	parameter tSpeed.
	parameter minDist.
	local tWork is 0.
	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork.
	lock throttle to tLock.
	lock steering to hLock.
	local lastDist is tObject:distance.
	lock relVel to tObject:velocity:orbit - ship:velocity:orbit.
	lock maxAccel to ship:maxthrust / ship:mass.
	
	local rm is 1.
	sas off.
	// set target to tObject.
	until rm = 0{
		if rm = 1{	// cancel relvel
			set hWork to relVel.
			if vang(ship:facing:forevector,hWork) > 2{
				set tWork to .01.
				rcs on.
			}
			else{
				// set tWork to min(.1,abs(30 - relVel:mag) / maxAccel).
				set tWork to .1.
				rcs off.
			}
			if relVel:mag < 1{
				set tWork to 0.
				if tObject:distance < minDist{
					set rm to 0.
				}
				else{
					set rm to 2.
				}
			}
		}
		if rm = 2{	// approach
			if tObject:distance < minDist{
				set rm to 1.
			}
			else if relVel:mag > 10{ //tSpeed
				set tWork to 0.
				set rm to 3.
			}
			set hWork to tObject:position.
			if vang(ship:facing:forevector,hWork) > 2{
				set tWork to .01.
				rcs on.
			}
			else{
				set tWork to min(.25,abs(20 - relVel:mag) / maxAccel).
				// set tWork to min(.25,setThrottle(relVel:mag,10)). //tSpeed
				rcs off.
			}
		}
		if rm = 3{	// await nearest
			if tObject:distance < minDist or tObject:distance > lastDist{
				set rm to 1.
			}
			set lastDist to tObject:distance.
			set hWork to relVel.
			set tWork to 0.
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Range  : " + round(tObject:distance) + " " at (1,8).
		print "Bearing : " + round(tObject:bearing) + " " at (1,9).
		print "RelVel  : " + round(relVel:mag,2) + " " at (1,10).
		print "Rendezvous   " at (1,1).
	}
}