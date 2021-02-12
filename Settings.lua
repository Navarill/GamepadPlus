--[[
		GamePadPlus
		Gamepad UI enhancement for The Elder Scrolls Online
		License: The MIT License
 ]]

-- GamePadPlus namespace
if GamePadPlus == nil then GamePadPlus = {} end

local addon = GamePadPlus

function SettingsSetup()

	addon.defaults = {
		ATT = false,
		MM = false,
		TTC = false,
	}
	
	-- Initialize saved variables
	addon.settings = LibSavedVars
		:NewAccountWide(addon.name .. "_Account", addon.defaults)
		:AddCharacterSettingsToggle(addon.name .. "_Character")
	
	if LSV_Data.EnableDefaultsTrimming then
		addon.settings:EnableDefaultsTrimming()
	end

	local panelData = {
    	type = "panel",
    	name = addon.title,
    	displayName = addon.title,
    	author = addon.author,
        version = addon.version,
        slashCommand = "/addon",
        registerForRefresh = true,
        registerForDefaults = true,
        -- website = "insert URL here",
	}

	LibAddonMenu2:RegisterAddonPanel("GamePadPlus", panelData)

	local optionsTable = {
	
		-- Account-wide settings
        addon.settings:GetLibAddonMenuAccountCheckbox(),
		
		-- Divider
		{
			type = "divider",
			width = "full",
		},

        {
            type = "checkbox",
            name = "Arkadius' Trade Tools",
            tooltip = "Show pricing info from Arkadius' Trade Tools",
            getFunc = function() return addon.settings.att end,
            setFunc = function(value) addon.settings.att = value end,
            width = "full",
            default = addon.defaults.att,
        },
				
        {
            type = "checkbox",
            name = "Master Merchant",
            tooltip = "Show pricing info from Master Merchant",
            getFunc = function() return addon.settings.mm end,
            setFunc = function(value) addon.settings.mm = value end,
            width = "full",
            default = addon.defaults.mm,
        },
				
        {
            type = "checkbox",
            name = "Tamriel Trade Centre",
            tooltip = "Show pricing info from Tamriel Trade Centre",
            getFunc = function() return addon.settings.ttc end,
            setFunc = function(value) addon.settings.ttc = value end,
            width = "full",
            default = addon.defaults.ttc,
        },

	}

	LibAddonMenu2:RegisterOptionControls("GamePadPlus", optionsTable)

end
