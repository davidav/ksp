PRINT "THESE ARE ALL THE RESOURCES ON THE SHIP:".
LIST RESOURCES IN RESLIST.
FOR RES IN RESLIST {
    PRINT "Resource " + RES:NAME.
    PRINT "    value = " + RES:AMOUNT.
    PRINT "    which is " + ROUND(100*RES:AMOUNT/RES:CAPACITY).
}
-------------------
deletepath(muna72).
-------------------

FOR P IN SHIP:PARTS {
  LOG ("MODULES FOR PART NAMED " + P:NAME) TO MODLIST.
  LOG P:MODULES TO MODLIST.
}.

--------------

function testModule{
    parameter tModule.
    for MOD in ship:modulesnamed(tModule){
      LOG ("GETFIELD AND SETFIELD" + MOD:NAME + ":") TO NAMELIST.
      LOG MOD:ALLFIELDS TO NAMELIST.
      LOG ("DOEVENT" +  MOD:NAME + ":") TO NAMELIST.
      LOG MOD:ALLEVENTS TO NAMELIST.
      LOG ("DOACTION" +  MOD:NAME + ":") TO NAMELIST.
      LOG MOD:ALLACTIONS TO NAMELIST.
    }
}
testModule ("ModuleProceduralFairing").
---------------



SomeModule:DOEVENT("Activate").