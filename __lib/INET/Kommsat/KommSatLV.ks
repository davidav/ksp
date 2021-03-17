function VertAscent {
  lock steering to heading(90,90).
}

function CapTWR {
  parameter maxTWR is 3.0.
  local g0 to Kerbin:mu/Kerbin:radius^2. // TWR считается относительно веса на уровне моря
  lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ). // без max() будет деление на ноль при пропадании тяги
}

function GravityTurn {
  parameter vstart. // скорость, при которой начинается разворот
  parameter AP45 is apoapsis. // апоцентр при тангаже 45 градусов
  parameter APstop is 60000. // апоцентр, по достижении которого ракета ложится горизонтально
  parameter v45 is 500. // скорость, при которой угол тангажа должен быть 45 градусов
  
  local vsm to velocity:surface:mag. // величина скорости относительно поверхности
  local pitch to 0.
  if ( vsm < v45 ) {
    set pitch to 90 - arctan( (vsm - vstart)/(v45 - vstart) ). // линейно менять тангаж от скорости оказалось плохо, по арктангенсу довольно неплохо получается
  }
  else {
    set pitch to max(0, 45*(apoapsis - APstop) / (AP45 - APstop) ). // линейно меняем тангаж, на APstop укладываем ракету горизонтально
  }
  lock steering to heading( 90, pitch ).
  // возложим на kOS функции Kerbal Engineer
  print "Apoapsis: " + round( apoapsis/1000, 2 ) + " km    " at (0,30).
  print "Periapsis: " + round( periapsis/1000, 2 ) + " km    " at (0,31).
  print " Altitude: " + round( altitude/1000, 2 ) + " km    " at (24,30).
  print " Pitch: " + round( pitch ) + " deg  " at (24,31).
}

function circularize {
  local th to 0. // в этой переменной будет необходимый уровень тяги
  local Vcircdir to vxcl( up:vector, velocity:orbit ):normalized. // направление круговой скорости такое же, как у горизонтальной компоненты орбитальной скорости
  local Vcircmag to sqrt(body:mu / body:position:mag). // mu - это гравитационный параметр планеты, произведение массы на гравитационную постоянную
  local Vcirc to Vcircmag*Vcircdir.
  local deltav to Vcirc - velocity:orbit.
  
  // начинаем прожиг, поворачивая ракету постоянно в сторону маневра
  lock steering to lookdirup( deltav, up:vector).
  wait until vang( facing:vector, deltav ) < 1. // убеждаемся, что прожиг начинается в нужной ориентации
  lock throttle to th.
  until deltav:mag < 0.05 {
    set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
    set Vcircmag to sqrt(body:mu / body:position:mag).
    set Vcirc to Vcircmag*Vcircdir.
    set deltav to Vcirc - velocity:orbit.
    if vang( facing:vector, deltav ) > 5 { 
      set th to 0. // если сильно не туда смотрим, надо глушить двигатель
    }
    else {
      set th to min( 1, deltav:mag * ship:mass / ship:availablethrust ). // снижаем тягу, если приращение скорости нужно небольшое
    }
    wait 0.1.
  }
  set th to 0.
  set ship:control:pilotmainthrottle to 0.
  unlock throttle.
}

function startnextstage {
  // если есть живые двигатели, то делать ничего не будет;
  // в противном случае будет запускать ступени, пока не появится тяга
  until ship:availablethrust > 0 {
    wait 0.5.
    stage.
  }
}

function DumpRocket {
  lock steering to ship:retrograde.
  wait until vang(facing:vector, retrograde:vector) < 5.
  lock throttle to 1.
  wait until apoapsis < 10000.
  lock throttle to 0.
}

function gettoorbit {
  parameter Horb to body:atm:height + 10000.
  parameter GTstart to 1000. // высота начала разворота
  parameter GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
  
  local maxTWR to 2.5.
  // запомним, как ракета стоит на столе, в этом положении взлетаем
  lock throttle to 1.
  local initialpos to ship:facing.
  lock steering to initialpos.
  startnextstage().

  until altitude > GTstart {
    VertAscent().
    startnextstage().
    CapTWR(maxTWR).
    wait 0.01.
  }
  
  // запомним параметры для функции гравиразворота:
  local GTStartSpd to velocity:surface:mag. // при какой скорости начали разворот
  local Apo45 to apoapsis. // какой апоцентр был при тангаже 45 градусов
  local lock pitch to 90 - vang( up:vector, velocity:surface ). // переменная с тем же именем, что и в другой функции
  // т.к. объявлена локально, конфликта имён возникать не должно

  // строим апоцентр
  until apoapsis >= Horb {
    if pitch >= 45 { set Apo45 to apoapsis. } // перестанет обновляться после тангажа 45 градусов - то, что требуется
    GravityTurn(GTStartSpd,Apo45,GTendAP).
    startnextstage().
    CapTWR(maxTWR).
    wait 0.01.
  }
  
  lock throttle to 0.

  // ждём, выхода из атмосферы, после чего сбрасываем ненужный более обтекатель
  lock steering to prograde.
  wait until altitude > body:atm:height.
  print "We are in space. Deploying payload fairing. ".
  stage.
  
  //вблизи апоцентра скругляем
  wait until altitude > apoapsis - 200.
  circularize().

  print "We are in orbit: " + round(apoapsis/1000,2) + "x" + round(periapsis/1000,2) + " km. ".
  wait 5.
  
  print "Deploying antennae.".
  set alist to ship:partsnamed("longAntenna").
  for an in alist {
    set d to an:getmodule("ModuleRTAntenna").
    d:doevent("activate").
  }
  
  // чтобы при торможении не попасть выхлопом в спутник, ракета разворачивается перпендикулярно
  lock steering to up.
  wait 10.
  
  print "Releasing payload.".
  create("sat1:/released.txt").
  stage.
  
  wait 10.
  DumpRocket().
  set ship:control:pilotmainthrottle to 0.
  set ship:control:neutralize to True. // отпустить управление
}

gettoorbit().
