@lazyglobal off.
global tsci is 0.
if true and
	require("systems.ks") and
	require("science.ks") and
	require("adjustOff.ks") and
	require("changeOrbit.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}

function main {
	local fOrbit is 50000.
	
	setPhase(1).	
	until phase = 0 {
		if phase = 1 {
			adjustInclination(45,ship:lan).
			setPhase(2).
		}
		if phase = 2 {
			changeOrbit(fOrbit,true).
			setPhase(0).
		}
	}
	when ship:status = "ORBITING" then {
		if tsci < 1 {
			doScience(true,false).
			set tSci to 20.
			}
		else {
			set tSci to tSci - eTime().	
		}
		return true.
	}
	wait until false.
}