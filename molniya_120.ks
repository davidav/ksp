// molniya_120 - спутник связи на геостационарной орбите 120 гр от ЦУП
//вывод на  опорную орбиту  80000 
//включение антены на Кербин
//расчет и занятие требуемого угла
//трансфер на геостационарную орбиту 
//вывод на геостационарную орбиту 2 863 330



set nameProgram to "molniya_120".
set angleSatellite to 180.//положение спутника относительно ЦУП 
set altOrbitSatellite to 2863330.//высота орбиты спутника
set keyreleseSolidBoosters to FALSE. // сброс твердотельных ускорителей
set namePartSideEngines to "NONE".// сброс боковых ускорителей
set altReleasePebkac to 37000.//высота сброса Pebkac
set altReleaseObtekatel to 70500.//высота сброса обтекателя
set altConnection to 71000.//высота развертывания средств связи
set typeAntenna to "RTShortDish2".
set targetAntenna1 to "Kerbin".
set altBaseOrbit to 80000 .//высота опорной орбиты
set maxTWR to 1.8.
set targetHead to 90.
set targetPitch to 90.
set GTstart to 3000.// высота начала гравитационного разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов
set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.

set longitudeSatellite to SHIP:GEOPOSITION:LNG + angleSatellite.

set cyclogram to 1.

until cyclogram = 0 {
    if cyclogram = 1{
		system["displayNameCyclogram"]("PRELUNCH").
        system["timer"](3, "BEFORE LAUNCH ", 1).
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
		system["displayNameCyclogram"]("START").
        lock steering to ship:facing.
        print "ZEMLYA - BORT" at(5,4).
        sound["link"]().        
        wait 0.5.
        print "ZAZHIGANIE" at(5,5). 
        lock throttle to 1.0.       
        wait 0.5.
        stage.
        print "TAKE OFF" at(5,6).
        set cyclogram to 3.
    }  
    else if cyclogram = 3{
		system["displayNameCyclogram"]("LIFTING").
        wait 3.
        vessel["orientation"](targetPitch, targetHead).
		vessel["CapTWR"](maxTWR).
        if altitude > GTstart {
            set cyclogram to 4.
        }
    }
    else if cyclogram = 4{
		system["displayNameCyclogram"]("GRAVITY_TURN").
        maneuver["gravityTurn"](5, keyreleseSolidBoosters, namePartSideEngines, altReleasePebkac, targetHead).   
    }
    else if cyclogram = 5{
    	system["displayNameCyclogram"]("FREE_FLIGHT").
        LOCK Steering to PROGRADE.	 	 	
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            if altReleaseObtekatel {
                if altitude > altReleaseObtekatel {
                    vessel["deployFairings"]().
                }
            }   
            if altConnection {
                if altitude > altConnection {
                    vessel["SetLinkTarget"](typeAntenna, 0, targetAntenna1).
                    set altConnection to FALSE.
                    wait 1.
                    vessel["deploySolarPanels"]().                                    
                }
            } 
        }
        wait 0.5.
        set cyclogram to 6.        
    }
    else if cyclogram = 6{
        system["displayNameCyclogram"]("CIRCULARIZE_ORBIT").
        maneuver["circularizeOrbit"]().
        set cyclogram to 7.
    }
    else if cyclogram = 7 {
        system["displayNameCyclogram"]("CALCULATING ANGLE").
        LOCK Steering to PROGRADE.        
        set requestAngle to maneuver["calculatingAngleToOrbit"](altOrbitSatellite).               
        set cyclogram to 8.                
    }    
    else if cyclogram = 8 {
        system["displayNameCyclogram"]("WATING POSITION").
        set keyAngle to FALSE.		
		until keyAngle {
			set currentLongitudeDiff to longitudeSatellite - SHIP:GEOPOSITION:LNG.

			if currentLongitudeDiff < 0{
				set currentLongitudeDiff to currentLongitudeDiff + 360.
		    }	
    		print "Transfer angle: " + Round(requestAngle) at(5,4).
    		print "Current angle: " + Round(currentLongitudeDiff) at(5,5).
    		if ABS(currentLongitudeDiff - requestAngle) < 5{
    			set kuniverse:timewarp:warp to 0.                
            }
    		set keyAngle to (ABS(currentLongitudeDiff - requestAngle) < 3).    
    		wait 1.
	    }
		wait 1.
        set cyclogram to 9.                
    }    
    else if cyclogram = 9 {
        system["displayNameCyclogram"]("TRANSFER").
        LOCK Steering to PROGRADE.
		until orbit:apoapsis > altOrbitSatellite {
			lock throttle to min(2*max(1-orbit:apoapsis/altOrbitSatellite, 0.001),1).
			print "Apo: " + Round(Apoapsis) at(5,7).
			print "Target Apo: " + Round(altOrbitSatellite) at(5,8).
			print "Apo Delta: " + Round(altOrbitSatellite-Apoapsis) at(5,9).	
		}
        lock throttle to 0.
        set cyclogram to 10.                
    }    
    else if cyclogram = 10 {
        system["displayNameCyclogram"]("FREE_FLIGHT").
		until (ETA:Apoapsis < 50) {
			print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,4).
			If ETA:Apoapsis < 100 set kuniverse:timewarp:warp to 0.
			wait 1.
		}
        set cyclogram to 11.
    }    
    else if cyclogram = 11 {
        system["displayNameCyclogram"]("CIRCULARIZE_TARGET_ORBIT").
        maneuver["circularizeOrbit"]().
        LOCK Steering to PROGRADE.
        set cyclogram to 0.                
    }  
}
if cyclogram = 0 {
	system["displayNameCyclogram"]("FINALIZATION").
    wait 1.
    SAS off.
    RCS off.
    unlock steering.
    unlock throttle.
    set ship:control:pilotmainthrottle to 0.
    print "PROGRAM SUCCESSFULLY FINISHED. NO ERROR." at(5,10).
    wait 1.
    sound["beepOK"]().    
}