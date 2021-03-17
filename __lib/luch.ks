//LUCH возвращаемый ракетоноситель
//сброс  обтекателя AG3
//перелючение антенн AG5
//вывод на  опорную орбиту 100000 
//*отстыковка полезной нагрузки AG4 
//*тормозной маневр
//выпуск парашутов AG9, AG10 (7000)
//выпуск шасси AG7 (500)
set nameProgram to "LUCH".

OS_SYSTEM["openTerminal"](60 , 40).
OS_VESSEL["setParams"]().
OS_VESSEL["orientation"](90, 90).

set releaseObtekatel to 61000.//высота сброса обтекателя
set HeightLink to 70000.//высота развертывания средств связи
set Horbop to 100000 .//высота опорной орбиты
set GTstart to 3000.// высота начала гравитационного разворота
set GTendAP to 60000. // заканчиваем разворот, когда апоцентр на этой высоте
set v45 to 550. // скорость, при которой угол тангажа должен быть 45 градусов
set maxTWR to 1.8.

until cyclogram = 0 {
    if cyclogram = 1{
		OS_SYSTEM["displayNameCyclogram"](nameProgram, "START").
        OS_SYSTEM["timer"](9).
        lock throttle to 1.0. 
        print "ZEMLYA - BORT" at(5,4).        
        WAIT 1.
		//stage.
        print "ZAZHIGANIE" at(5,6).        
        WAIT 1.
		//stage.
        WAIT 2.        
        set cyclogram to 2.
    }  
    else if cyclogram = 2{
		displayNameCyclogram (nameProgram, "LIFTING").
        lock steering to heading(targetHead,targetPitch).
        print "TAKE OFF" at(5,7).          
		CapTWR(maxTWR).
        if altitude > GTstart {
            set cyclogram to 3.
        }
    }
    else if cyclogram = 3{
		displayNameCyclogram (nameProgram, "GRAVITY_TURN").	 
            gravityTurn(4).// number next cyclogram
            //releseSolidBoosters().
            obtekatel().
            setLinkTarget("HighGainAntenna5",0,"molniya_60.02").
            setLinkTarget("HighGainAntenna5",1,"molniya_180.02").
            setLinkTarget("HighGainAntenna5",2,"molniya_300.02").
            nextstage().
			CapTWR(maxTWR). 
    }
    else if cyclogram = 4{
		displayNameCyclogram (nameProgram, "FREE_FLIGHT").
        LOCK Steering to PROGRADE.	 	 	
        until ETA:Apoapsis<1 {
            print "ETA:Apo: " + Round(ETA:Apoapsis) at(5,5).
            obtekatel().
            setLinkTarget("HighGainAntenna5",0,"molniya_60.02").
            setLinkTarget("HighGainAntenna5",1,"molniya_180.02").
            setLinkTarget("HighGainAntenna5",2,"molniya_300.02").
        }
        wait 0.5.
        set cyclogram to 5. 
    }
    else if cyclogram = 5{
		displayNameCyclogram (nameProgram, "CIRCULARIZE_BASIC_ORBIT").
        circularizeOrbit().
		wait 1.
		print "BASIC ORBIT" at(5,15).
        RCS ON.
        LOCK Steering to PROGRADE.
		wait 5.
        set cyclogram to 6. 
    }
    else if cyclogram = 6{
        displayNameCyclogram (nameProgram, "FREE_ORBIT"). 
        AG4 ON. // отделение полезной нагрузки
        wait 60.
        LOCK Steering to RETROGRADE.
        timer(900).

        set cyclogram to 7.
    }

    else if cyclogram = 7{
        displayNameCyclogram (nameProgram, "BACK_BURN").           
        until Periapsis<37000 {
            lock throttle to 0.2.
        }
        lock throttle to 0.
        set cyclogram to 8.
    }
    
    else if cyclogram = 8{
        displayNameCyclogram (nameProgram, "PREPARE FOR LANDING").
        wait 3.
        BRAKES ON.
        AG5 ON.// откл антенн
        wait 30.
        set cyclogram to 9.
    }        
    else if cyclogram = 9{
        displayNameCyclogram (nameProgram, "PARASHUTE GEAR").
        until ship:status = "LANDED" or ship:status = "SPLASHED" or ship:status = "PRELAUNCH"{
            if (altitude < 7000 and keyReleaseParashute ) {
                AG9 ON. // открытие служебного отсека
                WAIT 1.
                AG10 ON. // раскрытие парашутов
                WAIT 0.1.
                set keyReleaseParashute to 0. 
            }
            if (altitude < 500 and keyReleaseGear ) {
                AG7 ON. // выпуск стоек
                WAIT 1.
                set keyReleaseGear to 0. 
            }
        }
        set cyclogram to 0.
    } 
    
}
    if cyclogram = 0 {
		displayNameCyclogram (nameProgram, "FINALIZATION").        
        wait 1.
        SAS on.
        RCS on.
        unlock throttle.
        set ship:control:pilotmainthrottle to 0.
        print "PROGRAM SUCCESSFULLY FINISHED. NO ERROR." at(5,10).
        wait 1.
        AG5 ON.
		clearscreen.  
    }