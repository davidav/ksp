@lazyglobal off.

if true and
	require("ascent.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}

function main {
	if phase = 0 {
		setPhase(1).	
	}
	until phase = 0 {
		if phase = 1 {	
			ascent().
			wait 5.
			setPhase(0).
		}
	}
	notify("Orders complete").
	wait until false.
}