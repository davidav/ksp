function SetLinkTarget{
    parameter AntName. // Принимаем имя антенны
    parameter BlockIndex. 
    parameter LinkTarget. //Цель для антенны.
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", LinkTarget).
}


		else if cyclogram = 6{
 		DisplayCyclogram ("COMMUNICATION").           
        	SetLinkTarget("mediumDishAntenna",0,"MOLNIYA_60").//mediumDishAntenna
		wait 1.
		print "ANTENNA #1 IS TUNED TO MOLNIYA_60" at(5,5).
		wait 1.		
		SetLinkTarget("mediumDishAntenna",1,"MOLNIYA_180").//HighGainAntenna5
		print "ANTENNA #2 IS TUNED TO MOLNIYA_180" at(5,7).
        	wait 1. 	
       		SetLinkTarget("mediumDishAntenna",2,"MOLNIYA_300").//mediumDishAntenna
		wait 1.
        	print "ANTENNA #1 IS TUNED TO MOLNIYA_300" at(5,5).
		wait 1.		       
      		
        set cyclogram to 4.
    }

-----------------------------------
//Взятие науки - 4 материала, температура, давление
function Science{
    parameter DeviceName.
    parameter BlockIndex. 
SET P TO SHIP:PARTSNAMED(DeviceName)[BlockIndex].
SET M TO P:GETMODULE("ModuleScienceExperiment").
M:DEPLOY.
}

	else if cyclogram = 6{
 		DisplayCyclogram ("SCIENCE").           
        Science("GooExperiment", 0).
		wait 1.
		print "GooExperiment #1" at(5,5).
		wait 1.		
		Science("GooExperiment", 1).
		print "GooExperiment #2" at(5,6).
        wait 1. 	
       Science("GooExperiment", 2).
		wait 1.
        print "GooExperiment #3" at(5,7).
		wait 1.		
		Science("GooExperiment", 3).
		print "GooExperiment #4" at(5,8).
        wait 1.
		Science("sensorThermometer", 0).
		print "Thermometer #1" at(5,9).
        wait 1.
		Science("sensorBarometer", 0).
		print "Barometer #1" at(5,10).
        wait 1.
        
        set cyclogram to 7.
    }

==============================================
        if cyclogram = 7 {
		DisplayCyclogram ("FLIGHT_ORBIT").        
        wait 10.    
        until (FligthOrbit-1) = 0{
            set FligrhOrbit to FligrhOrbit-1.
            wait 1.
            print "LEFT TIME ORBIT: " + FligrhOrbit at(5,7).
            LOCK Steering to RETROGRADE.             
        }
		set cyclogram to 8.     
    }
======================================== ====   
    if cyclogram = 8 {
		DisplayCyclogram ("BACK").          
        LOCK Steering to RETROGRADE. 
        lock throttle to 1.
		until SHIP:PERIAPSIS < 37000 {
            wait 0.5.        
        }
        lock throttle to 0.        
        
		set cyclogram to 9.             
    }
=================================================   
    
    
    if cyclogram = 9 {
		DisplayCyclogram ("LIFT").       
        until alt:radar < 2500{
            wait 0.5.          
        }
        stage. //парашут
    
		set cyclogram to 0.             
    } 
==============================================   
    
set target to vessel("KWF-1a").//Устанавливаем цель
set RequestDistance to 280000.//Требуемая дальность
    
      if cyclogram = 1{
		DisplayCyclogram ("WAITING...").
        lock DistanceTarget to (Target:POSITION-SHIP:POSITION):MAG.
        until DistanceTarget < RequestDistance{
            If (DistanceTarget<(RequestDistance+20000)) set kuniverse:timewarp:warp to 0.
            print "Distance Target: " +DistanceTarget at(5,5).
            wait 1.            
        }
        set cyclogram to 2.
    } 
  ====================================================
  
  set SatelliteAngle to 10.
  
  function CheckMunAngle{
    set VecS to Ship:position-body("Kerbin"):position.
    set VecM to body("Mun"):position-body("Kerbin"):position.
    set VecHV to VXCL(ship:up:vector, ship:velocity:orbit).
    set VecSM to body("Mun"):position-Ship:position.
    set A1 to (2*body("Kerbin"):radius + body("Mun"):altitude + ship:altitude)/2.
    set A2 to body("Kerbin"):radius+body("Mun"):altitude.
    set m_angle to 180*(1 - (A1/A2)^1.5).
    set req_angle to m_angle+SatelliteAngle.
    set cur_angle to VANG(VecM,VecS).
    if VANG(VecHV,VecSM)>90
        set cur_angle to -cur_angle.
    print "Munar angle: " + m_angle at (5,4).
    print "Request angle: " + req_angle at (5,5).
    print "Current angle: " + cur_angle at (5,6).
    return ABS(cur_angle - req_angle) < 3.
}
  
  
        else if cyclogram = 6{
		DisplayCyclogram ("CALCULATING ...").
		wait 3.
        LOCK Steering to PROGRADE.
        UNTIL CheckMunAngle{        
			WAIT 1.
        }
		set cyclogram to 7.
	}    
    else if cyclogram = 7{
 		DisplayCyclogram ("TRANSFER").       
		lock steering to heading(90,0).
		wait 5.
        set the_mun to body("Mun").
		until orbit:apoapsis>the_mun:Altitude {
			lock throttle to min(2*max(1-orbit:apoapsis/the_mun:Altitude, 0.001),1).
            nextstage().
			print "Apo: " + Round(Apoapsis) at(5,7).
			print "Target Apo: " + Round(the_mun:Altitude) at(5,8).
			print "Apo Delta: " + Round(the_mun:Altitude-Apoapsis) at(5,9).	
		}
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set throttle to 0. 
		wait 1.
		set cyclogram to 10.
	}
    else if cyclogram = 8{
 		DisplayCyclogram ("FREE_FLIGHT").        
		until (ETA:Apoapsis<50){
			print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,4).
			If ETA:Apoapsis<100 set kuniverse:timewarp:warp to 0.
			wait 1.
		}
        set cyclogram to 9.
	}
    
    ===========================================================

// Эта функция активирует науч модуль с указанным именем
FUNCTION ScienceExp 
{
PARAMETER SciBlockName. // Принимаем имя термометра
PARAMETER Transmit. //Транслировать или сохранить данные эксперимента.
set SciBlock to ship:partsTagged(SciBlockName)[0]. // Находим соотв. деталь корабля и помещаем в переменную gradusnik
set ScienceModule to SciBlock:GetModule("ModuleScienceExperiment"). // Находим внутри этой части модуль, отвечающий за "науку".
ScienceModule:DEPLOY. // Активируем его.
IF Transmit {
WAIT UNTIL ScienceModule:HASDATA.
ScienceModule:TRANSMIT.
PRINT "Science data from " + SciBlockName + " transmitted to KSC".
}
ELSE PRINT "Science data stored in " + SciBlockName.
}
   
   
ScienceExp("Goo2", FALSE).
ScienceExp("Therm2", FALSE).
ScienceExp("Bar2", FALSE).