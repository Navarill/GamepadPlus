--[[
		GamePadPlus
		Gamepad UI enhancement
 ]]

if GamePadPlus == nil then GamePadPlus = {} end
local GPP = GamePadPlus


function GPP.MakeMenu()
  
	local panelData = {
    		type = "panel",
    		name = "GamePadPlus",
    		displayName = "GamePadPlus",
    		author = "|c6C00FF@Sidrinius|r",
        version = GPP.version,
        slashCommand = "/gpp",
        registerForRefresh = true,
        registerForDefaults = true,
        -- website = "https://www.esoui.com/downloads/info2862-AdBlock.html",
	}
	
	local menu = LibAddonMenu2
	menu:RegisterAddonPanel("GamePadPlus", panelData)

	local optionsTable = {
	
		-- Account-wide settings
        GPP.settings:GetLibAddonMenuAccountCheckbox(),

        {
            type = "checkbox",
            name = "Arkadius' Trade Tools",
            tooltip = "Hides text similar to 'Wts lootruns...'",
            getFunc = function() return GPP.settings.att end,
            setFunc = function(value) GPP.settings.att = value end,
            width = "full",
            default = GPP.defaults.att,
        },
				
        {
            type = "checkbox",
            name = "Master Merchant",
            tooltip = "Hides all guild ads with a guild linking",
            getFunc = function() return GPP.settings.mm end,
            setFunc = function(value) GPP.settings.mm = value end,
            width = "full",
            default = GPP.defaults.mm,
        },
				
        {
            type = "checkbox",
            name = "Tamriel Trade Centre",
            tooltip = "Hides 'wts/wtb crowns' messages",
            getFunc = function() return GPP.settings.ttc end,
            setFunc = function(value) GPP.settings.ttc = value end,
            width = "full",
            default = GPP.defaults.ttc,
        },
		
	}
	
	menu:RegisterOptionControls("GamePadPlus", optionsTable)
	
end
