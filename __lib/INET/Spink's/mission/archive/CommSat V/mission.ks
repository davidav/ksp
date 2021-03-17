@lazyglobal off.

if true and
	require("ascent.ks") and
	require("systems.ks") and
	require("changeorbit.ks") and
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
	local iHdg is 90.
	local iOrbit is 1067600.
	local iPitch is 90.
	local fOrbit is 1067600.

	when ship:altitude > 60000 then {
		deployFairings().
	}
	when ship:altitude > 70000 then {
		deployPanels().
		deployAntenna().
	}


	setPhase(1).	

		
	until phase = 0 {
		if phase = 1 {
			ascent(iHdg,iOrbit,iPitch).
			wait 5.
			setPhase(2).
		}
		if phase = 2 {
			changeorbit(fOrbit,true).
			setPhase(3).
		}
		if phase = 3 {
			adjustPeriod(7200).
			if approx(apoapsis,1067.7,2) {
				setphase(0).
			}
			else {
				setPhase(1).
			}
		}
	}
	setPhase(9).
	notify("Orders complete").
}