@lazyglobal off.
if true and
	require("navigation.ks") and
	require("changeOrbit.ks") and
	require("adjustOff.ks") and
	require("adjustPrd.ks") and
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
	local fOrbit is 1067600.
	local tObject is orbitable("CommSat I"). 
	local tOffset is 270.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			changeorbit(tObject:orbit:apoapsis,true).
			setPhase(2).
		}
		if phase = 2 {
			if approx(apoapsis,fOrbit,500) {
				setphase(3).
			}
			else {
				changeorbit(fOrbit,true).
			}
		}
		if phase = 3 {
			adjustOffset(tObject,tOffset,1).
			wait 5.
			adjustPeriod(tObject:orbit:period).
			if approx(apoapsis,fOrbit,500) {
				setphase(0).
			}
			else {
				setPhase(2).
			}
		}
	}
	notify("Orders complete").
	setphase(9).
}