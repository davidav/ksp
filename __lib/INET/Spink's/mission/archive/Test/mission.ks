@lazyglobal off.
global tSci is 0.

if true and
	require("ascent.ks") and
	// require("systems.ks") and
	require("science.ks") and
	// require("recovery.ks") and
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
	local iOrbit is 80000.
	local iPitch is 90.
	local ApoETA is 360.
	local sBurn is 5.
	local mPitchAlt is 200000. 


	when ship:altitude > 0 then {
		if tsci < 1 {
			doScience(true,false).
			set tSci to 20.
			}
		else {
			set tSci to tSci - eTime().	
		}
		return true.
	}
	when ship:altitude > 70000 then{
		doScience(true,true).
		wait 10.
		doScience(true,true).
	}
	// when ship:altitude > 100 then{
		// doScience(false,true).
	// }
	// when ship:altitude > 18000 then{
		// doScience(false,true).
	// }

	gear off.

	if phase = 0 {
		setPhase(1).	
	}
	
	until phase = 0 {
		if phase = 1 {	
			ascent(iHdg,iOrbit,iPitch,ApoETA,sBurn,mPitchAlt).
			wait 5.
			gear on.
			setPhase(0).

		}
	}

	when ship:status = "LANDED" or ship:status = "SPLASHED" then{
		doScience(true,true).
		wait 10.
		doScience(true,true).
		wait 10.
		doScience(true,true).		
	}
	notify("Orders complete").
	wait until false.
}