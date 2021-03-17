@lazyglobal off.
if true and
	require("changeOrbit.ks") and
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
	local tObject is orbitable("Mun"). 
	local tOffset is 25.
	
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			changeorbit(fOrbit,true).
			wait 5.
			adjustPeriod(fperiod).
			if approx(apoapsis,fOrbit,2) {
				setphase(0).
			}
			else {
				setPhase(1).
			}
		}

	}
	notify("Orders complete").
}