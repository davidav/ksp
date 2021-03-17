@lazyglobal off.
if true and
	require("changeOrbit.ks") and
	require("adjustOff.ks") and
	require("MunDescent.ks") and
	// require("systems.ks") and
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
	local tLat is 33.16500000.
	local tLng is 128.57305556.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			// adjustInclination(tLat,tLng - 90).
			changeOrbit(fOrbit,true).
			setPhase(2).
		}
		if phase = 2 {
			MunDescent(tLat,tLng,1,50).
			deployPanels().
			wait 10.
			setphase(0).
		}
	}
	notify("Orders complete").
	setphase(9).
	wait until false.
}