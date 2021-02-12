--[[
		GamePadPlus
		Gamepad UI enhancement
		License: The MIT License
 ]]

-- GamePadPlus namespace
if GamePadPlus == nil then GamePadPlus = {} end

local GPP = GamePadPlus

function GPP.MakeMenu()

	GPP.defaults = {
		ATT = false,
		MM = false,
		TTC = false,
	}
	
	-- Initialize saved variables
	GPP.settings = LibSavedVars
		:NewAccountWide(GPP.name .. "_Account", GPP.defaults)
		:AddCharacterSettingsToggle(GPP.name .. "_Character")
	
	if LSV_Data.EnableDefaultsTrimming then
		GPP.settings:EnableDefaultsTrimming()
	end

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

	LibAddonMenu2:RegisterAddonPanel("GamePadPlus", panelData)

	local optionsTable = {
	
		-- Account-wide settings
        GPP.settings:GetLibAddonMenuAccountCheckbox(),

        {
            type = "checkbox",
            name = "Arkadius' Trade Tools",
            tooltip = "Show pricing info from Arkadius' Trade Tools",
            getFunc = function() return GPP.settings.att end,
            setFunc = function(value) GPP.settings.att = value end,
            width = "full",
            default = GPP.defaults.att,
        },
				
        {
            type = "checkbox",
            name = "Master Merchant",
            tooltip = "Show pricing info from Master Merchant",
            getFunc = function() return GPP.settings.mm end,
            setFunc = function(value) GPP.settings.mm = value end,
            width = "full",
            default = GPP.defaults.mm,
        },
				
        {
            type = "checkbox",
            name = "Tamriel Trade Centre",
            tooltip = "Show pricing info from Tamriel Trade Centre",
            getFunc = function() return GPP.settings.ttc end,
            setFunc = function(value) GPP.settings.ttc = value end,
            width = "full",
            default = GPP.defaults.ttc,
        },

	}

	LibAddonMenu2:RegisterOptionControls("GamePadPlus", optionsTable)

end
