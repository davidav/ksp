//adjustInc.ks
@lazyglobal off.
require("control.ks").
require("navigation.ks").
function adjustInclination{
	parameter tIncl.
	parameter tLoAN.
	local rm is 1.
	local tWork is 0.
 	local hWork is ship:facing.
	set tLock to tWork.
	set hLock to hWork. 
	lock throttle to tLock.
	lock steering to hLock.
	local nLong is 0.
	local sApo is apoapsis.
	until rm = 0{
		set nLong to lng2deg(180 + orbit:body:rotationangle + lng2deg(ship:longitude)).
		if rm = 1{
			if approx(nLong,tLoAN,1){
				set rm to 2.
			}
			if tIncl > ship:orbit:inclination{
				set hWork to antiNormalVec + (retrograde:vector * .2).		
			}
			else
			{
				set hWork to NormalVec + (retrograde:vector * .2).					
			}
			set tWork to 0.
		}
		if rm = 2{
			rcs on.
			if approx(ship:orbit:inclination,tIncl,.5){
				set rm to 0.
			}
			if apoapsis > sApo * 1.2{
				set rm to 0.
			}
			if tIncl > ship:orbit:inclination{
				set hWork to antiNormalVec + (retrograde:vector * .2).		
			}
			else
			{
				set hWork to NormalVec + (retrograde:vector * .2).					
			}
			set tWork to setThrottle(ship:orbit:inclination,tIncl,.01).
		}
		checkStage().
		set tLock to tWork.
		set hLock to hWork.
		eTime().
		print "Adjust inclination  " at (1,1).
		print "Our Lng: " + round(nLong,2) + "  " + round(ship:orbit:inclination,2) + "  " at (1,13). 
		print "Tgt Lng: " + round(tLoAN,2) + "  " + round(tIncl,2) + "  " at (1,14). 
	}
	lock throttle to 0.
	lock steering to hLock.
	clearscreen.
	return true.
}