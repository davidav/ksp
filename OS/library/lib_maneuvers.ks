//@lazyglobal off.
// public class maneuverController
function maneuverController{
    function gravityTurn{
        parameter numberNextCyclogram.
        parameter keyreleseSolidBoosters is FALSE.
        parameter namePartSideEngines is "NONE".
        parameter altReleasePebkac is FALSE.
        parameter targetHead is 90.
            local GTStartSpd to velocity:surface:mag.
            set AP45 to apoapsis.
            set pitch to 0.
            lock GTpitch to 90 - vang( up:vector, velocity:surface ).
            until altitude > altBaseOrbit {
                set vsm to velocity:surface:mag.
                if GTpitch >= 45 {
                    set Apo45 to apoapsis.
                }
                if ( vsm < v45 ) {
                    set pitchRaschet1 to min(90, 90 - arctan((vsm - GTStartSpd)/(v45 - GTStartSpd))).
                    if pitch - pitchRaschet1 > 3 {
                        set pitch to pitch-1.
                        wait 3.
                    } else {
                        set pitch to pitchRaschet1.
                    }
                } else {
                    set pitchRaschet to max(0, 45*(apoapsis - GTendAP) / (AP45 - GTendAP)).
                    if pitch - pitchRaschet > 3 {
                        set pitch to pitch-1.
                        wait 1.
                    } else {
                        set pitch to pitchRaschet.
                    }
                }
                lock steering to heading(targetHead, pitch).
                print "Pitch: " + round( pitch ) + " deg  " at (5,4).
                print "Apo: " + Round(Apoapsis) at (5,5).
                if apoapsis > altBaseOrbit {
                    lock throttle to 0.
                    set cyclogram to numberNextCyclogram.
                    break.
                }
                vessel["CapTWR"](maxTWR).
                vessel["nextstage"]().
                if altReleasePebkac {
                    if altitude > altReleasePebkac {
                        AG1 ON.
                        set altReleasePebkac to FALSE.
                    }
                }
                if keyreleseSolidBoosters {
                    vessel["releseSolidBoosters"]().
                }
                if not (namePartSideEngines = "NONE"){
                    if (vessel["checkEngineFlameout"](namePartSideEngines)) {
                        stage.
                        wait 0.5.
                    }
                }
                if altReleaseObtekatel {
                    if altitude > altReleaseObtekatel {
                        vessel["deployFairings"]().
                        set altReleaseObtekatel to FALSE.
                    }
                }
            }
    }
    function circularizeOrbit{
        local th to 0.
            local Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
            local Vcircmag to sqrt(body:mu / body:position:mag).
            local Vcirc to Vcircmag*Vcircdir.
            local deltav to Vcirc - velocity:orbit.
            lock steering to lookdirup( deltav, up:vector).
            wait until vang( facing:vector, deltav ) < 1.
            lock throttle to th.
            until deltav:mag < 0.05 {
                set Vcircdir to vxcl( up:vector, velocity:orbit ):normalized.
                set Vcircmag to sqrt(body:mu / body:position:mag).
                set Vcirc to Vcircmag*Vcircdir.
                set deltav to Vcirc - velocity:orbit.
                if vang( facing:vector, deltav ) > 5 {
                set th to 0.
                }
                else {
                set th to min( 1, deltav:mag * ship:mass / max( ship:availablethrust, 0.001 ) ).
                }
                wait 0.1.
                vessel["nextstage"]().
            }
            lock throttle to 0.
    }
    // calculatingAngleToOrbit :: int(meters) -> int(angle)
    function calculatingAngleToOrbit{
        parameter altNewOrbit.
    	set radiusNewOrbit to SHIP:Body:Radius + altNewOrbit.
    	set A1 to (Ship:Body:radius + ship:altitude + radiusNewOrbit)/2.
    	set A2 to radiusNewOrbit.
    	set angleToOrbit to 180*(1 - ((A1^3)/(A2^3))^1.5).
    	return angleToOrbit.
    }
    // Return Public Fields
    return lexicon(
        "gravityTurn", gravityTurn@,
        "circularizeOrbit", circularizeOrbit@,
        "calculatingAngleToOrbit", calculatingAngleToOrbit@
    ).
}
global maneuver is maneuverController().
