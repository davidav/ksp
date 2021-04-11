CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
set SatelliteAngle to 45.
set KSCLNG to SHIP:GEOPOSITION:LNG+SatelliteAngle.
set DayLen to SHIP:Body:ROTATIONPERIOD.
set KerbinMu to SHIP:Body:MU.
set ksoR to (sqrt(KerbinMu)*DayLen/(2*constant():pi))^(2/3).
set ksoH to ksoR - SHIP:Body:Radius.
print "KSC LNG: " + Round(KSCLNG,2).
print "KSC LAT: " + Round(SHIP:GEOPOSITION:LAT,2).
print "Day Len: " + Round(DayLen,2).
print "Kerb Stat Orb R: " + Round(ksoR,2).
print "Kerb Stat Orb H: " + Round(ksoH,2).
Wait 5.
print "3".
Wait 1.
print "2".
Wait 1..
print "1".
Wait 1.
print ">>>START<<<".
STAGE.
LOCK Throttle to 1.
SET MaxFuel to STAGE:SOLIDFUEL.
set OLDLAT to 0.
UNTIL STAGE:SOLIDFUEL<1
{
clearscreen.
LOCK Throttle to 0.
print "Apo: " + Round(Apoapsis).
print "Pitch: " + Round(90-VANG(ship:facing:forevector,up:vector),2).
print "LAT:" + Round(SHIP:GEOPOSITION:LAT,3).
print "LNG:" + Round(SHIP:GEOPOSITION:LNG,3).
print "Bearing:" + Round(90-VANG(V(0,1,0),VXCL(up:vector,ship:facing:forevector)),3).
	SET LATVEL to SHIP:GEOPOSITION:LAT-OLDLAT.		
    print "LATVEL: " + Round(LATVEL,5).
	LOCK Steering to Heading(90+(SHIP:GEOPOSITION:LAT*100)+(LATVEL*5000), 90-60*(1-STAGE:SOLIDFUEL/MaxFuel)). 
	SET OLDLAT to SHIP:GEOPOSITION:LAT.	
WAIT 0.1.	
}
LOCK Steering to PROGRADE.
WAIT 15.
	STAGE.
WAIT 5.    
    STAGE.
WAIT 20.
STAGE.
UNTIL ETA:Apoapsis<1
{
clearscreen.
print "Apo: " + Round(Apoapsis).
print "ETA:Apo: " + Round(ETA:Apoapsis).
print "Pitch: " + Round(90-VANG(ship:facing:forevector,up:vector),2).
print "LAT:" + Round(SHIP:GEOPOSITION:LAT,3).
print "LNG:" + Round(SHIP:GEOPOSITION:LNG,3).
print "Bearing:" + Round(90-VANG(V(0,1,0),VXCL(up:vector,ship:facing:forevector)),3).
WAIT 1.
If ETA:Apoapsis<15 set kuniverse:timewarp:warp to 0.
}

STAGE.

FROM {local countup is 0.} UNTIL countup = 10 STEP {SET countup to countup + 1.} DO {
    PRINT "..." + countup.
    WAIT 0.3.
    LOCK Throttle to countup/10.    
}

    LOCK Throttle to 1.0.


SET OLDLAT to 0.
set StopBurn to false.
until StopBurn
{
	Set CirkData to ApoBurn. 

	if CirkData[4]<0
		set StopBurn to true.
	else if CirkData[4]<100
		LOCK Throttle to Max(CirkData[4]/100, 0.01).

	SET LATVEL to SHIP:GEOPOSITION:LAT-OLDLAT.		
	LOCK Steering to Heading(90+(SHIP:GEOPOSITION:LAT*250)+(LATVEL*120000), CirkData[0]).
	SET OLDLAT to SHIP:GEOPOSITION:LAT.
	clearscreen.
	print "Fi: "+Round(CirkData[0],2).	
	print "Vh: "+Round(CirkData[1],4).
	print "Vz: "+Round(CirkData[2],4).	
	print "Vorb: "+Round(CirkData[3],4).	
	print "dVh: "+Round(CirkData[4],4).		
	print "DeltaA: "+Round(CirkData[5],4).	
    print "LAT: " + Round(SHIP:GEOPOSITION:LAT,5).
    print "LATVEL: " + Round(LATVEL,5).
}


LOCK Throttle to 0.
Set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
unlock steering.

WAIT 1.

clearscreen.
print "WE'RE ON ORBIT!".
WAIT 5.
print "Apoapsis: " + Round(Ship:Orbit:Apoapsis).
WAIT 1.
print "Periapsis: " + Round(Ship:Orbit:Periapsis).
WAIT 1.
print "Eccentricity: " + Round(Ship:Orbit:Eccentricity,6).
WAIT 1.
print "Inclination: " + Round(Ship:Orbit:Inclination,3).
WAIT 5.
print "Deploy Antenna".

SetDishTarget("HighGainAntenna5",0,"Kerbin").

LOCK Steering TO Heading(90,0).

