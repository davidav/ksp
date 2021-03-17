@lazyglobal off.
if true and
	require("ascent.ks") and
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
	local iOrbit is 100000.
	local iPitch is 90.


	if phase = 0 {
		setPhase(1).	
	}
	
	until phase = 0 {
		if phase = 1 {
			ascent(iHdg,iOrbit).
			setPhase(2).
		}
		else if phase = 2 {
			if homeconnection:isconnected {
				notify("Ready for mission orders").
				deletepath(pLocal + "ascent.ks").
				copypath(pMission + "mission2.ks", pMission + sUpdate).
				wait 5.
				setphase(0).
				reboot.
			}
		}
	}
	notify("Orders complete").
}