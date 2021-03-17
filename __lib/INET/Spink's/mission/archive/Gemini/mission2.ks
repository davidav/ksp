@lazyglobal off.
if true and
	require("adjustOff.ks") and
	require("changeOrbit.ks") and
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
	local tObject is orbitable("Kerbin Station").
	local tOffset is 0.
	if phase = 0 {
		setPhase(1).
	}
	until phase = 0 {
		if phase = 1 {
			if tObject:distance < 15000 {
				setPhase(3).
			}
			else {
				changeorbit(tObject:orbit:apoapsis,true).
				setPhase(2).			
			}
		}
		if phase = 2 {
			if tObject:distance < 15000 {
				setPhase(3).
			}
			else {
				adjustOffset(tObject,tOffset).	
				setPhase(3).
			}
		}
		if phase = 3 {
			if tObject:distance > 15000 {
				setPhase(1).
			}	
			else {
				setPhase(4).		
			}			
		}
		else if phase = 4 {
			if homeconnection:isconnected {
				notify("Ready for mission orders").
				deletepath(pLocal + "changeOrbit.ks").
				deletepath(pLocal + "navigation.ks").
				deletepath(pLocal + "adjustOff.ks").
				copypath(pMission + "mission3.ks", pMission + sUpdate).
				wait 5.
				setPhase(0).
				reboot.
			}
		}
	}
	notify("Orders complete").
	shutdown.
}

