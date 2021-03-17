@lazyglobal off.
global tSci is 0.
if true and
	require("ascent.ks") and
	require("recovery.ks") and
	require("science.ks") and
	// require("systems.ks") and
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
	local iOrbit is 75000.
	local iPitch is 90.
	
	// when ship:altitude > 60000 then {
		// deployFairings().
	// }
	// when ship:altitude > 65000 then {
		// deployPanels().
		// deployAntenna().
	// }	
	// when ship:altitude > 0 then {
		// if tsci < 1 {
			// doScience(true,false).
			// set tSci to 20.
			// }
		// else {
			// set tSci to tSci - eTime().	
		// }
		// return true.
	// }
	
	if phase = 0 {
		setPhase(1).	
	}

	until phase = 0 {
		if phase = 1 {	
			ascent(iHdg,iOrbit,iPitch).
			wait 5.
			setPhase(2).
		}
		if phase = 2 {	
			recovery().
			setPhase(0).
		}
	}
	when ship:status = "LANDED" or ship:status = "SPLASHED" then{
		doScience(true,true).
		wait 10.
		doScience(true,true).		
	}
	notify("Orders complete").
	wait 30.
	shutdown.
}