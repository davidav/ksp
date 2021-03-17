@lazyglobal off.
global tSci is 0.

if true and
	require("science.ks") and
	true {
	main().
}
else{
	notify("REBOOTING").
	wait 10.
	reboot.
}

function main {
	when ship:altitude > 0 then {
		if tSci < 1 {
			doScience().
			set tSci to 20.
			}
		else {
			set tSci to tSci - eTime().	
		}
		return true.
	}
	wait until false.
}