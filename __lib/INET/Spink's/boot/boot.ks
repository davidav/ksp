@lazyglobal off.
wait until ship:unpacked.
set ship:control:pilotmainthrottle to 0.
clearscreen.
CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
set Terminal:CHARHEIGHT to 18.
global phase is 0.
global tElapsed is .01.
global tPrev is time:seconds.
global stageMax is ship:maxthrust.
global tLock is 0.
global hLock is ship:facing.
global pLocal is "1:/".
global pMission is "0:/mission/" + ship:name + "/".
global pLibrary is "0:/library/".
global sPhase is "phase.ks".
global sUpdate is "update.ks".
global sMission is "mission.ks".
bootup().
function bootup{
	if homeconnection:isconnected {
		if ship:status = "PRELAUNCH"
			if exists(pMission + sMission){
				copypath(pMission + sMission,pLocal + sMission).
			}
			else{
				notify("Mission script not found in " + pMission,red).
				notify("REBOOTING",red).
				wait 5.
				reboot.
			}
		else if exists(pMission + sUpdate){
			set warp to 0.
			notify("Downloading new instructions").
			wait 1.
			copypath(pMission + sUpdate,pLocal + sMission).
			deletepath(pMission + sUpdate).
		}
	}
	else{
		set warp to 0.
		notify("Attempting to regain contact").
		If require("systems.ks"){
			deployAntenna().
			deployDish().
			pointDish("Kerbin").
			wait 5.
			if homeconnection:isconnected {
				reboot.
			}
		}
	}
	if exists(pLocal + sPhase){
		runpath(pLocal + sPhase).
		notify("Phase is " + phase + " " + ship:status).
	}
	if exists(pLocal + sMission){
		runpath(pLocal + sMission).
	}
}
function require{
	parameter fname.
	if homeconnection:isconnected {
		if exists(pMission + fname){
			if exists(pLocal + fname){
				notify("Updating file " + fname).
			}
			else{
				notify("Downloading file " + fname).
			}
			copypath(pMission + fname,pLocal + fname).
			deletepath(pMission + fname).
			wait 1.
		}
		else if exists(plibrary + fname){
			copypath(pLibrary + fname,pLocal + fname).
			notify("Downloading file " + fname).
			wait 1.
		}
	}
	if exists(pLocal + fname){
		runoncepath(pLocal + fname).
		return true.
	}
	else{
		notify(fname + " not found", red).
		return false.
	}	
}
function setPhase{
	parameter pNew.
	set phase to pNew.
	notify("Phase " + phase,white).
	switch to 1.
	deletepath(pLocal + sPhase).
	log "set phase to " + phase + "." to sPhase.
}
function notify{
	parameter nMsg.
	parameter nCol is yellow.
	parameter nDly is 5.
	parameter nSty is 2.
	parameter nSz is 20.
	parameter nEcho is false.
	hudtext(nMsg,nDly,nSty,nSz,nCol,nEcho).
}
function eTime{
	set tElapsed to time:seconds - tPrev.
	set tPrev to time:seconds.
	return tElapsed.
}
function approx{
	parameter a.
	parameter b.
	parameter rng.
	return a - rng < b and a + rng > b.
}