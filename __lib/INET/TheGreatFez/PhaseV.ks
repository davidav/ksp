clearscreen.
// Calculation of the Launch Angle (Beta) and Delta-V of Hyperbolic Escape Trajectory were done on MatLab
// Final periapsis on Kerbin will be calculated to roughly 30,000m but it normally ends up being much lower.
set LAUNCH to 21.877991837556678.
set dV to 2.859013122877032*(10^2).
set vorbit to velocity:orbit.
set vx to vorbit:x.
set vy to vorbit:y.
set vz to vorbit:z.
set Vo to ((vx^2)+(vy^2)+(vz^2))^.5.
set Vfinal to Vo + dV.
set thrust to 0.
lock throttle to thrust.
lock steering to heading 90 by 0.
wait 5.
// Warp!
clearscreen.
print "Warp to Escape Burn Point".
set warp to 4.
wait until longitude < 0.
wait until longitude > 0.
set warp to 3.
wait until longitude > 15.
set warp to 2.
wait until longitude > 18.
set warp to 0.
wait until longitude > LAUNCH.


print "Burn for Mun Escape" at (0,0).
print "Orbital Speed" at (0,1).
print "Desired Speed" at (0,2).
print Vfinal at (20,2).
set y to .5.
set V to 0.
until Vfinal-V < 0 {
	set thrust to x.
	set vec to velocity:orbit.
	set Vx to vec:x.
	set Vy to vec:y.
	set Vz to vec:z.
	set V to ((Vx^2)+(Vy^2)+(Vz^2))^.5.
	if stage:liquidfuel = 0 {
		stage.
		}
	if (Vfinal-V) > 100  AND y < 1{
		set x to 1.
		set y to y+1.
		}
	if (Vfinal-V) < 150  AND y < 2{
		set x to (mass*10)/maxthrust.
		set y to y+1.
		}
	if (Vfinal-V) < 20 AND y < 3{
		set x to (mass*1)/maxthrust.
		set y to y+1.
		}
	if (Vfinal-V) < 2 AND y < 4{
		set x to (mass*.1)/maxthrust.
		set y to y+1.
		}
	print V at (20,1).
	}.
set thrust to 0.
clearscreen.
print "Warp to SOI Intercept".
set x to 0.
until x = 1 {
	if body = "Mun" {
		set warp to 5.
		}
	if body = "Kerbin" {
		set warp to 0.
		set x to 1.
		}
	}
set warp to 0.
print "End of Phase V".
wait 3.