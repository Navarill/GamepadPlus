--[[
		GamePadPlus
		Gamepad UI enhancement for The Elder Scrolls Online
		License: The MIT License
 ]]
 
--------------------------------------------------
--|  Create Namespace  |--
--------------------------------------------------
if GamePadPlus == nil then GamePadPlus = {} end


--------------------------------------------------
--|  Initialize Variables  |--
--------------------------------------------------
local addon = GamePadPlus

addon.name = "GamePadPlus"
addon.title = "GamePad Plus"
addon.author = "Sidrinius"
addon.version = "1.0.0"
addon.settings = {}


--------------------------------------------------
--|  OnAddOnLoaded  |--
--------------------------------------------------
function addon.OnAddOnLoaded(eventCode, addOnName)
	
	if (addOnName ~= addon.name) then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, eventCode)

	addon:SettingsSetup()

end


--------------------------------------------------
--|  Register Events  |--
--------------------------------------------------
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnAddOnLoaded)
