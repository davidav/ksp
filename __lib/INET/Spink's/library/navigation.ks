//navigation.ks
@lazyglobal off.
require("control.ks").
require("lib_circle_nav.ks").

global radialVec is vxcl(prograde:vector,up:vector).
global normalVec is vcrs(ship:velocity:orbit,-body:position).
global antiNormalVec is vcrs(ship:velocity:orbit,body:position).

function orbitable{
	parameter tName.
	local vessels is list().
	list targets in vessels.
	for vs in vessels{
		if vs:name = tName{
			return vessel(tName).
		}
	}
	return body(tName).
}
function lng2deg{
	parameter lng.
	return abs(mod(lng - 360,360)).
}
function targetAngle{
	parameter tObject.
	return mod(lng2deg(tObject:longitude) - lng2deg(ship:longitude) + 360,360).
}
function getIntercept{
	parameter tObject.
	parameter tAngle.
	local tPrd is tObject:orbit:period.
	local tDps is tprd/360.
	local iPrd is getPeriod(tObject:orbit:apoapsis + 210000,ship:apoapsis).
	local lAngle is (iprd/2)/tDps.
	return lng2deg(180 + tAngle - lAngle). 
}
function intercept{
	parameter tObject.
	parameter tOffset.
	local iAngle is getIntercept(tObject,tOffset).
	print "Wating for launch window" at (1,5).
	print "Target Phase : " + round(targetAngle(tObject)) + " " at (1,8).
	print "Lead Angle  : " + round(getIntercept(tObject,tOffset)) + " " at (1,9).
	if approx(iAngle,targetAngle(tObject),.25){
		return true.
	}
}