--[[
		GamepadPlus
		Gamepad UI enhancement for display of market data
		License: (To Be Determined)
		Based on RockingDice's GamePadBuddy
		https://www.esoui.com/downloads/info1773-GamePadBuddy.html
		https://github.com/rockingdice/GamePadBuddy
]]

function GamepadPlus:SettingsSetup()
	local GPP = GamepadPlus
	local LAM = LibAddonMenu2

	GPP.defaults = {
		invtooltip = false,
		recipes = false,
		att = false,
        -- eth = false,
		mm = false,
		ttc = false,
	}

	-- Initialize saved variables
	GPP.settings = LibSavedVars
		:NewAccountWide(GPP.name .. "_Data", GPP.defaults)
		:AddCharacterSettingsToggle(GPP.name .. "_Data")

	-- Settings panel
	local panelData = {
    	type = "panel",
    	name = GPP.title,
    	displayName = GPP.title,
    	author = GPP.author,
        version = GPP.version,
        registerForRefresh = true,
        registerForDefaults = true,
	}

	LAM:RegisterAddonPanel(GPP.name, panelData)

	-- Options table
	local optionsTable = {

		-- Account-wide settings
        GPP.settings:GetLibAddonMenuAccountCheckbox(),

		-- Divider
		{
			type = "divider",
			width = "full",
		},

		-- Checkbox for Inventory Tooltip
        {
            type = "checkbox",
            name = "Equipped Inventory Tooltip",
            tooltip = "Show equipped inventory tooltip info",
            getFunc = function() return GPP.settings.invtooltip end,
            setFunc = function(value) GPP.settings.invtooltip = value end,
            width = "full",
            default = GPP.defaults.invtooltip,
        },

		-- Checkbox Recipes
        {
            type = "checkbox",
            name = "Recipes",
            tooltip = "Show recipe pricing info",
            getFunc = function() return GPP.settings.recipes end,
            setFunc = function(value) GPP.settings.recipes = value end,
            width = "full",
            default = GPP.defaults.recipes,
        },

		-- Divider
		{
			type = "divider",
			width = "full",
		},

		-- Checkbox for Arkadius' Trade Tools
		{
            type = "checkbox",
            name = "Arkadius' Trade Tools",
            tooltip = "Show pricing info from Arkadius' Trade Tools",
            getFunc = function() return GPP.settings.att end,
            setFunc = function(value) GPP.settings.att = value end,
            width = "full",
            default = GPP.defaults.att,
        },

        --[[
        -- Checkbox for ESO Trading Hub
        {
            type = "checkbox",
            name = "ESO Trading Hub",
            tooltip = "Show pricing info from ESO Trading Hub",
            getFunc = function() return GPP.settings.eth end,
            setFunc = function(value) GPP.settings.eth = value end,
            width = "full",
            default = GPP.defaults.eth,
        },
        ]]

		-- Checkbox for Master Merchant
        {
            type = "checkbox",
            name = "Master Merchant",
            tooltip = "Show pricing info from Master Merchant",
            getFunc = function() return GPP.settings.mm end,
            setFunc = function(value) GPP.settings.mm = value end,
            width = "full",
            default = GPP.defaults.mm,
        },

		-- Checkbox for Tamriel Trade Centre
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

	LAM:RegisterOptionControls(GPP.name, optionsTable)

end