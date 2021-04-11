// molniya_60 - спутник связи на геостационарной орбите 60 гр от ЦУП
//вывод на  опорную орбиту  80000 
//включение антены на Кербин
//расчет и занятие требуемого угла
//трансфер на геостационарную орбиту 2 863 330 000



set nameProgram to "molniya_60".

set keyreleseSolidBoosters to FALSE. // сброс твердотельных ускорителей

set namePartSideEngines to "NONE".
set keyRealeseSideTanks to FALSE.

set altReleasePebkac to 37000.//высота сброса Pebkac
set keyRealesePebkac to TRUE.

set altReleaseObtekatel to 55000.//высота сброса обтекателя
set keyReleaseObtekatel to FALSE.

set altConnection to 70000.//высота развертывания средств связи
set keyConnection to FALSE.
set typeAntenna to "HighGainAntenna5".
set targetAntenna1 to "molniya_60".
set targetAntenna2 to "molniya_180".
set targetAntenna3 to "molniya_300".



set altOrbit to 81000 .//высота опорной орбиты
set maxTWR to 1.8.
set targetHead to 90.
set targetPitch to 90.

set GTstart to 3000.// высота начала гравитационного разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов

set ship:control:pilotmainthrottle to 0.
SAS off.
RCS off.


set cyclogram to 1.

until cyclogram = 0 {
    if cyclogram = 1{
		system["displayNameCyclogram"]("PRELUNCH").
        system["timer"](10, "BEFORE LAUNCH ", 1).
        set cyclogram to 2.
    }  
    if cyclogram = 2{
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
        maneuver["gravityTurn"](5, keyreleseSolidBoosters, namePartSideEngines, keyRealesePebkac, targetHead).   
    }
    else if cyclogram = 5{
    	system["displayNameCyclogram"]("FREE_FLIGHT").
        LOCK Steering to PROGRADE.	 	 	
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            if keyReleaseObtekatel {
                if altitude > altReleaseObtekatel {
                    vessel["deployFairings"]().
                    set keyReleaseObtekatel to FALSE.                
                }
            }   
            if keyConnection {
                if altitude > altConnection {
                vessel["SetLinkTarget"](typeAntenna, 0, targetAntenna1).
                vessel["SetLinkTarget"](typeAntenna, 1, targetAntenna2).
                vessel["SetLinkTarget"](typeAntenna, 2, targetAntenna3).
                    set keyConnection to FALSE.                
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
        system["displayNameCyclogram"]("RESERVE").
        LOCK Steering to PROGRADE.        
        wait 0.5.               
        set cyclogram to 8.                
    }    
    else if cyclogram = 8 {
        system["displayNameCyclogram"]("FLIGTH_ORBIT").
        system["timer"](930, "Left before deorbiting ", 1).
        set cyclogram to 9.                
    }    
    else if cyclogram = 9 {
        system["displayNameCyclogram"]("DEORBITING").
        LOCK Steering to RETROGRADE.
        wait until vang(facing:vector, retrograde:vector) < 5.
        until Periapsis<37000 {
            lock throttle to 0.2.
        }
        lock throttle to 0.
        set cyclogram to 0.                
    }    
    // else if cyclogram = 10 {
    //     system["displayNameCyclogram"]("DESCENT_FROM_ORBIT").
    //     if ship:velocity:surface:mag > 2160 {
    //         set cyclogram to 11.
    //     }
    // }    
    // else if cyclogram = 11 {
    //     system["displayNameCyclogram"]("BRAKE_BURN").
    //     until ship:velocity:surface:mag < 1300{
    //         lock throttle to 1.
    //     }
    //     lock throttle to 0.
    //     set cyclogram to 12.                
    // }    
    // else if cyclogram = 12 {
    //     system["displayNameCyclogram"]("GLIDING").
    //     RCS ON.
    //     global glide is glideController(ldata).
    //     lock steering to glide["getSteering"]().
    //     system["timer"](3, "GLIDING ", 1).
    //     set cyclogram to 13.                
    // }    
    // else if cyclogram = 13 {
    //     system["displayNameCyclogram"]("Landing Prep").
    //     global hoverslam is hoverSlamModel().
    //     global landing is landingController(ldata, hoverslam).
    //     lock throttle to landing["getThrottle"]().
    //     system["timer"](3, "Landing Prep ", 1).
    //     set cyclogram to 14.                
    // }    
    // else if cyclogram = 14 {
    //     system["displayNameCyclogram"]("Powered Landing").
    //     wait until throttle > 0 and alt:Radar < 5000.
    //     when alt:radar < 50 then { gear on. }
    //     lock steering to landing["getSteering"]().
    //     wait until landing["completed"]().
    //     set cyclogram to 0.                
    // }    
}
if cyclogram = 0 {
	system["displayNameCyclogram"]("FINALIZATION").
    lock throttle to 0.
    // LOCK Steering to PROGRADE.
    // rcs on.
    sas on.
    sound["beepOK"]().    
}