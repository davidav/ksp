@lazyglobal off.
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
	local iHdg is 90.
	local iOrbit is 75000.
	local iPitch is 90.
	local ApoETA is 60.
	local sBurn is 5.
	local mPitchAlt is 60000.
	
	if phase = 0 {
		setPhase(1).
	}
	until phase = 0 {
		if phase = 1 {
			ascent(iHdg,iOrbit,iPitch,ApoETA,sBurn,mPitchAlt).
			setPhase(2).
		}
		if phase = 2 {
			recovery().
			setPhase(0).
		}
	}
	notify("Orders complete").
}