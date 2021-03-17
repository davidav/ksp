@lazyglobal off.
if true and
	require("ascent.ks") and
	require("navigation.ks") and
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
	local fOrbit is 200000.
	local tObject is orbitable("Kerbin Station").
	local tOffset is 0.
	if phase = 0 {
		setPhase(1).
	}
	until phase = 0 {
		if phase = 1 {
			until intercept(tObject,tOffset){
				wait 0.01.
			}
			ascent(iHdg,tObject:orbit:apoapsis,85).
			setPhase(2).
		}
		else if phase = 2 {
			if homeconnection:isconnected {
				notify("Ready for mission orders").
				deletepath(pLocal + "ascent.ks").
				copypath(pMission + "mission2.ks", pMission + sUpdate).
				setPhase(0).
				reboot.
			}
		}
	}
	notify("Orders complete").
}