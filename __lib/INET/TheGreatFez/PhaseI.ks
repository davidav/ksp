clearscreen.
set thrust to 0.
lock steering to prograde.
lock throttle to thrust.
// Calculate the required Delta-V.
// The Insertion burn distance and Final Apoapsis for this burn were calculated on MatLab.
// The Calculated Final Periapsis on the Mun is around 50km.
set Ra to 1.2*(10^7).
set Rp to (apoapsis+periapsis)/2+600000.
set GM to 3.5316*(10^12).
set e to (Ra-Rp)/(Ra+Rp).
set a to (Ra+Rp)/2.
set h to (GM*a*(1-(e^2)))^.5.
set Vp to h/Rp.
set Va to h/Ra.
set Vcir to (GM/Rp)^.5.
set dV to Vp-Vcir.
set target to "Directly Below Kerbin".
set LAUNCH to 1.229146628119515*(10^7).
set x to 0.
set y to 0.
wait 10.
set diff to 1.
set warp to 4.
print "Warp to Insertion Burn point".
// Warp until directly under the Mun. This is to make sure we are at least past the insertion point.
until diff > 0 {
	set D1 to target:distance.
	wait .1.
	set D2 to target:distance.
	set diff2 to LAUNCH-D2.
	set diff to D1-D2.
	}
print "Relative Speed" at (0,1).
print "Diff. from Insertion Burn" at (0,2).
until x = 1 {
	set D1 to target:distance.
	wait .1.
	set D2 to target:distance.
	set diff2 to LAUNCH-D2.
	set diff to D1-D2.
	print diff + "      " at (26,1).
	print diff2 + "     " at (26,2).
	if diff > 0 AND diff2 < (-200000) AND y = 0{
		set warp to 3.
		set y to 1.
		}
	if diff > 0 AND diff2 > (-100000) AND y = 1{
		set warp to 1.
		set y to 2.
		}
	if diff > 0 AND diff2 > (-30000) AND y = 2{
		set warp to 0.
		set y to 3.
		print "Preparing for Burn" at (0,3).
		}
	if diff2 > (-2000) AND y = 3 {
		set x to 1.
		}
	}
clearscreen.
print "Burn to Mun Intercept" at (0,0).
print "Orbital Speed" at (0,1).
print "Desired Speed" at (0,2).
print "Current Apoapsis" at (0,3).
print "Desired Apoapsis" at (0,4).
print Vp at (20,2).
print Ra-600000 at (20,4).
set y to .5.
until Vp-V < 0 {
	set thrust to x.
	set vec to velocity:orbit.
	set Vx to vec:x.
	set Vy to vec:y.
	set Vz to vec:z.
	set V to ((Vx^2)+(Vy^2)+(Vz^2))^.5.
	if stage:liquidfuel = 0 {
		stage.
		}
	if (Vp-V) > 100  AND y < 1{
		set x to 1.
		set y to y+1.
		}
	if (Vp-V) < 150  AND y < 2{
		set x to (mass*10)/maxthrust.
		set y to y+1.
		}
	if (Vp-V) < 20 AND y < 3{
		set x to (mass*1)/maxthrust.
		set y to y+1.
		}
	if (Vp-V) < 2 AND y < 4{
		set x to (mass*.1)/maxthrust.
		set y to y+1.
		}
	if apoapsis > (Ra-600000) {
		break.
		}
	print V at (20,1).
	print apoapsis at (20,3).
	}.
set thrust to 0.
clearscreen.
print "Warp to SOI Intercept".
set x to 0.
until x = 1 {
	if body = "Kerbin" {
		set warp to 5.
		}
	if body = "Mun" {
		set warp to 0.
		set x to 1.
		}
	}
set warp to 0.
print "End of Phase I".
wait 3.