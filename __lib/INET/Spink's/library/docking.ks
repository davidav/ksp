@lazyglobal off.
require("control.ks").
function dock{
	parameter myPortTag,tgtVessel,tgtPortTag.
	local tgtDist is 100.
	local tgtSpeed is 1.
	local myPort is "NULL".
	local tgtPort is "NULL".
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	local rm is 1.
	
	set myPort to getPort(ship,myPortTag).
	set tgtPort to getPort(tgtVessel,tgtPortTag).
	if myPort = "NULL" or tgtPort = "NULL"{
		notify("Docking attemping aborted").
		return.
	}
	myPort:controlfrom.
	// set target to tgtPort.
	lock relVel to ship:velocity:orbit - tgtVessel:velocity:orbit.
	lock relPos to ship:position - tgtVessel:position.	

	lock dirOffset to tgtPort:portfacing:forevector.
	lock distOffset to tgtPort:portfacing:forevector * tgtDist.
	lock vApproach to (relPos:normalized * tgtDist) - relPos.
	
	set rm to 1.
	until rm = 0{
		sas off.
		rcs on.
		if rm = 1{
			killRelVel(tgtPort).
			notify("Move to " + tgtDist).		
			lock vApproach to (relPos:normalized * tgtDist) - relPos.			
			set rm to 2.			
		}
		else if rm = 2{
			if vApproach:mag < 0.1{
				killRelVel(tgtPort).			
				set rm to 3.
			}
			translate((vApproach:normalized * tgtSpeed) - relVel).
			set hWork to heading(0,0).		
		}		
		else if rm = 3{

			// lock offsetFore to gtPort:portfacing:forevector.
			// lock offsetAft to -offsetFore.
			// lock distFore to offsetFore * tgtDist.
			// lock distAft to offsetAft * tgtDist.
			
			// if (tgtPort:nodeposition - myPort:nodeposition + distFore):mag <
				// (tgtPort:nodeposition - myPort:nodeposition + distAft):mag{
				// lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
				// killRelVel(tgtPort).	
				// lock distOffset to tgtPort:portfacing:forevector * tgtDist.
				// lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
				// notify("Already in front").
				// set target to tgtPort.				
				// set rm to 5.				
			//}
			// get a direction perpendicular to the docking port			
			lock dirOffset to tgtPort:ship:facing:starvector.
			if abs(dirOffset * tgtPort:portfacing:forevector) = 1{
				lock dirOffset to tgtPort:ship:facing:topvector.
			}
			lock distOffset to dirOffset * tgtDist.
			// flip the offset if we're on the other side of the ship
			if (tgtPort:nodeposition - myPort:nodeposition + distOffset):mag >
				(tgtPort:nodeposition - myPort:nodeposition - distOffset):mag{
				lock distOffset to (-dirOffset) * tgtDist.
			}
			lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
			set rm to 4.
		}
		else if rm = 4{
			if vApproach:mag < 0.1{
				killRelVel(tgtPort).	
				lock distOffset to tgtPort:portfacing:forevector * tgtDist.
				lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
				notify("Begin approach").
				set target to tgtPort.				
				set rm to 5.				
			}		
			set hWork to heading(0,0).	
			translate((vApproach:normalized * tgtSpeed) - relVel).		
		}
		else if rm = 5{	
			lock distOffset to tgtPort:portfacing:forevector * tgtDist.
			lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
			if myPort:state <> "ready"{
				translate(v(0,0,0)).
				rcs off.
				set rm to 0.
			}
			local vDist is (tgtPort:nodeposition - myPort:nodeposition).
			local aDiff is max(2,tgtDist / 10).
			if vang(myPort:portfacing:forevector,vDist) < aDiff and abs(tgtDist - vDist:mag) < 0.1{
				set tgtDist to tgtDist / 2.
				set tgtSpeed to max(0.2,tgtDist / 20).
			}
			translate((vApproach:normalized * tgtSpeed) - relVel).		
			set hWork to lookdirup(-tgtPort:portfacing:forevector,tgtPort:portfacing:upvector).
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		telemetry(rm).
		print "Range   : " + round(tgtVessel:distance) + " " at (1,8).
		print "Bearing  : " + round(tgtVessel:bearing) + " " at (1,9).
		print "RelVel  : " + round(relVel:mag,2) + " " at (1,10).
		print "vApproach : " + round((vApproach):mag) + " " at (1,11).
		print "Docking   " at (1,1).
	}	
	rcs off.
	lock throttle to 0.
	lock steering to prograde.
	clearscreen.
}
function getPort{
	parameter tgtVessel.
	parameter tgtPort.
	for thePort in tgtVessel:dockingports{
		if thePort:tag = tgtPort{
			return thePort.
		}
		else if tgtPort = "Any" and thePort:state = "ready"{
			return thePort.
		}
	}
	notify("Port " + tgtPort + " not found on " + tgtVessel:name).
	wait 1.
	return "NULL".
}

function translate{
	parameter tVector.
	if tVector:mag > 1 set tVector to tVector:normalized.
	set ship:control:starboard to tVector * ship:facing:starvector.
	set ship:control:fore to tVector * ship:facing:forevector.
	set ship:control:top to tVector * ship:facing:topvector.
}

function killRelVel{
	parameter tgtPort.
	notify("Kill rel velocity").
	until relVel:mag < 0.1{
		translate(-relVel).
	}
	translate(v(0,0,0)).
}
function sideswipe_port{
	parameter tgtPort,myPort,tgtDist,tgtSpeed.
	myPort:controlfrom().
	// get a direction perpendicular to the docking port
	lock dirOffset to tgtPort:ship:facing:starvector.
	if abs(dirOffset * tgtPort:portfacing:forevector) = 1{
		lock dirOffset to tgtPort:ship:facing:topvector.
	}
	lock distOffset to dirOffset * tgtDist.
	lock offsetgtDist2 to (-dirOffset) * tgtDist.
	// flip the offset if we're on the other side of the ship
	if (tgtPort:nodeposition - myPort:nodeposition + distOffset):mag >
		(tgtPort:nodeposition - myPort:nodeposition - distOffset):mag{
		lock distOffset to (-dirOffset) * tgtDist.
	}
	lock vApproach2 to tgtPort:nodeposition - myPort:nodeposition + offsetgtDist2.
	lock vApproach to tgtPort:nodeposition - myPort:nodeposition + distOffset.
	lock relVel to ship:velocity:orbit - tgtPort:ship:velocity:orbit.
	lock steering to -1 * tgtPort:portfacing:forevector.
	until false{
		translate((vApproach:normalized * tgtSpeed) - relVel).
		if vApproach:mag < 0.1 break.
		wait 0.01.
		print "vApproach : " + round((vApproach):mag) + " " at (1,19).
		print "vApproach2: " + round((vApproach2):mag) + " " at (1,20).
		// print "tgt range  : " + round(tgtPort:distance) + "    " at (1,15).
		// print "tgt bearing : " + round(tgtPort:bearing) + "    " at (1,16).
	}
	translate(v(0,0,0)).
}