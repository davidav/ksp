//recovery.ks
@lazyglobal off.
require("control.ks").
require("systems.ks").
require("navigation.ks").
function recovery{
	local burnLNG is 170.
	parameter coordTgt is latlng(-0.0972,-74.5577). //KSC
	lock shipPos to ship:geoposition. 

	local rm is 1.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	
	local rShipLNG is lng2deg(shipPos:lng).
	local rBurnLNG is lng2deg(burnLNG).
	local dLead is 0.
	local burnETA is 0.
	eTime(). wait .1. eTime().
	if rBurnLNG < rShipLNG{
		set dLead to rShipLNG - rBurnLNG.
	}
	else{
		set dLead to 360 - rBurnLNG + rShipLNG.
	}
	
	set burnETA to dLead * (ship:orbit:period/360). 
		
	print "rShipLNG: " + round(rShipLNG,2) at (1,8).
	print "rBurnLNG: " + round(rBurnLNG,2) at (1,9).
	print "dLead   : " + round(dLead,2) at (1,10).
	print "sLead   : " + round(burnETA,2) at (1,11).
	
	if ship:altitude < 60000{
		set rm to 3.
	}
	else{
		setAlarm(time:seconds + burnETA - 30).
	}

	until rm = 0{
		if rm = 1{
			if approx(shipPos:lng,burnLNG,.25){
				notify("INITIATING DE-ORBIT BURN").
				set rm to 2.
			}
			else if approx(shipPos:lng,burnLNG,5){
				useRCS(hWork).
			}
			set tWork to 0.
			set hWork to ship:retrograde.
		}
		else if rm = 2{
			if ship:periapsis > 35000{
				checkStage().
				set tWork to setThrottle(ship:periapsis,35000,.5).
			}
			else{
				set tWork to 0.
				lock throttle to 0.
				wait 5.
				if stage:number > 1 and stage:ready{
					stage.
					wait 1.
				}
				else{
					set rm to 3.				
				}
			}
			set hWork to ship:retrograde.
		}
		else if rm = 3{
			if ship:altitude > 60000{
				rcs off.
			}
			else if ship:altitude > 20000 {
				useRCS(hWork).
			}
			else if alt:radar > 5000{
				rcs off.
				unlock steering.
			}
			else{
				deployChutes().
				set rm to 4.			
			} 
			set hWork to ship:srfretrograde.
			set tWork to 0.
		}
		else if rm = 4{
			if ship:status = "LANDED" or ship:status = "SPLASHED"{
				set rm to 0.
			}
			else if alt:radar < 50{
				sas on.
			}
		}
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Recovery   " at (1,1).
		print "Ship LNG: " + round(shipPos:lng,2) + "  " at (1,14).
		print "Tgt LNG : " + round(coordTgt:lng,2) + "   " at (1,15).
		print "Burn LNG: " + round(burnLNG,2) + "   " at (1,16).
		print "Burn Deg: " + round(dLead,2) + "   " at (1,17).
		print "Burn ETA: " + round(burnETA,2) + "   " at (1,18).
		set burnETA to burnETA - tElapsed.
	}
	notify("LANDED").
	clearscreen.
	return true.
}