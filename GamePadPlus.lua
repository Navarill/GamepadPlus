--[[
		GamePadPlus
		Gamepad UI enhancement
 ]]

if not GamePadPlus then GamePadPlus = {} end
local GPP = GamePadPlus
local em = GetEventManager()

GPP.name = "GamePadPlus"
GPP.version = "1.0.0"
GPP.settings = {}
GPP.defaults = {
	ATT = false,
	MM = false,
	TTC = false,
}

function GPP.Initialize(event, addon)
	
	if addon ~= GPP.name then return end
	
	em:UnregisterForEvent("GamePadPlusInitialize", EVENT_ADD_ON_LOADED)

	-- Fetch the saved variables
    GPP.settings = LibSavedVars:NewAccountWide(GPP.name .. "_Account", GPP.defaults)
                     :AddCharacterSettingsToggle(GPP.name .. "_Character")
    
    if LSV_Data.EnableDefaultsTrimming then
        GPP.settings:EnableDefaultsTrimming()
    end

	GPP.MakeMenu()

end

em:RegisterForEvent("GamePadPlusInitialize", EVENT_ADD_ON_LOADED, function(...) GPP.Initialize(...) end)
