@lazyglobal off.
if true and
	require("systems.ks") and
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
	local tAltitude is 2000.   //500 = -245  600= +181  550=        2092
	local tHeading is 118.
	local tPitch is 60.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	
	local kP1 is 0.05.	// 0.05
	local kI1 is 0.6.	// 0.5
	local kD1 is 0.01.	// 0.01	
	local aPID is pidloop(kP1, kI1, kD1, 0, 1).
	set aPID:setpoint to 0.
	local aGround is alt:radar.
	abort off.
	setphase(1).
	until phase = 0 {
		if phase = 1 {	
			wait 10.
			stage.
			setPhase(2).
			set hWork to up.
			set aPID:setpoint to 50.
		}
		else if phase = 2 {
			if alt:radar > tAltitude {
				stage.
				setPhase(3).
			}
			else if alt:radar > 20  {
				gear off.
			}
			set hWork to heading(tHeading,tPitch).
			set aPID:setpoint to 20.
			set tWork to aPID:update(time:seconds, verticalspeed).
		}
		else if phase = 3 {
			if ship:status = "Landed" {
				set tWork to 0.
				setphase(0).
			}
			else if alt:radar > 500 {
				set aPID:setpoint to -25.
			}
			else if alt:radar > 50 {
				set aPID:setpoint to -15.
			}
			else if alt:radar > 20 {
				set aPID:setpoint to -5.
			}
			else {
				set aPID:setpoint to -2.
				gear on.
			}
			lock steering to descent_vector().			
			set tWork to aPID:update(time:seconds, verticalspeed).
		}
		set tLock to tWork.
		set hLock to hWork.
		wait 0.
		eTime().
		telemetry().
	}
	notify("Orders complete").
	shutdown.
}
function g {
	return body:mu / ((ship:altitude + body:radius)^2).
}
function descent_vector {
	if vang(srfretrograde:vector, up:vector) > 90 return unrotate(up).
	return unrotate(up:vector * g() - velocity:surface).
}
function unrotate {
	parameter v. if v:typename <> "Vector" set v to v:vector.
	return lookdirup(v, ship:facing:topvector).
}