print "Calculating transfer angle...".
WAIT 10.

UNTIL CheckTransferAngle(ksoR, KSCLNG)
{
	WAIT 1.
	clearscreen.
}

print "Transfer start!".

SET Man_point TO Heading(90,0).
LOCK Steering TO Man_point.
WAIT 5.
UNTIL ORBIT:Apoapsis>ksoH
{
	clearscreen.
	Lock Throttle to min(max(1-orbit:Apoapsis/ksoH, 0.001),1).
    print "Apo: " + Round(Apoapsis).
	print "Target Apo: " + Round(ksoH).	
	print "Apo Delta: " + Round(ksoH-Apoapsis).	
}

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
set Throttle to 0. WAIT 1.

UNTIL (ETA:Apoapsis<50)
{
	clearscreen.
	print "ETA:Apo: " + Round(ETA:Apoapsis).
    If ETA:Apoapsis<100 set kuniverse:timewarp:warp to 0.
	WAIT 1.
}

LOCK Steering TO Heading(90,0).
WAIT 30.
LOCK Throttle to 0.3.
WAIT 1.
set StopBurn to false.
until StopBurn
{
	Set CirkData to ApoBurn.

	if Ship:ORBIT:SEMIMAJORAXIS>ksoR
		set StopBurn to true.
	else if CirkData[4]<100		
		LOCK Throttle to min(Max(1-ORBIT:SEMIMAJORAXIS/ksoR, 0.001),1).

	LOCK Steering to Heading(90, CirkData[0]).
	
	clearscreen.
	print "Fi: "+Round(CirkData[0],2).	
	print "Vh: "+Round(CirkData[1],4).
	print "Vz: "+Round(CirkData[2],4).	
	print "Vorb: "+Round(CirkData[3],4).	
	print "dVh: "+Round(CirkData[4],4).		
	print "DeltaA: "+Round(CirkData[5],4).	
    print "LAT: " + Round(SHIP:GEOPOSITION:LAT,5).
    print "LNG: " + Round(SHIP:GEOPOSITION:LNG,5).
	print "SemiMajor Axis: "+Round(Ship:ORBIT:SEMIMAJORAXIS).	
}
LOCK Throttle to 0.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.


clearscreen.
print "We're KerboStationary!".
WAIT 1.
print "Inclination: " + Ship:Orbit:Inclination.
WAIT 1.
print "PERIOD: " + Ship:Orbit:PERIOD.
WAIT 1.
print "Longitude: " + SHIP:GEOPOSITION:LNG.
WAIT 10.
print "Transfer complete".

WAIT 10.

function CalculateTransferAngle
{
    parameter OrbitA.

	SET A1 to (Ship:Body:radius + ship:altitude + OrbitA)/2.
	SET A2 to OrbitA.
	return 180*(1 - (A1/A2)^1.5).
}

FUNCTION CheckTransferAngle
{
    parameter OrbitA.
    parameter TargetLNG.
	set t_angle to CalculateTransferAngle(OrbitA).
	set cur_angle to TargetLNG-SHIP:GEOPOSITION:LNG.
	if cur_angle<0
	{
		set cur_angle to cur_angle+360.
	}	
	print "Transfer angle: " + t_angle.
	print "Current angle: " + cur_angle.
	if ABS(cur_angle - t_angle) < 6
		set kuniverse:timewarp:warp to 0.
	return ABS(cur_angle - t_angle) < 3.
}


FUNCTION ApoBurn
{
	set Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.
	set Vz to ship:verticalspeed.
	set Rad to ship:Body:radius+ship:altitude.
	set Vorb to sqrt(ship:Body:Mu/Rad). 
	set g_orb to ship:Body:Mu/Rad^2. 
	set ThrIsp to EngThrustIsp.
	if Throttle>0
		set AThr to ThrIsp[0]*Throttle/(ship:mass).
	else
		set AThr to ThrIsp[0]/(ship:mass).
	set ACentr to Vh^2/Rad.
	set DeltaA to g_orb-ACentr-Max(Min(Vz,2),-2).
	set Fi to arcsin(DeltaA/AThr). 
	set dVh to Vorb-Vh. 
	RETURN LIST(Fi, Vh, Vz, Vorb, dVh, DeltaA).
}


FUNCTION EngThrustIsp
{

  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
  set ens_fuelflow to 0.

  list engines in myengines.
	

  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }

  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
    set ens_fuelflow to ens_fuelflow + en:fuelflow.
	}

  RETURN LIST(ens_thrust, ens_isp/ens:length, ens_fuelflow).
}


FUNCTION SetDishTarget
{
PARAMETER DishBlockName. // Принимаем имя антенны
PARAMETER BlockIndex. 
PARAMETER DishTarget. //Цель для антенны.
SET p TO SHIP:partsnamed(DishBlockName)[BlockIndex].
SET m TO p:GETMODULE("ModuleRTAntenna").
m:DOEVENT("Activate").
m:SETFIELD("target", DishTarget).
}
