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
local addon = GamePadPlus

addon.name = "GamePadPlus"
addon.title = "GamePad Plus"
addon.author = "Sidrinius"
addon.version = "1.0.0"
addon.settings = {}

--------------------------------------------------
--|  AddInventoryPreInfo  |--
--------------------------------------------------
function AddInventoryPreInfo(tooltip, bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)      
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    
	--if addon.settings.recipes and itemType == ITEMTYPE_RECIPE then
	--[[
	if itemType == ITEMTYPE_RECIPE then
		if(IsItemLinkRecipeKnown(itemLink)) then
			tooltip:AddLine(GetString(SI_RECIPE_ALREADY_KNOWN))
		else
			tooltip:AddLine(GetString(SI_USE_TO_LEARN_RECIPE))
		end
	end
	]]--
	
	--------------------------------------------------
	--|  Arkadius' Trade Tools  |--
	--------------------------------------------------

	--[[
	if addon.settings.att and ArkadiusTradeTools ~= nil then
		--tooltip:AddLine(zo_strformat("|r"))
		tooltip:AddLine(zo_strformat("|cf58585ATT:|r"))
		tooltip:AddLine(zo_strformat("|cf58585No listing data|r"))
		--tooltip:AddLine(zo_strformat("|r"))
	end
	]]--

	--[[
	if addon.settings.att and ArkadiusTradeTools then 
		local priceLine, statusLine = GetATTPriceAndStatus(itemLink)
		tooltip:AddLine(zo_strformat("|cf58585ATT:|r"))
		tooltip:AddLine(zo_strformat("|cf58585<<1>>|r", priceLine))
		tooltip:AddLine(zo_strformat("|cf58585<<1>>|r", statusLine))
	end
	]]--
	
	--------------------------------------------------
	--|  Master Merchant  |--
	--------------------------------------------------
	
	if addon.settings.mm and MasterMerchant ~= nil then 
		--tooltip:AddLine(zo_strformat("|r"))
		tooltip:AddLine(zo_strformat("|c7171d1MM:|r"))
		local tipLine, avePrice, graphInfo = MasterMerchant:itemPriceTip(itemLink, false, false)
		if(tipLine ~= nil) then
			tooltip:AddLine(zo_strformat("|c7171d1<<1>>|r", tipLine))
		else
			tooltip:AddLine(zo_strformat("|c7171d1No listing data|r"))
		end

		local craftInfo = MasterMerchant:itemCraftPriceTip(itemLink)
		if craftInfo ~= nil then
			tooltip:AddLine(zo_strformat("|c7171d1<<1>>|r", craftInfo)) 
		end

        if addon.settings.recipes and itemType == ITEMTYPE_RECIPE then
			local resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
			
			local tipLine, avePrice, graphInfo = MasterMerchant:itemPriceTip(resultItemLink, false, false)
			if(tipLine ~= nil) then
				tooltip:AddLine(zo_strformat("|c7171d1Product <<1>>|r", tipLine))  
			else
				--tooltip:AddLine(zo_strformat("|c7171d1Product MM price (0 sales, 0 days): UNKNOWN|r"))
				tooltip:AddLine(zo_strformat("|c7171d1No listing data|r"))
			end
		end
	end
	
	--------------------------------------------------
	--|  Tamriel Trade Centre  |--
	--------------------------------------------------
    if addon.settings.ttc and TamrielTradeCentre ~= nil then
		tooltip:AddLine(zo_strformat("|cf23d8eTTC:|r"))
		local itemInfo = TamrielTradeCentre_ItemInfo:New(itemLink)
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemInfo)
    
        if (priceInfo == nil) then
			tooltip:AddLine(zo_strformat("|cf23d8e<<1>>|r", GetString(TTC_PRICE_NOLISTINGDATA)))
        else
          if (priceInfo.SuggestedPrice ~= nil) then
			tooltip:AddLine(zo_strformat("|cf23d8e<<1>>|r", string.format(GetString(TTC_PRICE_SUGGESTEDXTOY), 
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
 
        if addon.settings.recipes and itemType == ITEMTYPE_RECIPE then
		
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
	if addon.settings.invtooltip and tooltip.selectedEquipSlot then
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
function addon.OnAddOnLoaded(eventCode, addOnName)
	
	if (addOnName ~= addon.name) then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, eventCode)

	addon:SettingsSetup()
	
	if(IsInGamepadPreferredMode()) then
		LoadModules()
	else
		_initialized = false
	end

end

--------------------------------------------------
--|  Register Events  |--
--------------------------------------------------
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, addon.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function(code, inGamepad) LoadModules() end)
