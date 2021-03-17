@lazyglobal off.
if true and
	require("navigation.ks") and
	require("changeOrbit.ks") and
	require("adjustOff.ks") and
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
	local fOrbit is 1000000.
	local fperiod is getPeriod(fOrbit).
	local tObject is orbitable("CommSat M-I"). 
	local tOffset is 240.
	
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			changeorbit(fOrbit,true).
			adjustOffset(tObject,tOffset,1).
			adjustPeriod(tObject:orbit:period).
			if approx(apoapsis,fOrbit,2000) {
				setphase(0).
			}
			else {
				setPhase(1).
			}
		}

	}
	notify("Orders complete").
}