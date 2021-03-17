//script: tko.ks
//craft: TKO.craft
//mods for craft: KOS/MechJeb
//purpose: bring two tourist into orbit and back
//by maculator

//preparation
clearscreen.
set terminal:width to 25.
set terminal:height to 14.
print "preparing |" at (0,0).	//just for the looks
wait 0.5.
print "preparing /" at (0,0).
wait 0.5.
print "preparing -" at (0,0).
wait 0.5.
print "preparing \" at (0,0).
wait 0.5.
print "preparing |" at (0,0).
wait 0.5.
print "preparing complete".
lock steering to up.
lock throttle to 1.
set safety to 0.				//prevents staging through whole rocket
set angle to 0.					//adjusts steering while gravityturn
set enjoying to 0.				//keeps track of tourists enjoyment of orbit
set countdown to 5.				//keeps track of countdown
set lpad to ship:geoposition.	//storing the koords of the launchpad
//launch
until countdown = 0 {
	print "countdown: " + countdown at (0,1).
	set countdown to countdown - 1.
	wait 1.
}
stage.
print "liftoff!     ".
print "STEP 1/3: ASCENT".
set step to "ascent".			//enters the LOOP
//>>LOOP<< ascent, circulation and staging
until step = "decent" {
	//LOOP_PART_1: >>ASCENT<<
	if step = "ascent" {
		wait until alt:radar > 500.
		if alt:radar < 9000 {
			lock steering to up + r(0,-5,0).
			wait 0.005.
		}
		//gravityturn
		else if alt:radar > 9000 {
			if apoapsis < 60000 {
				set angle to max(5,90*(1-ship:apoapsis/60000)).
				lock steering to heading (90,angle*1.02).
				wait 0.005.
			}
			//pushing apoapsis to 71000
			else if apoapsis > 60000 {
				if apoapsis < 72000 {
					lock steering to heading (90,0).
					wait 0.005.
				}
				//warping to circulation burn
				else if apoapsis > 72000 {
					lock throttle to 0.
					print "warping physics".
					set kuniverse:timewarp:mode to "physics".
					wait 0.5.
					set warp to 4.
					wait until eta:apoapsis < 20.
					set warp to 0.
					print "STEP 2/3: CIRCULATION".
					set step to "circulation".
				}
			}
		}
	}
	//LOOP_PART_"2: >>CIRCULATION<<
	else if step = "circulation" {
		//burning
		if eta:apoapsis < 15 {
			lock throttle to max(0.07,(((70000-max(50000,periapsis))/200)/(eta:apoapsis*eta:apoapsis))).
		}
		//coasting
		else if eta:apoapsis > 305-(14*((apoapsis-max(50000,periapsis))/1000)) and periapsis < 70000 {
			lock throttle to 0.
		}
		//finishing
		else if periapsis > 70000 {
			lock throttle to 0.
			toggle lights.				//the fun part
			set enjoying to 1.
			until enjoying = 11 {
				print "enjoying orbit " + enjoying * 10 + "%" at(0,5).
				wait 1.
				set enjoying to enjoying +1.
			}
			toggle lights.
			print "enjoyed orbit!".
			wait 1.
			set step to "decent".
		}
	}
	//LOOP_PART_3: >>STAGING<<
	if stage:solidfuel < 1 and safety < 1 {
		stage.
		set safety to safety + 1.

	}
	//LOOP_MAINTENANCE: preventing lag
	wait 0.005.
}
//>>DECENT<<
//deorbiting
print "STEP 3/3: DECENT".
lock steering to retrograde.
wait 5.
print "deorbiting".
lock throttle to 1.
wait until ship:liquidfuel < 1.
wait 1.
stage.
print "warping rails".
//warping rails
set kuniverse:timewarp:mode to "rails".
wait 1.
set warp to 2.
wait until alt:radar < 70000.
set warp to 0.
wait 0.5.
print "warping physics".
//warping physics
set kuniverse:timewarp:mode to "physics".
wait 0.5.
set warp to 4.
print "reentering".
//reentering
wait until alt:radar <20000.
unlock steering.
//killing warp
wait until alt:radar < 100.
set warp to 0.
wait until alt:radar < 1.
print "touchdown!".
//distance to launchpad for reference
print round((lpad:distance)/1000) + "km away from KSC!".
wait 2.