@lazyglobal off.
global rcsON is false. 
function idle{
	wait .01.
	eTime().
	telemetry(0).
}
function setThrottle{
	parameter cVal.
	parameter tVal.
	parameter tPct.
	parameter tMult is 1.
	local tCutoff is tVal * tPct.
	local tRemain is abs(tVal - cVal).
	return max(0.01,min(1,tMult*tRemain/tCutoff)).
}
function setThrottleTWR{
	parameter tTWR.
	if ship:availablethrust > 0{
		return min(1,tTWR * currGrav(ship:altitude) * (Ship:Mass/Ship:AvailableThrust)).
	}
}
function currGrav{
	parameter atAlt.
	return (constant:G * body:mass)/((atAlt + ship:body:radius)^2).
}
function align{
	parameter tdir.
	local vDiff is vang(ship:facing:vector,tdir:Vector).
	return vDiff.
}
function useRCS{
	parameter hWork is 0.
	parameter vMax is 1.
	parameter vMin is .25.
	if not rcsON and align(hWork) > abs(vMax){
		rcs on.
		set rcsON to true.
	}
	if rcsON and align(hWork) < abs(vMin){
		rcs off.
		set rcsON to false.
	}
}
function getPeriod{
	parameter ap.
	parameter pe is ap.
	local sma is (ap + pe + orbit:body:radius * 2)/2.
	return 2*constant:pi*sqrt(sma^3/ship:orbit:body:mu).
}
function checkStage{
	if stageMax - ship:maxthrust > 10{
		lock throttle to 0.
		stage.
		wait 1.
		lock throttle to tLock.
		set stageMax to ship:maxthrust.
	}
}
function setAlarm{
	parameter aTime.
	if not addons:kac:available{
		return.
	}
	if aTime < time:seconds{
		return.
	}
	local na is addAlarm("Raw",aTime,"Auto from kOS","Auto").
}
function telemetry{
	parameter rm is 0.
	print pMission at (1,0).
	print "Phase: " + phase + " " at (1,2).
	print "rm: " + rm + " " at (12,2).
	print "Status: " + ship:status + "      " at (25,2).
	print "Stage  : " + stage:number + " " at (1,4).
	print "Throttle: " + round(tLock,2) + "      " at (1,5).
	print "Connection to KSC: " at (25,1).
	if homeconnection:isconnected {
    print "YES" at (44,1).
	}
	else{
		print "NO " at (44,1).
	}
}