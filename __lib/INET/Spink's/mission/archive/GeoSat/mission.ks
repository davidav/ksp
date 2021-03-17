@lazyglobal off.
global tSci is 0.
if true and
	require("ascent.ks") and
	require("systems.ks") and
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
	local iOrbit is 2863334.
	local iPitch is 80.

	
	
	when ship:altitude > 60000 then {
		deployFairings().
	}
	when ship:altitude > 65000 then {
		deployPanels().
		deployAntenna().
	}
	
	if phase = 0 {
		setPhase(1).	
	}
	

	until phase = 0 {
		if phase = 1 {	
			ascent(iHdg,iOrbit,iPitch).
			wait 5.
			setPhase(0).
		}
	}
	deployDish().
	pointDish("Jool").
	notify("Orders complete").
	wait until false.
}