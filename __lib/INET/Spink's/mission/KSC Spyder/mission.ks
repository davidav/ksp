// land a lander at the monolith
@lazyglobal off.
if true and
	require("systems.ks") and
	require("navigation.ks") and
	require("control.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}
function main {
	local tWork is 0.
 	local hWork is ship:facing.
	local tAltitude is 500.   
	local tHeading is 0.
	local tPitch is 90.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	
	local kP1 is 0.1.		// proportion - amount of error
	local kI1 is 0.05.		// integral 	- error over time
	local kD1 is 0.05.		// derivative - error change rate 
	local aPID is pidloop(kP1,kI1,kD1,0,1).
	set aPID:setpoint to 10.

	local tgtPos is latlng(0.102330,-74.568421). //Monolith
	lock shipPos to ship:geoposition. 
	local tCD is 10.
	eTime().eTime().

	setphase(1).
	
	until phase = 0 {
		if phase = 1{ 
			if tCD > 0{
				notify("COUNTDOWN INITIATED: T - " + round(tCD)).
				set tCD to tCD - tElapsed.
			}
			else{
				stage.
				set hWork to ship:facing.
				set aPID:setpoint to 10.
				notify("LAUNCH").
				setPhase(2).
			}
		}
		else if phase = 2{
			if alt:radar > 10 {
				gear off.
				setPhase(3).
			}
			set hWork to ship:facing.
			set tWork to aPID:update(time:seconds,verticalspeed).
		} 
		else if phase = 3 {
			if ship:altitude > tAltitude{
				set tCD to 30.
				aPID:reset().
				setPhase(4).
			}
			set aPID:setpoint to 10.
			set hWork to heading(tHeading,tPitch).
			set tWork to aPID:update(time:seconds,verticalspeed).
		}
		else if phase = 4 {
			if tCD < 0 {
				aPID:reset().
				setPhase(5).
			}
			else{
				set tCD to tCD - tElapsed.
			}
			set aPID:setpoint to 0.		
			set hWork to descent_vector().	
			set tWork to aPID:update(time:seconds,verticalspeed).
		}
		else if phase = 5 {
			if ship:status = "Landed" {
				setphase(0).
			}
			else if alt:radar > 500{
				set aPID:setpoint to -30.	
				set hWork to descent_vector().					
			}
			else if alt:radar > 100{
				set aPID:setpoint to -20.	
				set hWork to descent_vector().	
			}
			else if alt:radar >	30{
			set aPID:setpoint to -10.
			}
			else {
				set hWork to up.	
				gear on.
				set aPID:setpoint to -5.	
			}
			set hWork to descent_vector().			
			set tWork to aPID:update(time:seconds,verticalspeed).
		}
		useRCS(hWork,0.1).
		set tLock to tWork.
		set hLock to hWork.
		wait 0.
		eTime().
		telemetry().
		print "tPitch  : " + round(tPitch) + " " at (1,7).
		print "Actual : " + round(90-(vang(ship:facing:vector,ship:up:Vector))) + "   " at (15,7).
		print "Tgt Dist: " + round(circle_distance(tgtPos,shipPos,ship:body:radius)) + "   " at (1,8).
		
		print "PID  : " + aPID:setpoint + " m/s  " + "error %: " + round(100 - (verticalspeed/(aPID:setpoint + .01) * 100),2) + "     " at (1,10).
		print "PTERM: " + round(aPID:PTERM,5) + "   " at (1,11).
		print " x " +	kP1 + "  " at (15,11).
		print "ITERM: " + round(aPID:ITERM,5) + "   " at (1,12).
		print " x " + kI1 + "  " at (15,12).
		print "DTERM: " + round(aPID:DTERM,5) + "   " at (1,13).
		print " x " + kD1 + "  " at (15,13).
	}
	lock throttle to 0.
	rcs off.
	notify("Orders complete").
	until false{
		idle().
	}
}
function g {
	return body:mu/((ship:altitude + ship:body:radius)^2).
}
function descent_vector{
	if vang(srfretrograde:vector, up:vector) > 90{
		return unrotate(up).
	}
	else{ 
		return unrotate(up:vector * g() - velocity:surface).
	}
}
function unrotate {
	parameter v.
	if v:typename <> "Vector" {
		set v to v:vector.
	}
	return lookdirup(v,ship:facing:topvector).
}
