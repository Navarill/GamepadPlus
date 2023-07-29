--[[
		GamepadPlus
		Gamepad UI enhancement for display of market data
		License: (To Be Determined)
		Based on RockingDice's GamePadBuddy
		https://www.esoui.com/downloads/info1773-GamePadBuddy.html
		https://github.com/rockingdice/GamePadBuddy
]]

GamepadPlus = {}
local GPP = GamepadPlus

GPP.settings = {}
GPP.name = "GamepadPlus"
GPP.title = "Gamepad Plus"
GPP.author = "Navarill"
GPP.version = "2.1.0"

function FormattedCurrency(amount)
	-- Currency values less than 100 are rounded to two decimal places
	if amount < 100 then
		amount = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(amount, 0.01))
		return string.format("%.2f", amount)

	-- No decimals for currency values 100 or greater
	else
		return ZO_CommaDelimitNumber(zo_floor(amount))
	end
end

function AddInventoryPreInfo(tooltip, bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	goldSymbol = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"

	-- Recipes
	if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
		if(IsItemLinkRecipeKnown(itemLink)) then
			tooltip:AddLine(GetString(SI_RECIPE_ALREADY_KNOWN))
		else
			tooltip:AddLine(GetString(SI_USE_TO_LEARN_RECIPE))
		end
	end

	-- Arkadius' Trade Tools
	if GPP.settings.att and ArkadiusTradeTools then
		local attAvgPrice = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, nil, nil)

		if attAvgPrice > 0 then
			attAvgPriceFormatted = FormattedCurrency(attAvgPrice)
			tooltip:AddLine(zo_strformat("|cf58585ATT price: <<1>><<2>> |r", attAvgPriceFormatted, goldSymbol))
		end
	end

	-- ESO Trading Hub
	if GPP.settings.eth and LibEsoHubPrices then
		local PriceData = LibEsoHubPrices.GetItemPriceData(itemLink)

		if PriceData ~= nil then
			local suggMinPrice = PriceData.suggestedPriceMin
			local suggMaxPrice = PriceData.suggestedPriceMax
			local avgPrice = PriceData.average
			local numListings = PriceData.listings
			local maxPrice = PriceData.priceMax
			local minPrice = PriceData.priceMin

			--suggMinFormatted = FormattedCurrency(suggMinPrice)
			--suggMaxFormatted = FormattedCurrency(suggMaxPrice)
			--avgFormatted = FormattedCurrency(avgPrice)
			--numListingsFormatted = ZO_CommaDelimitNumber(zo_floor(numListings))
			--maxPriceFormatted = FormattedCurrency(maxPrice)
			--minPriceFormatted = FormattedCurrency(minPrice)

			if avgPrice ~= nil then
				tooltip:AddLine(zo_strformat("|cf23d8eESO-Hub average price: <<1>><<2>> |r", avgPrice, goldSymbol))
				tooltip:AddLine(zo_strformat("|cf23d8e<<1>><<2>> - <<3>><<4>> in <<5>> listings |r", minPrice, goldSymbol, maxPrice, goldSymbol, numListings))
				tooltip:AddLine(zo_strformat("|cf23d8eSuggested price: <<1>><<2>> - <<3>><<4>> |r", suggMinPrice, goldSymbol, suggMaxPrice, goldSymbol))
			end
		end
	end

	-- Master Merchant
	if GPP.settings.mm and (MasterMerchant and MasterMerchant.isInitialized ~= false) and (LibGuildStore and LibGuildStore.guildStoreReady ~=  false) then
		local mmPricingData = MasterMerchant:itemStats(itemLink, false)
		local mmAvgPrice = mmPricingData.avgPrice
		local mmNumSales = mmPricingData.numSales
		local mmNumDays = mmPricingData.numDays
		local mmNumItems = mmPricingData.numItems

		-- Sales Price
		if (mmAvgPrice == nil or mmAvgPrice == 0) then
			return
		else
			mmAvgPriceFormatted = FormattedCurrency(mmAvgPrice)
			mmNumSalesFormatted = ZO_CommaDelimitNumber(zo_floor(mmNumSales))
			mmNumDaysFormatted = ZO_CommaDelimitNumber(zo_floor(mmNumDays))
			mmNumItemsFormatted = ZO_CommaDelimitNumber(zo_floor(mmNumItems))

			tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", mmNumSalesFormatted, mmNumItemsFormatted, mmNumDaysFormatted, mmAvgPriceFormatted, goldSymbol))
		end

		-- Crafting Cost
		local mmCraftCost, mmCraftCostEach = MasterMerchant:itemCraftPrice(itemLink)

		if mmCraftCost == nil then
			return

		elseif (itemType == ITEMTYPE_POTION) or (itemType == ITEMTYPE_POISON) then
			mmCraftCostFormatted = FormattedCurrency(mmCraftCost)
			mmCraftCostEachFormatted = FormattedCurrency(mmCraftCostEach)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>> (<<2>> each)<<3>> |r", mmCraftCostFormatted, mmCraftCostEachFormatted, goldSymbol))

		elseif ((itemType == ITEMTYPE_DRINK) or (itemType == ITEMTYPE_FOOD)
				or (itemType == ITEMTYPE_RECIPE and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK))) then
			mmCraftCostFormatted = FormattedCurrency(mmCraftCost)
			mmCraftCostEachFormatted = FormattedCurrency(mmCraftCostEach)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>> (<<2>> each)<<3>> |r", mmCraftCostFormatted, mmCraftCostEachFormatted, goldSymbol))

		else
			mmCraftCostFormatted = FormattedCurrency(mmCraftCost)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>><<2>> |r", mmCraftCostFormatted, goldSymbol))
		end

		-- Product Price
		if GPP.settings.recipes and avgPrice ~= nil and itemType == ITEMTYPE_RECIPE then
			local mmResultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local mmProductPricingData = MasterMerchant:itemStats(mmResultItemLink, false)
			local mmProductAvgPrice = mmProductPricingData.avgPrice
			local mmProductNumSales = mmProductPricingData.numSales
			local mmProductNumDays = mmProductPricingData.numDays
			local mmProductNumItems = mmProductPricingData.numItems

			if mmProductAvgPrice ~= nil then
				mmProductAvgPriceFormatted = FormattedCurrency(mmProductAvgPrice)
				tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", mmProductNumSales, mmProductNumItems, mmProductNumDays, mmProductAvgPriceFormatted, goldSymbol))
			end
		end
	end

	-- Tamriel Trade Centre
	if GPP.settings.ttc and TamrielTradeCentre ~= nil then
		local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)

		if (priceInfo == nil) then
			tooltip:AddLine(zo_strformat("|cf23d8eTTC <<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA)))
		else
			if (priceInfo.SuggestedPrice ~= nil) then
				tooltip:AddLine(zo_strformat("|cf23d8eTTC <<1>>|r", string.format(GetString(TTC_PRICE_SUGGESTEDXTOY),
						TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))))
			end

			if (true) then
				tooltip:AddLine(zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg),
						TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max))))
			end

			if (true) then
				if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
					tooltip:AddLine(zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))))
					tooltip:AddLine()
				else
					tooltip:AddLine(zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))))
				end
			end
		end

		if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then

			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(resultItemLink)

			if (priceInfo == nil) then
				tooltip:AddLine(zo_strformat("|cf23d8eProduct <<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA)))
			else
				if (priceInfo.SuggestedPrice ~= nil) then
					tooltip:AddLine(zo_strformat("|cf23d8eProduct <<1>>|r", string.format(GetString(TTC_PRICE_SUGGESTEDXTOY),
							TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice, 0), TamrielTradeCentre:FormatNumber(priceInfo.SuggestedPrice * 1.25, 0))))
				end

				if (true) then
					tooltip:AddLine(zo_strformat("|cf23d8eProduct <<1>>|r", string.format(GetString(TTC_PRICE_AGGREGATEPRICESXYZ), TamrielTradeCentre:FormatNumber(priceInfo.Avg),
							TamrielTradeCentre:FormatNumber(priceInfo.Min), TamrielTradeCentre:FormatNumber(priceInfo.Max))))
				end

				if (true) then
					if (priceInfo.EntryCount ~= priceInfo.AmountCount) then
						tooltip:AddLine(zo_strformat("|cf23d8eProduct <<1>>|r", string.format(GetString(TTC_PRICE_XLISTINGSYITEMS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount), TamrielTradeCentre:FormatNumber(priceInfo.AmountCount))))
						tooltip:AddLine()
					else
						tooltip:AddLine(zo_strformat("|cf23d8eProduct <<1>>|r", string.format(GetString(TTC_PRICE_XLISTINGS), TamrielTradeCentre:FormatNumber(priceInfo.EntryCount))))
					end
				end
			end
		end
	end
end

function InventoryHook(tooltip, method)
	local origMethod = tooltip[method]
	tooltip[method] = function(control, bagId, slotIndex, ...)
		AddInventoryPreInfo(control, bagId, slotIndex, ...)
		origMethod(control, bagId, slotIndex, ...)
	end
end

function InventoryMenuHook(tooltip, method)
	local origMethod = tooltip[method]
	tooltip[method] = function(selectedData, ...)
		origMethod(selectedData, ...)
		if GPP.settings.invtooltip and tooltip.selectedEquipSlot then
			GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, tooltip.selectedEquipSlot)
		end
	end
end

function InventoryCompanionMenuHook(tooltip, method)
	local origMethod = tooltip[method]
	tooltip[method] = function(selectedData, ...)
		origMethod(selectedData, ...)
		if GPP.settings.invtooltip and tooltip.selectedEquipSlot then
			GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_COMPANION_WORN, tooltip.selectedEquipSlot)
		end
	end
end

function LoadModules()
	if(not _initialized) then
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutBagItem")
	InventoryMenuHook(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
	InventoryCompanionMenuHook(COMPANION_EQUIPMENT_GAMEPAD, "UpdateCategoryLeftTooltip")
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutBagItem")
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutBagItem")

	_initialized = true
	end
end

function GPP.OnAddOnLoaded(eventCode, addOnName)
	if (addOnName ~= GPP.name) then return end
	EVENT_MANAGER:UnregisterForEvent(GPP.name, eventCode)

	GPP:SettingsSetup()

	if(IsInGamepadPreferredMode()) then
		LoadModules()
	else
		_initialized = false
	end
end

EVENT_MANAGER:RegisterForEvent(GPP.name, EVENT_ADD_ON_LOADED, GPP.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GPP.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad) LoadModules() end)