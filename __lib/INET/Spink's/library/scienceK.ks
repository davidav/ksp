//scienceK.ks for use with Kerbalism
@lazyglobal off.
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
	local scienceModules is ListScienceModules().
	for theModule in scienceModules{
		if theModule:rerunnable{
			local actionlist is list().
			set actionList to themodule:allactionnames.
			for theAction in actionList{
				if theAction:contains("log"){
					themodule:doaction(theAction,true).
				}
			}
		}
	}
}
function getSample{
	notify("Get Sample").
	local scienceModules is ListScienceModules().
	for theModule in scienceModules{
		if not theModule:rerunnable and not theModule:inoperable{
			local actionlist is list().
			set actionList to themodule:allactionnames.
			for theAction in actionList{
				if theAction:contains("observe"){
					themodule:doaction(theAction,true).
					return true.
				}
			}
		}
	}
}
function ListScienceModules{
	local scienceModules to list().
	local partList to ship:parts.
	for thePart in partList{
		local moduleList to thePart:modules.
		from{local i is 0.}until i = moduleList:length step{set i to i + 1.}do{
			local theModule is moduleList[i].
			if (theModule = "ModuleScienceExperiment") or
				(theModule = "DMModuleScienceAnimate"){
				scienceModules:add(thePart:getModuleByIndex(i)).
			}                      
		}
	}
	return scienceModules.
}