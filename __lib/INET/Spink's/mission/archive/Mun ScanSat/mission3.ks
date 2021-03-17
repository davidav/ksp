@lazyglobal off.
if true and
	require("changeOrbit.ks") and
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
	local fOrbit is 200000.
	local tObject is orbitable("Mun"). 
	local tOffset is 25.
	local tIncl is 90.
	if phase = 0 {
		setPhase(1).	
	}	
	until phase = 0 {
		if phase = 1 {
			// adjustInclination(tIncl,orbit:LAN).
			wait 5.
			changeorbit(fOrbit,true).
			setPhase(0).			
		}
	}
	activateModule("ScanSat","Start RADAR Scan").
	notify("Orders complete").
	setPhase(9).
	wait until false.
}