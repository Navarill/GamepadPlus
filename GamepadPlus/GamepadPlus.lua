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
GPP.version = "2.1.1"

function FormatNumber(value, type)
	if type == "currency" and value < 100 then
		value = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(value, 0.01))
		return string.format("%.2f", value)
	else
		return ZO_CommaDelimitNumber(zo_floor(value))
	end
end

function AddInventoryPreInfo(tooltip, bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)
	local symbolGold = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"

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
		local avgPrice = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, nil, nil)

		if avgPrice ~= nil and avgPrice ~= 0 then
			tooltip:AddLine(zo_strformat("|cf58585ATT price: <<1>><<2>> |r", FormatNumber(avgPrice, "currency"), symbolGold))
		end
	end

	-- ESO Trading Hub
	-- ESO Trading Hub is work in progress. Solinur working on itemLink inconsistency in API.
	if GPP.settings.eth and LibEsoHubPrices then
		local priceData = LibEsoHubPrices.GetItemPriceData(itemLink)

		if priceData ~= nil and priceData ~= 0 then
			local suggMinPrice = priceData.suggestedPriceMin
			local suggMaxPrice = priceData.suggestedPriceMax
			local avgPrice = priceData.average
			local numListings = priceData.listings
			local maxPrice = priceData.priceMax
			local minPrice = priceData.priceMin

			tooltip:AddLine(zo_strformat("|cf23d8eESO-Hub average price: <<1>><<2>> |r", FormatNumber(avgPrice, "currency"), symbolGold))
			tooltip:AddLine(zo_strformat("|cf23d8e<<1>><<2>> - <<3>><<4>> in <<5>> listings |r", FormatNumber(minPrice, "currency"), symbolGold, FormatNumber(maxPrice, "currency"), symbolGold, FormatNumber(numListings)))

			if suggMinPrice ~= nil and suggMaxPrice ~= nil then
				tooltip:AddLine(zo_strformat("|cf23d8eSuggested price: <<1>><<2>> - <<3>><<4>> |r", FormatNumber(suggMinPrice, "currency"), symbolGold, FormatNumber(suggMaxPrice, "currency"), symbolGold))
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

		if avgPrice ~= nil and avgPrice ~= 0 then
			tooltip:AddLine(zo_strformat("|c7171d1MM price: (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", FormatNumber(numSales), FormatNumber(numItems), FormatNumber(numDays), FormatNumber(avgPrice, "currency"), symbolGold))
		end

		-- Crafting Cost
		local craftCost, craftCostEach = MasterMerchant:itemCraftPrice(itemLink)

		if craftCost ~= nil and craftCost ~= 0 and craftCostEach ~= nil and craftCostEach ~= 0 then
			if (itemType == ITEMTYPE_POTION) or (itemType == ITEMTYPE_POISON) then
				tooltip:AddLine(zo_strformat("|c7171d1MM Craft cost: <<1>> (<<2>> each)<<3>> |r", FormatNumber(craftCost, "currency"), FormatNumber(craftCostEach, "currency"), symbolGold))

            elseif ((itemType == ITEMTYPE_DRINK) or (itemType == ITEMTYPE_FOOD) or
						(itemType == ITEMTYPE_RECIPE and
							(specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or
                            specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK))) then
				tooltip:AddLine(zo_strformat("|c7171d1MM Craft cost: <<1>> (<<2>> each)<<3>> |r", FormatNumber(craftCost, "currency"), FormatNumber(craftCostEach, "currency"), symbolGold))

            else
            	tooltip:AddLine(zo_strformat("|c7171d1MM Craft cost: <<1>><<2>> |r", FormatNumber(craftCost, "currency"), symbolGold))
            end
		end

		-- Product Price
		if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local productPricingData = MasterMerchant:itemStats(resultItemLink, false)
			local productAvgPrice = productPricingData.avgPrice
			local productNumSales = productPricingData.numSales
			local productNumDays = productPricingData.numDays
			local productNumItems = productPricingData.numItems

			if productAvgPrice ~= nil then
				tooltip:AddLine(zo_strformat("|c7171d1MM Product price (<<1[no sales/1 sale/$d sales]>>/<<2[no items/1 item/$d items]>>, <<3[no days/1 day/$d days]>>): <<4>><<5>> |r", FormatNumber(productNumSales), FormatNumber(productNumItems), FormatNumber(productNumDays), FormatNumber(productAvgPrice, "currency"), symbolGold))
			end
		end
	end

	-- Tamriel Trade Centre
	-- TODO: Cleanup TTC code
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