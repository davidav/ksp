if HASTARGET = FALSE {
  PRINT "No Target!!!".
} else {
  sas off.
  rcs off.
  SET dp TO SHIP:DOCKINGPORTS.

  WHEN dp[0]:STATE = "PreAttached" THEN {
    SET f TO 0.
    RCS OFF.
    UNLOCK STEERING.
  }
  WHEN facing:vector:normalized <> dp[0]:facing:vector:normalized THEN {
    dp[0]:CONTROLFROM().
    PRESERVE.
  }

  SET rp TO SHIP:PARTSDUBBED("RCS").

  set p to 7.
  set i to p / 3.
  set st to prograde.
  lock steering to st.
  lock st to target:portfacing:vector:normalized * -1.
  wait 4.
  rcs on.
  lock cls to (target:ship:velocity:orbit - ship:velocity:orbit).
  lock u to (facing * R (-90, 0, 0)):vector:normalized.
  lock fwd to facing:vector:normalized.
  lock stb to (facing * R (0, 90, 0)):vector:normalized.
  lock uerr to target:ship:position * u - dp[0]:position:mag.
  lock ferr to target:ship:position * fwd .
  lock stberr to target:ship:position * stb.
  lock dup to cls * u.
  lock dstb to cls * stb.
  lock dfwd to cls * fwd.
  set f to 1.
  set uint to 0.
  set stbint to 0.
  set fint to 0.
  set standoff to target:ship:position:mag.
  if standoff < 15
  {
    set standoff to 15.
  }.

  clearscreen.
  PRINT "#######################################" AT (2,2).
  PRINT "# Direction  #  Distance  #  Velocity #" AT (2,3).
  PRINT "#######################################" AT (2,4).
  PRINT "# UP         #            #           #" AT (2,5).
  PRINT "# Forward    #            #           #" AT (2,6).
  PRINT "# Starboard  #            #           #" AT (2,7).
  PRINT "#######################################" AT (2,8).
  PRINT "  RCS Offset :" AT (2,12).
  PRINT round(dp[0]:position:mag,2) + "    " AT (2,13).

  until f = 0
  {
    set fwddes to MIN(1.5,MAX(-1.5,(standoff - ferr) / 10)).
    if (abs(uerr) < .5) and (abs(stberr) < .5)
    {
      set fwddes to MIN(1.5,MAX(-1.5,(ferr/ 20) * -1)).
      set standoff to ferr.
    }.
    set updes to  MIN(1.5,MAX(-1.5,(uerr / 12) * -1)).
    set stbdes to MIN(1.5,MAX(-1.5,(stberr / 12) * -1)).

    set fpot to dfwd - fwddes.
    set upot to dup - updes.
    set stbpot to dstb - stbdes.

    set fint to    MIN(5,MAX(-5,fint + fpot * .1)).
    set stbint to  MIN(5,MAX(-5,stbint + stbpot * .1)).
    set uint to    MIN(5,MAX(-5,uint + upot * .1)).

    set fwdctr to fpot * p + fint * i.
    set ship:control:fore to (fwdctr).

    set upctr to upot * p + uint * i.
    set ship:control:top to (upctr).

    set stbctr to stbpot * p + stbint * i.
    set ship:control:starboard to (stbctr).

    print round(uerr, 2) + " m  " AT (17,5).
    PRINT round(dup, 2)+" m/s  " AT (30,5).
    print round(ferr, 2) + " m  " AT (17,6).
    print round(dfwd, 2)+" m/s" AT (30,6).
    print round(stberr, 2) + " m" AT(17,7).
    print round(dstb, 2)+" m/s" AT (30,7).

    PRINT "State " + dp[0]:STATE AT (10,0).
    if (abs(uerr) < .5) and (abs(stberr) < .5)
    {
      print "Approaching                    " AT (4,9).
    }.
    if (abs(uerr) > .5) or (abs(stberr) > .5)
    {
      print "Holding at: " + round(standoff) AT (4,9).
    }.
    if rp:LENGTH = 4 {
      LOCAL fore IS MAX(rp[0]:POSITION:Z, rp[1]:POSITION:Z).
      LOCAL aft IS MIN(rp[2]:POSITION:Z, rp[3]:POSITION:Z).
      PRINT round(ABS(fore) - ABS(aft),2) + "   " AT (17,12).
    }
    wait 0.
  }.
}

