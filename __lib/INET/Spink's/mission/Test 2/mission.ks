@lazyglobal off.
global tSci is 0.

if true and
	require("ascent.ks") and
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
	local tHeading is 90.
	local tApo is 80000.
	local iPitch is 90.
	local ApoETA is 60.
	local sBurn is 5.
	local mPitchAlt is 60000.


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

	notify("Orders complete").
	wait until false.
}