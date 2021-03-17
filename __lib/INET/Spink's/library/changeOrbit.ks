//changeOrbit.ks
@lazyglobal off.
require("control.ks").

function changeOrbit{
	parameter newApo.
	parameter circularize is true.
	parameter newPeri is newApo.
	local cApo is false.
	local cPeri is false.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	local tPrd is getPeriod(newApo,newPeri).
	notify("Change orbit to " + newApo).
	local rm is 1.
	until rm = 0{
		if rm = 1{
			if newApo > ship:apoapsis{
				set hWork to prograde.
				rcs on.
				if align(prograde) < 10{
					set rm to 2.
				}
			}
			else if newPeri < ship:periapsis{
				set hWork to retrograde.
				rcs on.
				if align(retrograde) < 10{
					rcs off.
					set rm to 5.
				}
			}
			else if eta:apoapsis < eta:periapsis{
				setAlarm(time:seconds + eta:apoapsis - 120).
				set rm to "1a".
			}
			else if eta:apoapsis > eta:periapsis{
				setAlarm(time:seconds + eta:periapsis - 120).
				set rm to "1b".
			}
		}
		else if rm = "1a"{
			set hWork to prograde.
			if eta:apoapsis < 20{
				rcs on.
			}
			else{
				rcs off.
			}
			if eta:apoapsis < 10{
				set rm to 4.
			}
		}
		else if rm = "1b"{
			set hWork to retrograde.
			if eta:periapsis < 20{
				rcs on.
			}
			else{
				rcs off.
			}
			if eta:periapsis < 10{
				set rm to 3.
			}
		}
		else if rm = 2{
			set hWork to prograde.
			if ship:apoapsis > newApo{
				rcs off.
				set tWork to 0.
				set cApo to true.
				set rm to 6.
			}
			set tWork to setThrottle(ship:apoapsis,newApo,0.1).
		}
		else if rm = 3{
			set hWork to retrograde.
			if ship:apoapsis < newApo{
				rcs off.
				set tWork to 0.
				set cApo to true.
				set rm to 6.
			}
			set tWork to setThrottle(ship:apoapsis,newApo,0.1).
		}
		else if rm = 4{
			set hWork to prograde.
			if ship:periapsis > newPeri or ship:orbit:period > tPrd{
				rcs off.
				set tWork to 0.
				set cPeri to true.
				set rm to 6.
			}
			set tWork to setThrottle(ship:periapsis,newPeri,0.1).
		}
		else if rm = 5{
			set hWork to retrograde.
			if ship:periapsis < newPeri{
				rcs off.
				set tWork to 0.
				set cPeri to true.
				set rm to 6.
			}
			set tWork to setThrottle(ship:periapsis,newPeri,0.1).
		}
		else if rm = 6{
			set tWork to 0.
			if not circularize{
				set rm to 0.
			}
			else if cApo = true{
				setAlarm(time:seconds + eta:apoapsis - 120).
				set rm to "6a".
			}
			else if cPeri = true{
				setAlarm(time:seconds + eta:periapsis - 120).
				set rm to "6b".
			}
		}
		else if rm = "6a"{
			if ship:periapsis < newPeri{
				set hWork to prograde.
				if eta:apoapsis < 20{
					rcs on.
				}
				else{
					rcs off.
				}
				if eta:apoapsis < 10{
					set rm to 7.
				}
			}
			else{
				set hWork to retrograde.
				if eta:apoapsis < 20{
					rcs on.
				}
				else{
					rcs off.
				}
				if eta:apoapsis < 10{
					set rm to 8.
				}
			}
		}
		else if rm = "6b"{
			if ship:apoapsis < newApo{
				set hWork to prograde.
				if eta:periapsis < 20{
					rcs on.
				}
				else{
					rcs off.
				}
				if eta:periapsis < 10{
					set rm to 7.
				}
			}
			else{
				set hWork to retrograde.
				if eta:periapsis < 20{
					rcs on.
				}
				else{
					rcs off.
				}
				if eta:periapsis < 10{
					set rm to 8.
				}
			}
		}
		else if rm = 7{
			notify("circularizing prograde").
			set hWork to prograde.
			if ship:orbit:period > tPrd{
				rcs off.
				set tWork to 0.
				set rm to 0.
			}
			set tWork to setThrottle(ship:orbit:period,tPrd,0.1).
		}
		else if rm = 8{
			notify("circularizing retrograde").
			set hWork to retrograde.
			if ship:orbit:period < tPrd{
				rcs off.
				set tWork to 0.
				set rm to 0.
			}
			set tWork to setThrottle(ship:orbit:period,tPrd,0.1).
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Change orbit  " at (1,1).
		print "new Orbit: " + round(newApo) +
						 " x " + round(newPeri) + "    " at (1,8).
		print "curr prd : " + round(ship:orbit:period) + " " at (1,9).
		print "tgt prd : " + round(tPrd) + " " at (1,10).
	}
	lock throttle to 0.
	lock steering to prograde.
	rcs off.
	clearscreen.
}