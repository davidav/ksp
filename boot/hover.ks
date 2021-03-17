LOCK gg TO SHIP:BODY:MU/(SHIP:BODY:RADIUS + ALTITUDE)^2.
SET kV TO 0.5.
SET v_max TO 200.
SET kA TO 2.
SET k_input TO 3.
SET MaxFuel TO SHIP:LIQUIDFUEL.
SET top_vec TO VXCL(SHIP:UP:VECTOR, SHIP:FACING:TOPVECTOR):NORMALIZED.
SET trg_h TO ALTITUDE+5000.


LOCK STEERING TO HEADING(0,85).
STAGE.
SET THROTTLE TO 0.5.
WAIT UNTIL (SHIP:LIQUIDFUEL<MaxFuel*0.7).
SET THROTTLE TO 0.

UNTIL FALSE
{
	SET h_vel_vec TO VXCL(SHIP:UP:VECTOR, SHIP:ORBIT:VELOCITY:SURFACE).
	SET stop_vec TO h_vel_vec*0.1.

	IF (SHIP:LIQUIDFUEL>MaxFuel*0.3)
	{
		SET pitch_vec TO VXCL(SHIP:UP:VECTOR, SHIP:FACING:TOPVECTOR):NORMALIZED*SHIP:CONTROL:PILOTPITCH*k_input.
		SET yaw_vec TO VXCL(SHIP:UP:VECTOR, SHIP:FACING:STARVECTOR):NORMALIZED*SHIP:CONTROL:PILOTYAW*k_input.	
		SET top_vec TO (top_vec + VCRS(SHIP:UP:VECTOR, top_vec):NORMALIZED*SHIP:CONTROL:PILOTROLL*k_input*0.05):NORMALIZED.
		SET trg_h TO trg_h - SHIP:CONTROL:PILOTTOP.	
		KEEPALTASL(trg_h, kV, kA).
	}
	ELSE
	{
		SET pitch_vec TO V(0,0,0).
		SET yaw_vec TO V(0,0,0).
		SET top_vec TO V(0,0,0).			
		IF((ALT:RADAR>20)OR(h_vel_vec:MAG>1))
		{
			KEEPALTRADAR(15, kV, kA).
			//PRINT 1.
		}
		ELSE
		{
			KEEPVERTICALVELOCITY(-1, kV).
			//PRINT 2.
		}
		IF (SHIP:STATUS = "LANDED")
		{
			SET THROTTLE TO 0.
			BREAK.
		}
	}
	
	SET dir_vec TO pitch_vec + yaw_vec - stop_vec.
	
	IF (dir_vec:MAG>0.25)
	{
		SET dir_vec TO dir_vec:NORMALIZED*0.25.
	}
	LOCK STEERING TO LOOKDIRUP(dir_vec + SHIP:UP:VECTOR, top_vec).
	
	WAIT 0.1.
}

PRINT "LANDED".

FUNCTION KEEPALTRADAR
{
	DECLARE LOCAL PARAMETER trg_h.
	DECLARE LOCAL PARAMETER kV.	
	DECLARE LOCAL PARAMETER kA.	
	SET h_diff TO trg_h - ALT:RADAR.
	KEEPVERTICALVELOCITY(h_diff*kV, kA).
}

FUNCTION KEEPALTASL
{
	DECLARE LOCAL PARAMETER trg_h.
	DECLARE LOCAL PARAMETER kV.	
	DECLARE LOCAL PARAMETER kA.	
	SET h_diff TO trg_h - ALTITUDE.
	KEEPVERTICALVELOCITY(h_diff*kV, kA).
}

FUNCTION KEEPVERTICALVELOCITY
{
	DECLARE LOCAL PARAMETER trg_v.
	DECLARE LOCAL PARAMETER kA.
	SET trg_v TO MIN(MAX(trg_v, -v_max), v_max).
	SET v_diff TO trg_v - SHIP:VERTICALSPEED.
	SET corr_a TO v_diff * kA.
	SET Thr0 TO (gg + corr_a) * SHIP:MASS / VDOT(SHIP:UP:VECTOR, SHIP:FACING:FOREVECTOR).
	SET THROTTLE TO Thr0/SHIP:MAXTHRUST.
}




