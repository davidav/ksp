clearscreen.
set SOI to 2429559.1.
print "Warp to Mun Periapsis".
set warp to 5.
wait until eta:periapsis < 2000.
set warp to 4.
wait until eta:periapsis < 500.
set warp to 3.
wait until eta:periapsis < 50.
set warp to 0.
lock steering to retrograde.
clearscreen.
print "Burn for Mun Capture".
wait until eta:periapsis < 1.
lock throttle to 1.
wait until apoapsis > 0.
wait until apoapsis < .5*SOI.
lock throttle to 0.
set thrust to 0.
lock throttle to thrust.
// Calculate Delta-V to circularize orbit
set GM to 6.5138398*(10^10).
set Rp to periapsis+200000.
set vcir to (GM/Rp)^.5.
set Ra to apoapsis+200000.
set a to (Ra+Rp)/2.
set e to (Ra-Rp)/(Ra+Rp).
set h to (GM*a*(1-(e^2)))^.5.
set Vp to h/Rp.
set ar to (Va^2)/Rp.
set g to GM/(Rp)^2.
set W to mass*(g-ar).
set theta to arcsin(W/maxthrust).
wait 5.
// I do two seperate burns to help make the burns more efficient
// It is more efficient to burn at Periapsis
// Warp!
print "Warp to Periapsis".
print theta.
set warp to 5.
wait until eta:periapsis < 2000.
set warp to 4.
wait until eta:periapsis < 500.
set warp to 3.
wait until eta:periapsis < 50.
set warp to 0.
lock steering to heading 270 by theta.
clearscreen.

// Waiting on periapsis arrival.
print "Vertical Speed" at (0,1).
until verticalspeed > 0 {
	print verticalspeed at (20,1).
	print "T-minus " + eta:periapsis + " to periapsis" at (0,0).
	}.
clearscreen.

// Burn to circularize, theta is used to maintain the apogee infront of the craft
print "Burn to Circularize Orbit" at (0,0).
print "Vertical Speed" at (0,1).
print "Orbital Speed" at (0,2).
print "Vcir" at (0,3).
print vcir at (20,3).
print "Theta" at (0,4).
print theta at (20,4).
set y to .5.
set Vo to 1000.
set z to 0.
set x to 1.
until Vo-vcir < .001 {
	set thrust to x.
	set vorbit to velocity:orbit.
	set Vox to vorbit:x.
	set Voy to vorbit:y.
	set Voz to vorbit:z.
	set Vo to ((Vox^2)+(Voy^2)+(Voz^2))^.5.
	set ar to (Vo^2)/r.
	set W to mass*(g-ar).
	
	if y = .5 {
		set err to .75.
		set error to 1-(err*verticalspeed).
		set theta to arcsin(W/maxthrust).
		set theta to theta*error.
		}.
	if stage:liquidfuel = 0 AND z < 1{
		stage.
		set z to 1.5.
		}.
	if (Vo-vcir) < 100  AND y < 1{
		set err to 4.
		set A to 10.
		set y to y+1.
		}.
	if (Vo-vcir) < 10 AND y < 2{
		set err to 5.
		set A to 1.
		set y to y+1.
		}.
	if (Vo-vcir) < 1 AND y < 3{
		set err to 6.
		set A to .1.
		set y to y+1.
		}.
	if y > 1 {
		set error to 1-(err*verticalspeed).
		set C to mass*A.
		set B to ((W^2)+(C^2))^.5.
		set x to B/maxthrust.
		if x > 1 {
			set x to 1.
			}.
		set theta to arctan(W/C).
		set theta to theta*error.
		}.
	print verticalspeed at (20,1).
	print Vo at (20,2).
	print theta at (20,4).
	}.
lock throttle to 0.
clearscreen.
// DONE!

set e to (apoapsis-periapsis)/(apoapsis+periapsis).
print "Eccentricity" at (0,0). print e at (20,0).
set avg to (apoapsis+periapsis)/2-FINAL.
set error to avg/FINAL*100.
print "Error " + error + "%" at (0,1).
print "Craft is now in stable circular orbit around Mun" at (0,3).
print "This ends Phase II, on to Phase III" at (0,4). 
wait 10.