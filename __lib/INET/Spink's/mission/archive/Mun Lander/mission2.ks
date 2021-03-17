@lazyglobal off.
if true and
	require("navigation.ks") and
	require("changeOrbit.ks") and
	require("insertion.ks") and
	require("adjustOff.ks") and
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
	local fOrbit is 50000.
	local tObject is orbitable("Mun"). 
	local tOffset is 25.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			lock steering to prograde.
			until intercept(tObject,tOffset){
				wait 0.01.
			}
			changeorbit(tObject:orbit:apoapsis,false).
			wait 5.
			setAlarm(time:seconds + eta:transition).
			setPhase(2).
		}
		else if phase = 2 {
			if ship:orbit:body:name = tObject:name{
				setPhase(3).		
			}
		}
		else if phase = 3 {
			Notify("Entering Mun SOI").
			wait 10.
			insertion(1000000).
			wait 5.
			setPhase(4).			
		}
		else if phase = 4 {
			changeorbit(fOrbit,true).
			setPhase(5).
		}
		else if phase = 5 {
			if homeconnection:isconnected {
				notify("Ready for mission orders").
				deletepath(pLocal + "insertion.ks").
				deletepath(pLocal + "changeOrbit.ks").
				deletepath(pLocal + "navigation.ks").
				deletepath(pLocal + "adjustOff.ks").
				copypath(pMission + "mission3.ks", pMission + sUpdate).
				setPhase(0).
				wait 5.
				reboot.
			}
		}
	}
	notify("Orders complete").
}