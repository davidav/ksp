//science.ks for use without Kerbalism
@lazyglobal off.
global tDelay is 0.
global xmit is false.

function doScience{
	parameter data is true.
	parameter sample is false.
	if data{
		getData().
	}
	if sample{
		getSample().   
	}
}
function getData{
	notify("Get Data").
	set xmit to false.
	local scienceModules is ListScienceModules().
	for theModule in scienceModules{
		if theModule:rerunnable{
			if theModule:hasdata{
				evalData(theModule).
			}
			if not theModule:hasdata{
				doExperiment(theModule).
				set xmit to true.
			}
		}
	}
	set tDelay to time:seconds + 5.
	when xmit = true and tDelay < time:seconds then{
		notify("Check Data").
		local scienceModules is ListScienceModules().
		for theModule in scienceModules{
			evalData(theModule).
		}
	}
}

function getSample{
	notify("Get Sample").
	local scienceModules is ListScienceModules().
	for theModule in scienceModules{
		if not theModule:rerunnable and
		   not theModule:inoperable and
			 not theModule:hasdata{
				doExperiment(theModule).
				break.
		}
	}
}
function doExperiment{
	parameter theModule.
	if not theModule:inoperable{
		theModule:deploy().
	}
}
function evalData{
	parameter theModule.
	if theModule:rerunnable and not theModule:inoperable and theModule:hasdata{
		local dataT is theModule:data[0]:transmitvalue.
		if dataT = 0{
			notify("Dump redundant data").
			theModule:dump().
			if not theModule:inoperable{
				theModule:reset().
			}
			return.
		}
		if CheckForCharge(theModule:data[0]){
			notify("Xmit data").
			theModule:transmit().
		}
	}
}

function GetSpecifiedResource{
	parameter searchTerm.
	local allResources to ship:resources.
	local theResult to "".
	for theResource in allResources{
		if theResource:name = searchTerm{
			set theResult to theResource.
			break.
		}
	}
	return theResult.
}

function CheckForCharge{
	parameter scienceData.
	local electricalPerData to 6.
	local electricalResource to GetSpecifiedResource("ElectricCharge").
	local chargeMargin to 1.05. // Want to have not just enough,but a 5% margin
	local canTransmit to true.
	local neededCharge to scienceData:dataamount * electricalPerData * chargeMargin.
	if (electricalResource:capacity < neededCharge) or (electricalResource:amount < neededCharge){
		notify("Insufficient electrical capacity to attempt transmission").
		set canTransmit to false.
	}
	if not homeconnection:isconnected {
		set canTransmit to false.
	}
	return canTransmit.
}

function ListScienceModules{
	local scienceModules to list().
	local partList to ship:parts.
	for thePart in partList{
		local moduleList to thePart:modules.
		from{local i is 0.}until i = moduleList:length step{set i to i+1.}do{
			local theModule is moduleList[i].
			if (theModule = "ModuleScienceExperiment") or (theModule = "DMModuleScienceAnimate"){
				scienceModules:add(thePart:getModuleByIndex(i)).
			}                      
		}
	}
	return scienceModules.
}