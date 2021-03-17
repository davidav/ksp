        PRINT "THESE ARE ALL THE RESOURCES ON THE SHIP:".
        LIST RESOURCES IN RESLIST.
        FOR RES IN RESLIST {
            PRINT "Resource " + RES:NAME.
            PRINT "    value = " + RES:AMOUNT.
            PRINT "    which is " + ROUND(100*RES:AMOUNT/RES:CAPACITY).
        }
        

set ksoH to  (sqrt(SHIP:Body:MU)*DayLen/(2*constant():pi))^(2/3) - SHIP:Body:Radius. //высота орбиты в зависимости от периода DayLen
        
        
        
    PRINT "Counting down:".
    FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
        PRINT "..." + countdown.
        WAIT 1.
    }
    
set currentPitch to 90 - vectorangle(up:vector,ship:facing:forevector).//текущий тангаж
set currentRoll to 90 - vectorangle(up:vector,ship:facing:starvector).//текущий крен

set DayLen to SHIP:Body:ROTATIONPERIOD.//звездные сутки 


// замедление при  приблежнии к апоапсису ========
			set throttledown to true.
			if apoapsis > Horb - Horb*0.2 {
				set throttledown to false.
				if apoapsis > Horb set throttledown to true.
			}
			until throttledown{
				lock throttle to max(1 - apoapsis/Horb, 0.001).
				print "Throttle: " + Round(Throttle) at (15,17).
				print "apoapsis: " + Round(apoapsis) at (15,18).
				print "Horbop: " + Round(Horb) at (15,19).
				if apoapsis>80000 set throttledown to true.
			}
// =============================================			
			