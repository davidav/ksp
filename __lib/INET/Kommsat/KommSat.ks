function AlignToSun {
  lock steering to lookdirup(north:vector,Sun:position) + R(0,0,90).
}

function warpfor {
// вспомогательная функция, проматывает время на варпе
// warp:xTime    (0:1) (1:5) (2:10) (3:50) (4:100) (5:1000) (6:10000) (7:100000)
  parameter dt.
  set t1 to time:seconds + dt.
  if dt < 0 {
    print "WARNING: wait time " + round(dt) + " is in the past.".
  }
  until time:seconds >= t1 {
    set warp to round( log10( 0.356*(t1 - time:seconds) ) * 2 ).
    wait 0.01.
  }
}

function exenode {
  local nd to nextnode. //nextnode возвращает ближайший узел манёвра
  local done to False.
  
  // оцениваем время манёвра
  local g0 to Kerbin:mu/Kerbin:radius^2.
  list engines in el.
  local ispeff to 0.
  local ff to 0. // fuel flow - потребление топлива
  local tt to 0. // total thrust - тяга
  for e in el {
    set ff to ff + e:availablethrust/max(e:isp,0.01)/g0.
    set tt to tt + e:availablethrust.
  }
  if tt = 0 { 
    print "ERROR: No active engines!".
    set ship:control:pilotmainthrottle to 0.
    return.
  }
  set ispeff to tt/ff.
  set dob to mass/ff*(1 - constant:e^(-nd:deltav:mag/ispeff)).
  print "Burn duration: " + round(dob) + " s, Max acc: " + round(ship:availablethrust/(mass - dob*ff),1) + " m/s^2 ".
  
  warpfor(nd:eta-dob/2-60).
  sas off.
  print "Turning ship to burn direction.".
  local np to lookdirup(nd:deltav,up:vector).
  lock steering to np.
  wait until vang( np:vector,facing:vector ) < 0.05 and ship:angularvel:mag < 0.05.
  
  warpfor(nd:eta-dob/2-7).
  print "Burn start " + round(dob/2) + " s before node.".
  lock throttle to 0.
  lock steering to lookdirup(nd:deltav,up:vector).
  
  wait until nd:eta <= dob/2.
  local dv0 to nd:deltav. // запомнили начальное направление манёвра
  until done {
    lock throttle to min( nd:deltav:mag * mass / ship:availablethrust, 1).
    // прерывание, если выполнили лишнего
    if vdot(dv0, nd:deltav) < 0 {
        print "Overshoot, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        lock throttle to 0.
        break.
    }
    if nd:deltav:mag < 0.1 {
        wait until vdot(dv0:normalized, nd:deltav) < 0.01.
        lock throttle to 0.
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s ".
        set done to True.
    }
  }
  unlock steering.
  set ship:control:pilotmainthrottle to 0.
  remove nd.
  unlock throttle.
}

function transfernode {
  parameter targetperiod is 3600.
  
  local newsma to ( targetperiod / 2 / constant:pi * body:mu^0.5 )^(2.0/3.0).
  
  local r0 to body:radius + (apoapsis + periapsis)/2.
  local v0 to velocity:orbit:mag.
  
  // рассчитываем манёвр апоцентра
  local a1 to (newsma + r0)/2. // большая полуось переходной орбиты
  local Vpe to sqrt( body:mu * ( 2/r0 - 1/a1 ) ).

  set deltav to Vpe - v0.         
  print "Transfer burn: " + round(v0) + " -> " + round(Vpe) + "m/s".
  set nd to node(time:seconds + 180, 0, 0, deltav). // три минуты должно хватить на выполнение
  add nd.
}

function aponode {
  parameter newapsis is apoapsis.
  
  print "Maneuver at apoapsis. Changing orbit: ".
  print round(periapsis/1000,1) + "x" + round(apoapsis/1000,1) + " km -> " + round( min(apoapsis,newapsis)/1000,1) + "x" + round( max(apoapsis,newapsis)/1000,1) + " km ".

  local Vnow to velocity:orbit:mag.
  local Rnow to body:radius + altitude.      
  local Ra to body:radius + apoapsis.
  local Va to sqrt( Vnow^2 + 2*body:mu*(1/Ra - 1/Rnow) ). // скорость в апоцентре
  
  // расчет будущей орбиты
  local a1 to (newapsis + apoapsis)/2 + body:radius. // новая большая полуось
  local v1 to sqrt( body:mu * (2/Ra - 1/a1 ) ).
  
  set deltav to v1 - Va.
  print "Burn at apoapsis: " + round(Va) + " -> " + round(v1) + "m/s".
  set nd to node(time:seconds + eta:apoapsis, 0, 0, deltav).
  add nd.
  print "Apoapsis node created.".
}

function TrimPeriod {
  parameter WantedPeriod.
  parameter epsilon is 5e-8.
  
  local dt to  WantedPeriod - orbit:period.
  lock steering to velocity:orbit*dt.
  list engines in elist.
  local thrustlim to list().
  // ставим всем двигателям тягу на ускорение 0.5 м/с^2
  from { local i to 0. } until i=elist:length step { set i to i+1. } do {
    thrustlim:add(elist[i]:thrustlimit).
    set elist[i]:thrustlimit to 0.5*ship:mass/ship:availablethrust.
  }
  wait until vang(facing:vector,velocity:orbit*dt) < 1.
  until abs( (orbit:period - WantedPeriod) / WantedPeriod ) < epsilon {
    lock throttle to min( 1, max( abs( (orbit:period - WantedPeriod) / WantedPeriod - epsilon ), 0.1 ) ).
    wait 0.01.
  }
  lock throttle to 0.
  // восстанавливаем тягу как было
  from { local i to 0. } until i=elist:length step { set i to i+1. } do {
    set elist[i]:thrustlimit to thrustlim[i].
  }
  print "Target period: " + round(WantedPeriod,1) + "s, Delta: " + (orbit:period - WantedPeriod) + " s ".
  set ship:control:pilotmainthrottle to 0.
  unlock throttle.
}

function nextmode {
  parameter newmode is satmode+1.
  set satmode to newmode.
  log "set satmode to " + newmode + "." to "mode.ks".
  AlignToSun().
}

function satprogram {
  if satmode = 0 {
    print "Waiting for LV separation.".
    wait until exists("released.txt").
    print "LV separation confirmed. ".
    wait 20.
    nextmode().
  }
  if satmode = 1 {
    print "Aligning for optimal solar panel performance.".
    AlignToSun().
    wait 15.
    stage.
    nextmode().
  }
  if satmode = 2 {
    transfernode(7200).
    nextmode().
  }
  if satmode = 3 {
    exenode().
    nextmode().
  }
  if satmode = 4 {
    wait 10.
    aponode(apoapsis).
    nextmode().
  }
  if satmode = 5 {
    exenode().
    nextmode().
  }
  if satmode = 6 {
    TrimPeriod(7200).
    nextmode().
  }
  if satmode = 7 {
    set dish to ship:partsnamed("HighGainAntenna5")[0].
    set d to dish:getmodule("ModuleRTAntenna").
    d:doevent("activate").
    d:setfield("target", Mun).
    print "Satellite deployed to operational orbit.".
    nextmode().
  }  
  until false AlignToSun().
}
