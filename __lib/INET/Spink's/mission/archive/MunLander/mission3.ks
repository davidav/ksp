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
	local fOrbit is 25000.
	local tObject is orbitable("Mun"). 
	local tOffset is 25.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			changeOrbit(fOrbit,true).
			setPhase(2).
		}
		if phase = 2 {
			MunDescent().
			doscience(true,false).
			setphase(0).
		}
	}
	notify("Orders complete").
	shutdown.
}