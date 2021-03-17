//ascent.ks
@lazyglobal off.
require("control.ks").
require("systems.ks").

function MunAscent{
	parameter tHeading.
	parameter tApo is 10000.
	parameter iPitch is 80.
	parameter ApoETA is 60.
	parameter sBurn is 5.
	local rm is 1.
	local mPitch is 0.
	local mPitchAlt is 20000. 
	local pidAlt is 10000. 
	local kP1 is 0.05.	// 0.05
	local kI1 is 0.6.	// 0.5
	local kD1 is 0.001.	// 0.01
	local aPID is pidloop(kP1,kI1,kD1,0,1).
	set aPID:setpoint to 50.
	local tPitch is 0.
	local tLaunch is 0.
	local tPrd is getPeriod(tApo).
	local fIg is true. 

	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
		
	rcs off.
	sas off.

	clearscreen.
	local tCD is 10.
	eTime().eTime().
	set rm to 1.

	until rm = 0{
		if rm = 1{ 
			if tCD > 0{
				notify("COUNTDOWN INITIATED: T - " + round(tCD)).
				set tCD to tCD - tElapsed.
			}
			else{
				stage.
				set hWork to up.
				set tWork to aPID:update(time:seconds,verticalspeed).
				set stageMax to ship:maxthrust.
				set rm to 2.
				notify("LAUNCH").
			}
		}
		else if rm = 2{
			if ship:altitude > 1000{
				set kP1 to 0.156.
				set kI1 to 0.101.	
				set kD1 to 0.060.	
				set aPID to pidloop(kP1,kI1,kD1,0,1).
				set aPID:setpoint to ApoETA.
				set rm to 3.
			}
			else if verticalspeed > 30{      
				set tPitch to min(iPitch,max(mPitch,90*(1 - alt:radar/mPitchAlt))).
				set hWork to heading(tHeading,tPitch).
			}
			else if verticalspeed > 10{
				set hWork to heading(tHeading,90).
				gear off.
			}
			set tWork to aPID:update(time:seconds,verticalspeed).
		}
		else if rm = 3{
			set tPitch to min(iPitch,max(mPitch,90 * (1 - alt:radar/mPitchAlt))).
			set hWork to heading(tHeading,tPitch). 
			if eta:periapsis < eta:apoapsis{
				set tWork to 1.
			}			
			else if ship:altitude < pidAlt{
				set tWork to aPID:update(time:seconds,eta:apoapsis).
			}
			else{
				set tWork to setThrottle(ship:apoapsis,tApo,0.1).
			}
			if (ship:apoapsis > tApo){
				set tWork to 0.
				set hWork to ship:prograde.
				notify("COAST TO APOAPSIS").
				wait 5.
				setAlarm(time:seconds + eta:apoapsis - 90).
				set rm to 4.
			}
		}
		else if rm = 4{
			set tWork to 0.
			set hWork to ship:prograde.

			if eta:apoapsis < sBurn + 10{
				rcs on.
			}
			if eta:apoapsis < sBurn{
				notify("CIRCULARIZE").
				rcs off.
				set rm to 5.
			}
		}
		else if rm = 5{
			if ship:periapsis > tApo * .9 and ship:orbit:period > tPrd{
				notify("ORBIT ESTABLISHED").
				set tWork to 0.
				set rm to 0.
			}
			set hWork to ship:prograde.
			set tWork to setThrottle(ship:orbit:period,tPrd,0.1).
		}
		// checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Ascent   " at (1,1).
		print "Pitch  : " + round(tPitch) + " " at (1,7).
	}
	lock throttle to 0.
	lock steering to ship:prograde.
	clearscreen.
}