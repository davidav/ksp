@lazyglobal off.
global tSci is 0.
if true and
	require("ascent.ks") and
	require("systems.ks") and
	require("navigation.ks") and
	require("control.ks") and
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
	local iOrbit is 1067600.
	local iPitch is 90.
	local fOrbit is 1067600.
	local tObject is orbitable("CommSat I"). 
	local tOffset is 180.

	when ship:altitude > 60000 then {
		deployFairings().
	}
	when ship:altitude > 70000 then {
		deployPanels().
		deployAntenna().
	}	
	if phase = 0 {
		setPhase(1).	
	}
		
	until phase = 0 {
		if phase = 1 {
			until intercept(tObject,tOffset){
				wait 0.01.
			}
			ascent(iHdg,tObject:orbit:apoapsis,iPitch).
			wait 5.
			if stage:number > 0 {
				stage.
			}
			setPhase(2).
		}
		if phase = 2 {
			if homeconnection:isconnected {
				notify("Ready for mission orders").
				deletepath(pLocal + "ascent.ks").
				copypath(pMission + "mission2.ks", pMission + sUpdate).
				wait 5.
				reboot.
			}
		}
	}
	notify("Orders complete").
	wait 30.
	shutdown.
}