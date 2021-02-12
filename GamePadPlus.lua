--[[
		GamePadPlus
		Gamepad UI enhancement
		License: The MIT License
 ]]
 
 -- GamePadPlus namespace
--if not GamePadPlus then GamePadPlus = {} end
if GamePadPlus == nil then GamePadPlus = {} end

local GPP = GamePadPlus

GPP.name = "GamePadPlus"
GPP.version = "1.0.0"
GPP.settings = {}

function GPP.Initialize(event, addon)
	
	if addon ~= GPP.name then return end
	EVENT_MANAGER:UnregisterForEvent("GamePadPlusInitialize", EVENT_ADD_ON_LOADED)

	GPP.MakeMenu()

end

EVENT_MANAGER:RegisterForEvent("GamePadPlusInitialize", EVENT_ADD_ON_LOADED, function(...) GPP.Initialize(...) end)
