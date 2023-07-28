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
		if (attAvgPrice == nil or attAvgPrice == 0) then
			return
		else
			attAvgPriceFormatted = FormattedCurrency(attAvgPrice)
			tooltip:AddLine(zo_strformat("|cf58585ATT price: <<1>><<2>> |r", attAvgPriceFormatted, goldSymbol))
		end
	end

	-- ESO Trading Hub
	if GPP.settings.eth and LibEsoHubPrices then
		local ethPriceData = LibEsoHubPrices.GetItemPriceData(itemLink)

		if (ethPriceData == nil or ethPriceData == 0) then
			return
		else
			local ethSuggestedMin = ethPriceData.suggestedPriceMin
			local ethSuggestedMax = ethPriceData.suggestedPriceMax
			local ethAverage = ethPriceData.average
			local ethListings = ethPriceData.listings
			local ethPriceMax = ethPriceData.priceMax
			local ethPriceMin = ethPriceData.priceMin

			if (ethSuggestedMin == nil or ethSuggestedMax == nil or ethAverage == nil) then
				return
			else
				ethSuggestedMinFormatted = FormattedCurrency(ethSuggestedMin)
				ethSuggestedMaxFormatted = FormattedCurrency(ethSuggestedMax)
				ethAverageFormatted = FormattedCurrency(ethAverage)
				ethListingsFormatted = ZO_CommaDelimitNumber(zo_floor(ethListings))
				ethPriceMaxFormatted = FormattedCurrency(ethPriceMax)
				ethPriceMinFormatted = FormattedCurrency(ethPriceMin)

				tooltip:AddLine(zo_strformat("|c7171d1ESO-Hub average price: <<1>><<2>> |r", ethAverageFormatted, goldSymbol))
				tooltip:AddLine(zo_strformat("|c7171d1<<1>><<2>> - <<3>><<4>> in <<5>> listings |r", ethPriceMinFormatted, goldSymbol, ethPriceMaxFormatted, goldSymbol, ethListingsFormatted))
				tooltip:AddLine(zo_strformat("|c7171d1Suggested price: <<1>><<2>> - <<3>><<4>> |r", ethSuggestedMinFormatted, goldSymbol, ethSuggestedMaxFormatted, goldSymbol))
			end
		end
	end

	-- Master Merchant
	if GPP.settings.mm and (MasterMerchant and MasterMerchant.isInitialized ~= false) and (LibGuildStore and LibGuildStore.guildStoreReady ~=  false) then
		local pricingData = MasterMerchant:itemStats(itemLink, false)
		local avgPrice = pricingData.avgPrice
		local numSales = pricingData.numSales
		local numDays = pricingData.numDays
		local numItems = pricingData.numItems

		-- Sales Price
		if (avgPrice == nil or avgPrice == 0) then
			return
		else
			avgPriceFormatted = FormattedCurrency(avgPrice)
			numSalesFormatted = ZO_CommaDelimitNumber(zo_floor(numSales))
			numDaysFormatted = ZO_CommaDelimitNumber(zo_floor(numDays))
			numItemsFormatted = ZO_CommaDelimitNumber(zo_floor(numItems))

			tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", numSalesFormatted, numItemsFormatted, numDaysFormatted, avgPriceFormatted, goldSymbol))
		end

		-- Crafting Cost
		local craftCost, craftCostEach = MasterMerchant:itemCraftPrice(itemLink)

		if craftCost == nil then
			return

		elseif (itemType == ITEMTYPE_POTION) or (itemType == ITEMTYPE_POISON) then
			craftCostFormatted = FormattedCurrency(craftCost)
			craftCostEachFormatted = FormattedCurrency(craftCostEach)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>> (<<2>> each)<<3>> |r", craftCostFormatted,craftCostEachFormatted, goldSymbol))

		elseif ((itemType == ITEMTYPE_DRINK) or (itemType == ITEMTYPE_FOOD)
				or (itemType == ITEMTYPE_RECIPE and (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK))) then
			craftCostFormatted = FormattedCurrency(craftCost)
			craftCostEachFormatted = FormattedCurrency(craftCostEach)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>> (<<2>> each)<<3>> |r", craftCostFormatted,craftCostEachFormatted, goldSymbol))

		else
			craftCostFormatted = FormattedCurrency(craftCost)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>><<2>> |r", craftCostFormatted, goldSymbol))
		end

		-- Product Price
		if GPP.settings.recipes and avgPrice ~= nil and itemType == ITEMTYPE_RECIPE then
			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local productPricingData = MasterMerchant:itemStats(resultItemLink, false)
			local productAvgPrice = productPricingData.avgPrice
			local productNumSales = productPricingData.numSales
			local productNumDays = productPricingData.numDays
			local productNumItems = productPricingData.numItems

			if productAvgPrice ~= nil then
				productAvgPriceFormatted = FormattedCurrency(productAvgPrice)
				tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted, goldSymbol))
			end
		end
	end

	-- Tamriel Trade Centre
	if GPP.settings.ttc and TamrielTradeCentre ~= nil then
		local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)

		if (priceInfo == nil) then
			return
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