//insertion.ks
@lazyglobal off.
require("control.ks").
function insertion{
	parameter iOrbit is 0.
	notify("Begin insertion").
	lock steering to retrograde.	
	setAlarm(time:seconds + eta:periapsis - 120).
	wait until eta:periapsis < 30.
	lock throttle to 1.
	wait until ship:apoapsis > 0.
	if iOrbit > 0{
		wait until ship:apoapsis < iOrbit.
	}
	lock throttle to 0.
	return true.
}