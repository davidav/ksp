//systems.ks
@lazyglobal off.
function deployFairings{
	for theModule in ship:modulesnamed("ModuleProceduralFairing"){
		if theModule:hasevent("deploy"){
			theModule:doevent("deploy").
			notify("Deploying Fairings").
		}
	}
}
function deployPanels{
	panels on.
	notify("Deploying Solar Panels").
}
function retractPanels{
	panels off.
	notify("Retracting Solar Panels").
}
function activateModule{
	parameter tModule.
	parameter tAction.
	for theModule in ship:modulesnamed(tModule){
		if theModule:hasevent(tAction){
			theModule:doevent(tAction).
			notify("Activate " + tModule).
			return true.
		}
		else if theModule:hasaction(tAction){
			theModule:doaction(tAction,true).
			notify("Activate " + tModule).
			return true.
		}
	}
}
function deployAntenna{
	for theModule in ship:modulesnamed("ModuleRTAntenna"){
		if theModule:hasfield("omni range") and theModule:hasevent("Activate"){
			theModule:doevent("Activate").
			notify("Deploying Antenna").
		}
	}
}
function retractAntenna{
	for theModule in ship:modulesnamed("ModuleRTAntenna"){
		if theModule:hasfield("omni range") and theModule:hasevent("Deactivate"){
			theModule:doevent("Deactivate").
			notify("Retracting Antenna").
		}
	}
}
function deployDish{
	for theModule in ship:modulesnamed("ModuleRTAntenna"){
		if theModule:hasfield("dish range") and theModule:hasevent("Activate"){
			theModule:doevent("Activate").
			notify("Deploying Dish").
		}
	}
}
function retractDish{
	for theModule in ship:modulesnamed("ModuleRTAntenna"){
		if theModule:hasfield("dish range") and theModule:hasevent("Deactivate"){
			theModule:doevent("Deactivate").
			notify("Retracting Dish").
		}
	}
}
function pointDish{
	parameter aTarget.
	for theModule in ship:modulesnamed("ModuleRTAntenna"){
		if theModule:hasfield("dish range"){
			theModule:setfield("target",aTarget).
			notify("Pointing dish at " + aTarget).
		}
	}
}
function deployChutes{
	activateModule("ModuleParachute","Deploy Chute").
	activateModule("RealChuteModule","Arm parachute").
}