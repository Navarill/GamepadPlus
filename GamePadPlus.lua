--[[
		GamePadPlus
		Gamepad UI enhancement for The Elder Scrolls Online
		License: The MIT License
		
		Based on RockingDice's GamePadBuddy (no longer maintained)
		https://www.esoui.com/downloads/info1773-GamePadBuddy.html
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

	if GPP.settings.att and ArkadiusTradeTools ~= nil then
		local ATTavgPrice = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, nil, nil)
		if(ATTavgPrice ~= nil or ATTavgPrice ~= 0) then
			tooltip:AddLine(zo_strformat("|cf58585ATT price: <<1>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", ATTavgPrice))
		else
			tooltip:AddLine(zo_strformat("|cf58585ATT No listing data|r"))
        end
	end
	
	--------------------------------------------------
	--|  Master Merchant  |--
	--------------------------------------------------
	
	if GPP.settings.mm and MasterMerchant ~= nil then 
		local MMpricingData = MasterMerchant:itemStats(itemLink, false)
		local MMavgPrice = MMpricingData.avgPrice
		local MMnumSales = MMpricingData.numSales
		local MMnumDays = MMpricingData.numDays
		local MMnumItems = MMpricingData.numItems
		--local MMbonanzaPrice = MMpricingData.bonanzaPrice
		--local MMbonanzaSales = MMpricingData.bonanzaSales
		--local MMbonanzaCount = MMpricingData.bonanzaCount
		
		-- Sales Price
		if (MMavgPrice ~= nil or MMavgPrice ~= 0) then
			MMavgPriceFormatted = FormattedNumber(MMavgPrice)
			if MMnumSales > 1 then
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", MMnumSales, MMnumItems, MMnumDays, MMavgPriceFormatted))
			else
				tooltip:AddLine(zo_strformat("|c7171d1MM price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", MMnumSales, MMnumItems, MMnumDays, MMavgPriceFormatted))
			end
		else
			tooltip:AddLine(zo_strformat("|c7171d1MM No listing data|r"))
		end
		
		-- Bonanza Price
		--[[ Bonanza price not supported by MM alias commands at this time (per Sharlikran 9/12/2021)
		if MMbonanzaPrice ~= nil then
			MMbonanzaPriceFormatted = FormattedNumber(MMbonanzaPrice)
			if bonanzaSales > 1 then
				tooltip:AddLine(zo_strformat("|c7171d1Bonanza price (<<1>> listings/<<2>> items): <<3>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", MMbonanzaSales, MMbonanzaCount, MMbonanzaPriceFormatted))
			else
				tooltip:AddLine(zo_strformat("|c7171d1Bonanza price (<<1>> listing/<<2>> items): <<3>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", MMbonanzaSales, MMbonanzaCount, MMbonanzaPriceFormatted))
			end
		else
			tooltip:AddLine(zo_strformat("|c7171d1No Bonanza price data|r"))
		end
		]]
		
		-- Crafting Cost
		local MMcraftCost = MasterMerchant:itemCraftPrice(itemLink)
		if MMcraftCost ~= nil then
			MMcraftCostFormatted = FormattedNumber(MMcraftCost)
			tooltip:AddLine(zo_strformat("|c7171d1Craft cost: <<1>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", MMcraftCostFormatted))
		end

        -- Product Price
		if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
			local MMresultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			local productMMpricingData = MasterMerchant:itemStats(resultItemLink, false)
			local productMMavgPrice = productPricingData.avgPrice
			local productMMnumSales = productPricingData.numSales
			local productMMnumDays = productPricingData.numDays
			local productMMnumItems = productPricingData.numItems
			--local productMMbonanzaPrice = productMMpricingData.bonanzaPrice
			--local productMMbonanzaSales = productMMpricingData.bonanzaSales
			--local productMMbonanzaCount = productMMpricingData.bonanzaCount
			
			if productAvgPrice ~= nil then
				productAvgPriceFormatted = FormattedNumber(productAvgPrice)
				if productNumSales > 1 then
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sales/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				else
					tooltip:AddLine(zo_strformat("|c7171d1Product price (<<1>> sale/<<2>> items, <<3>> days): <<4>>|t16:16:EsoUI/Art/currency/currency_gold.dds|t |r", productNumSales, productNumItems, productNumDays, productAvgPriceFormatted))
				end
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
