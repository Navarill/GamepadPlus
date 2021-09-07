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
		local tipLine, avePrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, false)
		if(tipLine ~= nil) then
			tooltip:AddLine(zo_strformat("|c7171d1<<1>>|r", tipLine))
		else
			tooltip:AddLine(zo_strformat("|c7171d1MM No listing data|r"))
		end

		local craftInfo = MasterMerchant:CraftCostPriceTip(itemLink, false)
		if craftInfo ~= nil then
			tooltip:AddLine(zo_strformat("|c7171d1<<1>>|r", craftInfo))
		end

        if GPP.settings.recipes and itemType == ITEMTYPE_RECIPE then
			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			
			local tipLine, avePrice, graphInfo = MasterMerchant:itemPriceTip(resultItemLink, false, false)
			if(tipLine ~= nil) then
				tooltip:AddLine(zo_strformat("|c7171d1Product <<1>>|r", tipLine))  
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
