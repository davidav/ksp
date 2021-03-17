CORE:PART:GETMODULE("kOSProcessor"):DOEVENT("Open Terminal").
SET TERMINAL:WIDTH TO 60.
SET TERMINAL:HEIGHT TO 20.
clearscreen.



function EnableDevice{
    parameter deviceName. // имя устройства
    parameter blockIndex.// номер
    parameter moduleName.// имя модуля
    parameter actionName.// действие
    SET p TO SHIP:partsnamed(deviceName)[blockIndex].
    SET m TO p:GETMODULE(moduleName).
    m:DOEVENT(actionName).
}


EnableDevice ("SurveyScanner",0,"ModuleAnimationGroup","Deploy Scanner"). // запуск M700 сканера
EnableDevice ("SurveyScanner",0,"ModuleOrbitalSurveyor","Perform orbital survey"). // M700 сканирует пов-ть



EnableDevice ("dockingPort3", 1, "ModuleDockRotate", "Rotate clockwise (+)").// выдвигаем мульти сканер
EnableDevice ("dockingPort3", 3, "ModuleDockRotate", "Rotate clockwise (+)").// выдвигаем радар сканер
EnableDevice ("dockingPort3", 5, "ModuleDockRotate", "Rotate clockwise (+)").// выдвигаем оре сканер
EnableDevice ("dockingPort3", 7, "ModuleDockRotate", "Rotate Counterclockwise (-)").// поворачиваем оре сканер


EnableDevice ("solarPanels4", 0, "ModuleDeployableSolarPanel", "Extend Solar Panel").
EnableDevice ("solarPanels4", 1, "ModuleDeployableSolarPanel", "Extend Solar Panel").
EnableDevice ("solarPanels4", 2, "ModuleDeployableSolarPanel", "Extend Solar Panel").
EnableDevice ("solarPanels4", 3, "ModuleDeployableSolarPanel", "Extend Solar Panel").

EnableDevice ("OrbitalScanner",0,"ModuleAnimationGroup","Deploy Scanner"). // запуск оре сканера
EnableDevice ("SCANsat.Scanner",0,"SCANsat","Start Scan: RADAR"). // развертывание радар сканера
EnableDevice ("SCANsat.Scanner",0,"SCANexperiment","Analyze Data: RADAR"). //анализ данных радар сканера

EnableDevice ("SCANsat.Scanner24", 0, "SCANsat", "Start Scan: Multispectral").// развертывание мульти сканера
EnableDevice ("SCANsat.Scanner24", 0, "SCANexperiment", "Analyze Data: Multispectral").//анализ данных мульти сканера




function SetLinkTarget{
    parameter AntName. // Принимаем имя антенны
    parameter BlockIndex. 
    parameter LinkTarget. //Цель для антенны.
    SET p TO SHIP:partsnamed(AntName)[BlockIndex].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", LinkTarget).
}

   
SetLinkTarget("HighGainAntenna5",0,"Kerbin").
SetLinkTarget("HighGainAntenna5",1,"Kerbin").