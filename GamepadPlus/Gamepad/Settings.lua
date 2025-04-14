--[[
		GamepadPlus
		Gamepad UI enhancement for display of market pricing data
		License: (To Be Determined)
		Based on RockingDice's GamePadBuddy
		https://www.esoui.com/downloads/info1773-GamePadBuddy.html
		https://github.com/rockingdice/GamePadBuddy
]]

function GamepadPlus.LoadSettings()
	local GPP = GamepadPlus
	local LAM = LibAddonMenu2

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

	LAM:RegisterAddonPanel(GPP.title, panelData)

	local optionsTable = {}

	-- Account-wide settings
	table.insert(
		optionsTable,
		{
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings for all characters on the account.",
            getFunc = function()
                return GPP.savedVars.accountwide
            end,
            setFunc = function(value)
				GPP.accountSavedVars.accountwide = value
                GPP.characterSavedVars.accountwide = value
            end,
            width = "full",
            requiresReload = true,
        }
	)

	-- Divider
	table.insert(
		optionsTable,
		{
			type = "divider",
			width = "full",
		}
	)

	-- Checkbox for Inventory Tooltip
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "Equipped Inventory Tooltip",
            tooltip = "Show equipped inventory tooltip info",
            getFunc = function() return GPP.savedVars.invtooltip end,
            setFunc = function(value) GPP.savedVars.invtooltip = value end,
            width = "full",
            default = GPP.defaults.invtooltip,
        }
	)

	-- Checkbox Recipes
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "Recipes",
            tooltip = "Show recipe pricing info",
            getFunc = function() return GPP.savedVars.recipes end,
            setFunc = function(value) GPP.savedVars.recipes = value end,
            width = "full",
            default = GPP.defaults.recipes,
        }
	)

	-- Divider
	table.insert(
		optionsTable,
		{
			type = "divider",
			width = "full",
		}
	)

	-- Checkbox for Arkadius' Trade Tools
	table.insert(
		optionsTable,
		{
            type = "checkbox",
            name = "Arkadius' Trade Tools",
            tooltip = "Show pricing info from Arkadius' Trade Tools",
            getFunc = function() return GPP.savedVars.att end,
            setFunc = function(value) GPP.savedVars.att = value end,
            width = "full",
            default = GPP.defaults.att,
        }
	)

	-- Checkbox for ESO Trading Hub Listing Prices
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "ESO Trading Hub (Listings)",
            tooltip = "Show listing prices from ESO Trading Hub",
            getFunc = function() return GPP.savedVars.ethl end,
            setFunc = function(value) GPP.savedVars.ethl = value end,
            width = "full",
            default = GPP.defaults.ethl,
        }
	)

	-- Checkbox for ESO Trading Hub Sales Prices
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "ESO Trading Hub (Sales)",
            tooltip = "Show sales prices from ESO Trading Hub",
            getFunc = function() return GPP.savedVars.eths end,
            setFunc = function(value) GPP.savedVars.eths = value end,
            width = "full",
            default = GPP.defaults.eths,
        }
	)

	-- Checkbox for Master Merchant
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "Master Merchant",
            tooltip = "Show pricing info from Master Merchant",
            getFunc = function() return GPP.savedVars.mm end,
            setFunc = function(value) GPP.savedVars.mm = value end,
            width = "full",
            default = GPP.defaults.mm,
        }
	)

	-- Checkbox for Tamriel Trade Centre
	table.insert(
		optionsTable,
        {
            type = "checkbox",
            name = "Tamriel Trade Centre",
            tooltip = "Show pricing info from Tamriel Trade Centre",
            getFunc = function() return GPP.savedVars.ttc end,
            setFunc = function(value) GPP.savedVars.ttc = value end,
            width = "full",
            default = GPP.defaults.ttc,
        }
	)

	LAM:RegisterOptionControls(GPP.title, optionsTable)

end