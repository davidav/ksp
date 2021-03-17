@lazyglobal off.
global tSci is 0.

if true and
	require("ascent.ks") and
	require("science.ks") and
	require("recovery.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}

function main {
	local tHeading is 270.
	local tApo is 70000.
	local iPitch is 90.
	local ApoETA is 600.
	local sBurn is 5.
	local mPitchAlt is 30000.


	when ship:altitude > 100 then {
		if tSci < 1 {
			doScience().
			set tSci to 20.
			}
		else {
			set tSci to tSci - eTime().	
		}
		return true.
	}
	when ship:altitude > 100 then {
		doScience(false,true).
	}
 	when ship:altitude > 18000 then {
		doScience(false,true).
	} 	
	if phase = 0 {
		setPhase(1).	
	}
	until phase = 0 {
		if phase = 1 {	
			ascent(tHeading,tApo,iPitch,ApoETA,sBurn,mPitchAlt).
			wait 5.
			setPhase(2).
		}
		if phase = 2 {	
			recovery().
			wait 5.
			setPhase(0).
		}
	}

	when ship:status = "LANDED" or ship:status = "SPLASHED" then{
		doScience(true,true).
		wait 10.
	}
	notify("Orders complete").
	wait until false.
}