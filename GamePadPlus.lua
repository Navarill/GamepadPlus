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
local GPP = GamePadPlus

GPP.name = "GamePadPlus"
GPP.title = "GamePad Plus"
GPP.author = "Sidrinius"
GPP.version = "1.0.0"
GPP.settings = {}

--------------------------------------------------
--|  FormattedNumber  |--
--------------------------------------------------
function FormattedNumber(amount)
	if not amount then
		return tostring(0)
	end
	
	if amount > 100 then
		return ZO_CommaDelimitNumber(zo_floor(amount))
	end

	return ZO_CommaDelimitDecimalNumber(zo_roundToNearest(amount, .01))
end

--------------------------------------------------
--|  AddInventoryPreInfo  |--
--------------------------------------------------
function AddInventoryPreInfo(tooltip, bagId, slotIndex)

    local itemLink = GetItemLink(bagId, slotIndex)      
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)

	--------------------------------------------------
	--|  Recipes  |--
	--------------------------------------------------	
    
	if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
	
		if(IsItemLinkRecipeKnown(itemLink)) then
			tooltip:AddLine(GetString(SI_RECIPE_ALREADY_KNOWN))
		else
			tooltip:AddLine(GetString(SI_USE_TO_LEARN_RECIPE))
		end
	end

	--------------------------------------------------
	--|  Arkadius' Trade Tools  |--
	--------------------------------------------------

	if GPP.settings.att and ArkadiusTradeTools then
		local avgPrice = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, nil, nil)
		if(avgPrice == nil or avgPrice == 0) then
			tooltip:AddLine(zo_strformat("|cf58585ATT No listing data|r"))
		else
			tooltip:AddLine(zo_strformat("|cf58585ATT price (avg): <<1>>|r", avgPrice))
        end
	end
	
	--------------------------------------------------
	--|  Master Merchant  |--
	--------------------------------------------------
	
	if GPP.settings.mm and MasterMerchant ~= nil then 
		local pricingData = MasterMerchant:itemStats(itemLink, false)
			local avgPrice = pricingData.avgPrice
			local numSales = pricingData.numSales
			local numDays = pricingData.numDays
			local numItems = pricingData.numItems
			local bonanzaPrice = pricingData.bonanzaPrice
			local bonanzaSales = pricingData.bonanzaSales
			local bonanzaCount = pricingData.bonanzaCount
		
		-- Sales Price
		if avgPrice ~= nil then
			avgPriceFormatted = FormattedNumber(avgPrice)
			if numSales > 1 then
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", numSales, numItems, numDays, avgPriceFormatted))
			else
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", numSales, numItems, numDays, avgPriceFormatted))
			end
		else
			tooltip:AddLine(zo_strformat("|c7171d1MM No listing data|r"))
		end
		
		-- Crafting Cost
		local craftCost = MasterMerchant:itemCraftPrice(itemLink)
		if craftCost ~= nil then
			craftCostFormatted = FormattedNumber(craftCost)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", craftCostFormatted))
		end

        -- Product Price
		if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local productPricingData = MasterMerchant:itemStats(resultItemLink, false)
				local productAvgPrice = productPricingData.avgPrice
				local productNumSales = productPricingData.numSales
				local productNumDays = productPricingData.numDays
				local productNumItems = productPricingData.numItems
				local productBonanzaPrice = productPricingData.bonanzaPrice
				local productBonanzaSales = productPricingData.bonanzaSales
				local productBonanzaCount = productPricingData.bonanzaCount
			
			if productAvgPrice ~= nil then
				productAvgPriceFormatted = FormattedNumber(productAvgPrice)
				if productNumSales > 1 then
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				else
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				end
			else
				tooltip:AddLine(zo_strformat("|c7171d1No product data|r"))
			end
		end	
	end
	
	--------------------------------------------------
	--|  Tamriel Trade Centre  |--
	--------------------------------------------------
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

--------------------------------------------------
--|  InventoryHook  |--
--------------------------------------------------
function InventoryHook(tooltip, method)
  local origMethod = tooltip[method]
  tooltip[method] = function(control, bagId, slotIndex, ...) 
    AddInventoryPreInfo(control, bagId, slotIndex, ...)
    origMethod(control, bagId, slotIndex, ...)            
  end
end

--------------------------------------------------
--|  InventoryMenuHook  |--
--------------------------------------------------
function InventoryMenuHook(tooltip, method) 
  local origMethod = tooltip[method]
  tooltip[method] = function(selectedData, ...) 
    origMethod(selectedData, ...)  
	if GPP.settings.invtooltip and tooltip.selectedEquipSlot then
		GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, BAG_WORN, tooltip.selectedEquipSlot)
	end
	  
  end
end

--------------------------------------------------
--|  LoadModules  |--
--------------------------------------------------
function LoadModules() 
	if(not _initialized) then
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutBagItem")
	InventoryMenuHook(GAMEPAD_INVENTORY, "UpdateCategoryLeftTooltip")
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutBagItem")
	InventoryHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutBagItem")

	_initialized = true
	
	end

end

--------------------------------------------------
--|  OnAddOnLoaded  |--
--------------------------------------------------
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

--------------------------------------------------
--|  Register Events  |--
--------------------------------------------------
EVENT_MANAGER:RegisterForEvent(GPP.name, EVENT_ADD_ON_LOADED, GPP.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(GPP.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad) LoadModules() end)
