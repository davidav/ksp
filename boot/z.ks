CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
clearscreen.


set pos to SHIP:GEOPOSITION:LNG.
set pos1 to pos+60.
print "pos "+ pos1.










// function calculatingAngleToOrbit{
//     parameter altOrbit.
// 	set radiusOrbit to SHIP:Body:Radius + altOrbit.
// 	set A1 to (Ship:Body:radius + ship:altitude + radiusOrbit)/2.
// 	set A2 to radiusOrbit.
// 	set requestAngle to 180*(1 - ((A1^3)/(A2^3))^1.5).
// 	return requestAngle.
// }
// set angle to calculatingAngleToOrbit(100).
// print "angle "+ angle.
// switch to 0.