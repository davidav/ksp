


CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 40.
SET TERMINAL:HEIGHT TO 15.
clearscreen. 

function SetLinkTarget{
    parameter AntName. // Принимаем имя антенны
    parameter BlockIndex. 
    parameter LinkTarget. //Цель для антенны.
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", LinkTarget).
}

//        SetLinkTarget("HighGainAntenna5",0,"link_1").
//       SetLinkTarget("HighGainAntenna5",1,"link_2").
        SetLinkTarget("HighGainAntenna5",2,"link_3").
//		SetLinkTarget("HighGainAntenna5",3,"Kerbin").        
		wait 1.
		print "ok" at(5,5).
