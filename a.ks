clearscreen.
switch to 1.
copypath("0:/OS/bootOS", "").
run bootOS.// boot OS
gui["loadingIndicator"](15, "x").//name control program
clearscreen.
print "SYSTEM OK!" at (5, 19).
sound["timeIsOver"]().
wait 10.


// FOR P IN SHIP:PARTS {
//   LOG ("MODULES FOR PART NAMED " + P:NAME) TO "0:/MODLIST".
//   LOG P:MODULES TO "0:/MODLIST".
// }.




// function testModule{
//     parameter tModule.
//     for MOD in ship:modulesnamed(tModule){
//       LOG ("GETFIELD AND SETFIELD" + MOD:NAME + ":") TO "0:/NAMELIST".
//       LOG MOD:ALLFIELDS TO "0:/NAMELIST".
//       LOG ("DOEVENT" +  MOD:NAME + ":") TO "0:/NAMELIST".
//       LOG MOD:ALLEVENTS TO "0:/NAMELIST".
//       LOG ("DOACTION" +  MOD:NAME + ":") TO "0:/NAMELIST".
//       LOG MOD:ALLACTIONS TO "0:/NAMELIST".
//     }
// }
// testModule ("ModuleCargoPart").


                    vessel["actModule"]("ModuleAnimateGeneric", "Open").


// OS_Boot["copyAndRunFile"]("x").//name control program
// sound["beepOK"]().
switch to 0.
