@lazyglobal off.
global tSci is 0.
if true and
	require("ascent.ks") and
	require("science.ks") and
	require("systems.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}
function main {
	local iHdg is 0.
	local iOrbit is 255000.
	local iPitch is 80.

	
	
	when ship:altitude > 70000 then {
		deployFairings().
	}
	when ship:altitude > 75000 then {
		deployPanels().
		deployAntenna().
	}
	
	if phase = 0 {
		setPhase(1).	
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

	until phase = 0 {
		if phase = 1 {	
			ascent(iHdg,iOrbit,iPitch).
			wait 5.
			setPhase(0).
		}
	}
	activateModule("ScanSat","Start RADAR Scan").
	notify("Orders complete").
	wait until false.
}