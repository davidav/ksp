@lazyglobal off.
if true and
	require("docking.ks") and
	require("rendezvous.ks") and
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
	local myPort is "Gemini".
	local tgtPort is "Crew".
	local tDist is 100.
	if phase = 0 {
		setPhase(1).
	}
	until phase = 0 {
		if phase = 1 {
			rendezvous(tObject, 10, 500).
			setPhase(2).
		}
		if phase = 2 {
			dock(myPort, tObject, tgtPort).
			setPhase(0).
		}
	}
	notify("Orders complete").
	shutdown.
}

