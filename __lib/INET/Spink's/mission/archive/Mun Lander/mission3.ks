@lazyglobal off.
if true and
	require("changeOrbit.ks") and
	require("MunDescent.ks") and
	require("science.ks") and
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
	local tLat is 0.
	local tLng is -65.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			changeOrbit(fOrbit,true).
			setPhase(2).
		}
		if phase = 2 {
			MunDescent(tLat,tLng).
			wait 10.
			setphase(0).
		}
	}
	when ship:status = "LANDED" or ship:status = "SPLASHED" then{
		doScience(true,true).

	}
	notify("Orders complete").
	setphase(9).
	wait until false.
}