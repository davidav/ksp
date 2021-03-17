clearscreen.
print "Begin Orbital Ascent".
set FINAL to 100000.
lock steering to up.
lock throttle to thrust.
wait 1. set thrust to 1.
wait 1.
lock steering to up + R(0,-89,0).
toggle AG3.

set x to 0.
until apoapsis > FINAL {
	if apoapsis > .9*FINAL AND x = 0{
		set thrust to (10*mass)/maxthrust.
		set x to 1.
		}.
	if apoapsis >.99*FINAL AND x = 1 {
		set thrust to mass/maxthrust.
		}.
	if apoapsis > FINAL {
		set thrust to 0.
		}.
	}.
set thrust to 0.

//Calculate circular velocity at apoapsis altitude
set x to 1.
set GM to 6.5138398*(10^10).
set r to apoapsis+200000.
set vcir to (GM/r)^.5.
set v to 0.
set per to periapsis+200000.
set a to (r+per)/2.
set e to (r-per)/(r+per).
set h to (GM*a*(1-(e^2)))^.5.
set Va to h/r.
set ar to (Va^2)/r.
set g to GM/(r)^2.
set W to mass*(g-ar).
set theta to arcsin(W/maxthrust).
wait 2.

// Warp!
print "Warp to Apogee".
print theta.
set warp to 4.
wait until eta:apoapsis < 1000.
set warp to 3.
wait until eta:apoapsis < 50.
set warp to 0.
lock steering to heading 90 by theta.
clearscreen.

// Waiting on apoapsis arrival.
print "Vertical Speed" at (0,1).
until verticalspeed < 0 {
	print verticalspeed at (20,1).
	print "T-minus " + eta:apoapsis + " to Apoapsis" at (0,0).
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
set Vo to 0.
set z to 0.
set x to 1.
until vcir-Vo < .001 {
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
	if (Vcir-Vo) < 100  AND y < 1{
		set err to 4.
		set A to 10.
		set y to y+1.
		}.
	if (Vcir-Vo) < 10 AND y < 2{
		set err to 5.
		set A to 1.
		set y to y+1.
		}.
	if (Vcir-Vo) < 1 AND y < 3{
		set err to 7.
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
print "Craft is now in Parking Orbit. Begin Phase V" at (0,3).
wait 5.