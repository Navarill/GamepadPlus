--[[
		GamepadPlus
		Gamepad UI enhancement for The Elder Scrolls Online
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
		return ZO_CommaDelimitDecimalNumber(zo_roundToNearest(amount, 0.01))

	-- No decimals for currency values 100 or greater
	else
		return ZO_CommaDelimitNumber(zo_floor(amount))
	end
end

function AddInventoryPreInfo(tooltip, bagId, slotIndex)

    local itemLink = GetItemLink(bagId, slotIndex)
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)

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
		if (avgPrice == nil or avgPrice == 0) then
			tooltip:AddLine(zo_strformat("|cf58585ATT No listing data|r"))
		else
			avgPriceFormatted = FormattedCurrency(avgPrice)
			tooltip:AddLine(zo_strformat("|cf58585ATT price: <<1>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", avgPriceFormatted))
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
		if avgPrice ~= nil then
			avgPriceFormatted = FormattedCurrency(avgPrice)
			numSalesFormatted = ZO_CommaDelimitNumber(zo_floor(numSales))
			numDaysFormatted = ZO_CommaDelimitNumber(zo_floor(numDays))
			numItemsFormatted = ZO_CommaDelimitNumber(zo_floor(numItems))

			if numSales > 1 then
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", numSalesFormatted, numItemsFormatted, numDaysFormatted, avgPriceFormatted))
			else
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", numSalesFormatted, numItemsFormatted, numDaysFormatted, avgPriceFormatted))
			end
		else
			tooltip:AddLine(zo_strformat("|c7171d1MM No listing data|r"))
		end

		-- Crafting Cost
		if avgPrice ~= nil then
			local craftCost = MasterMerchant:itemCraftPrice(itemLink)
			if craftCost ~= nil then
				craftCostFormatted = FormattedCurrency(craftCost)
				tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", craftCostFormatted))
			end
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
				if productNumSales > 1 then
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				else
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				end
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
