 runoncepath("0:/fall/utilities/importFall").
 importFall("landingDataModel").
 importFall("hoverSlamModel").
 importFall("glideController").
 importFall("landingController").
         function capTWR {
            parameter maxTWR is 2.0.
            local g0 to Kerbin:mu/Kerbin:radius^2.
            lock throttle to min(1, ship:mass*g0*maxTWR / max( ship:availablethrust, 0.001 ) ).
        }

 //local ldata is landingDataModel(ship:geoposition).
 local spotTuchDown to LATLNG(ship:geoposition:lat + 0.0001, ship:geoposition:lng).
 local ldata is landingDataModel(spotTuchDown).
 lock steering to up.
 lock throttle to 1.
 
 // [ Launch ]
 wait 1.
 stage.
 gear off.
 
 
 // [ Ascent ]
until ship:apoapsis > 4000 {
         capTWR().
 }
 lock throttle to 0.
 rcs on.
 
 // [ Gliding Prep ]
 local glide is glideController(ldata).
 
 
 // [ Gliding ]
 AG5 ON.
 wait until ship:verticalspeed < 0.
 when alt:radar < 300 then { gear on. }
 
 lock steering to glide["getSteering"]().
 
 // [Landing Prep]
 local hoverslam is hoverSlamModel(10).
 local landing is landingController(ldata, hoverslam, 5, 0.4).
 lock throttle to landing["getThrottle"]().
 
 // [ Powered Landing ]
 wait until throttle > 0 and alt:Radar < 5000.
 lock steering to landing["getSteering"]().
 
 wait until landing["completed"]().
 lock throttle to 0.
 rcs off.
 wait until false.











// set keyHeightLink to 1.
// set HeightLink to 1.

                // deletepath(modlist).
                // deletepath(namelist).
        // set n to 0.
        // function testModule{
        //     parameter tModule.
        //     for MOD in ship:modulesnamed(tModule){
        //       LOG ("-----------------") TO NAMELIST.
        //       LOG (MOD:part) TO NAMELIST.
        //       LOG (MOD:NAME) TO NAMELIST.
        //       LOG ("GETFIELD AND SETFIELD ") TO NAMELIST.
        //       LOG MOD:ALLFIELDS TO NAMELIST.
        //       LOG ("DOEVENT ") TO NAMELIST.
        //       LOG MOD:ALLEVENTS TO NAMELIST.
        //       LOG ("DOACTION ") TO NAMELIST.
        //       LOG MOD:ALLACTIONS TO NAMELIST.
        //       set n to n + 1.
        //     }
        //     LOG("n = " + n) TO NAMELIST.
        // }
        // testModule ("ModuleTestSubject").



// FOR P IN SHIP:PARTS {
//   LOG ("MODULES FOR PART NAMED " + P:NAME) TO MODLIST.
//   LOG P:MODULES TO MODLIST.
// }.

// function checkEngineFlameout {
//         parameter namePart.
//         FOR P IN SHIP:PARTS {
//                 if (P:name = namePart){
//                         print P:FLAMEOUT.                               
//                         return P:FLAMEOUT.
//                 }
//         }
// }
// until checkEngineFlameout("Size2LFB"){
//           wait 0.1.      
//         }
// stage.
// print "ok!".
//LIST ENGINES IN allEngines.
//print allEngines.
// FOR theEngine IN allEngines {
//         // if theEngine = "Size2LFB"{
//                 print "An engine " + theEngine:part:name.
//         // }
//}.

