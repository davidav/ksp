@lazyglobal off.
if true and
	require("systems.ks") and
	require("navigation.ks") and
	require("changeOrbit.ks") and
	require("insertion.ks") and
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
	local fOrbit is 200000.
	local tObject is orbitable("Minmus"). 
	local tOffset is 15.
	
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
			Notify("Entering Minmus SOI").
			deployDish().
			pointDish("Kerbin").
			insertion(1000000).
			wait 5.
			setPhase(4).			
		}
		else if phase = 4 {
			changeorbit(fOrbit,true).
			setPhase(0).
		}
	}
	notify("Orders complete").
}