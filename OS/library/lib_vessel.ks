//@lazyglobal off.
// public class vesselController     
function vesselController{  
        function actModule{
            parameter nameModule.
            parameter nameAction.
            for theModule in ship:modulesnamed(nameModule){
                if theModule:hasevent(nameAction){
                    theModule:doevent(nameAction).
                    print("Activate doevent " + nameModule).
                }
                else if theModule:hasaction(nameAction){
                    theModule:doaction(nameAction,true).
                    print("Activate doaction " + nameModule).
                }
            }
        }
        function capTWR {
            parameter maxTWR is 3.0.
            local g0 to Kerbin:mu/Kerbin:radius^2.
            lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ).
        }
        function checkEngineFlameout {
                parameter namePart.
                FOR P IN SHIP:PARTS {
                        if (P:name = namePart){
                                return P:FLAMEOUT.
                        }
                }
        }               
        function deployChutes{
            actModule("RealChuteModule","Arm parachute").
        }
        function deployFairings{
            actModule("ModuleProceduralFairing","deploy").
            actModule("ProceduralFairingDecoupler","jettison fairing").
        }
        function deploySolarPanels{
            panels on.
        }
        function nextstage{
            until ship:availablethrust > 0 {
            wait 0.5.
            stage.
            wait 0.1.
            print "next stage".            
            }
        }
        function orientation{
            parameter targetPitch.
            parameter targetHead.
            lock steering to heading(targetHead, targetPitch).
            print "Orientation".            
        }
        function retractSolarPanels{
            panels off.
        }
        function releseSolidBoosters{
            if STAGE:SOLIDFUEL < 10 {
                wait 0.5.                
                STAGE.
                wait 0.1.
                set keyreleseSolidBoosters to FALSE.
                print "Relese Solid Boosters".
            }
        }
        function setLinkTarget{
            parameter AntName. 
            parameter BlockIndex. 
            parameter LinkTarget.
            SET p TO SHIP:partsnamed(AntName)[BlockIndex].
            SET m TO p:GETMODULE("ModuleRTAntenna").
            m:DOEVENT("Activate").
            m:SETFIELD("target", LinkTarget).
            WAIT 1.
		    print "ANTENNA #"+ (BlockIndex + 1) + " IS TUNED TO - " + LinkTarget.
        }   
    // Return Public Fields
    return lexicon(
        "actModule", actModule@,
        "capTWR", capTWR@,
        "checkEngineFlameout", checkEngineFlameout@,
        "deployChutes", deployChutes@,        
        "deployFairings", deployFairings@,
        "deploySolarPanels", deploySolarPanels@,
        "nextstage", nextstage@,                       
        "orientation", orientation@,
        "retractSolarPanels", retractSolarPanels@,        
        "releseSolidBoosters", releseSolidBoosters@,
        "setLinkTarget", setLinkTarget@
    ). 
}
global vessel is vesselController().