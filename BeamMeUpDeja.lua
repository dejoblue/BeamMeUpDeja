--SavedVariables Setup
local BeamMeUpDeja, private = ...
local mapName
local basewidth = 236
local baseheight = 192
local buttonSize = 36;
local padding = 4;
local perRow = 6;
local BMUDRarity
local BMUDItemName
local ShowHideButtonShownCheck
local BMUDRarityTable = {}

private.defaults = {
    -- If you have any general settings for you addon,
    -- list them here, or just leave the table empty.
}

local SEARCHED_ITEMS = {
	--Other
    [147729] = "",	-- Netherchunk

	-- Epics
    [146921] = "",	-- Illisthyndria
    [146920] = "",	-- Fel Obliterator
    [146919] = "",	-- An'thyna:An'thyna
    [146918] = "",	-- Force-Commander Xillious
    [146917] = "",	-- Skulguloth
    [146916] = "",	-- Than'otalion
	
    -- Rares
    [146915] = "",	-- Greater Torment
    [146914] = "",	-- Greater Engineering
    [146913] = "",	-- Greater Warbeasts
    [146912] = "",	-- Greater Carnage
    [146911] = "",	-- Greater Firestorm
    [146910] = "",	-- Greater Dominance
	-- Crafting Rares
	[147355] = "",	-- Bloodstrike
	[146923] = "",	-- Petrification
	[146922] = "",	-- Fel growth
    
    -- Uncommons
    [146909] = "",	-- Torment
    [146908] = "",	-- Engineering
    [146907] = "",	-- Warbeasts
    [146906] = "",	-- Carnage
    [146905] = "",	-- Firestorm
    [146903] = "",	-- Dominance
}

local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "BeamMeUpDeja" then
			local function initDB(db, defaults)
				if type(db) ~= "table" then db = {} end
				if type(defaults) ~= "table" then return db end
				for k, v in pairs(defaults) do
					if type(v) == "table" then
						db[k] = initDB(db[k], v)
					elseif type(v) ~= type(db[k]) then
						db[k] = v
					end
				end
			return db
			end

		BeamMeUpDejaDBPC = initDB(BeamMeUpDejaDBPC, private.defaults)
		private.db = BeamMeUpDejaDBPC -- add this
		self:UnregisterEvent("ADDON_LOADED")
		-- Don't place any frames here
		end
	end)

BeamMeUpDeja = {};

local _, private = ...
	private.defaults.optpanelDefaults = {
		point = "RIGHT", 
		relativeTo = "UIParent", 
		relativePoint = "RIGHT", 
		xOffset = 0, 
		yOffset = 0,
	}	
	
BeamMeUpDeja.panel = CreateFrame( "Frame", "BeamMeUpDejaPanel", UIParent );
-- Register in the Interface Addon Options GUI
-- Set the name for the Category for the Options Panel
BeamMeUpDeja.panel.name = "BeamMeUpDeja";
-- Add the panel to the Interface Options
InterfaceOptions_AddCategory(BeamMeUpDeja.panel);

-- Make a child panel
-- BeamMeUpDeja.childpanel = CreateFrame( "Frame", "BeamMeUpDejaChild", BeamMeUpDeja.panel);
-- BeamMeUpDeja.childpanel.name = "MyChild";
-- Specify childness of this panel (this puts it under the little red [+], instead of giving it a normal AddOn category)
-- BeamMeUpDeja.childpanel.parent = BeamMeUpDeja.panel.name;
-- Add the child to the Interface Options
-- InterfaceOptions_AddCategory(BeamMeUpDeja.childpanel);

--Panel Title
local BMUDtitle=CreateFrame("Frame", "BMUDtitle", BeamMeUpDejaPanel)
	BMUDtitle:SetPoint("TOPLEFT", 5, -5)
	BMUDtitle:SetScale(2.0)
	BMUDtitle:SetWidth(150)
	BMUDtitle:SetHeight(50)
	BMUDtitle:Show()

local BMUDtitleFS = BMUDtitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BMUDtitleFS:SetText('|cff00c0ffBeamMeUpDeja|r')
	BMUDtitleFS:SetPoint("TOPLEFT", 0, 0)
	BMUDtitleFS:SetFont("Fonts\\FRIZQT__.TTF", 10)
	
local BMUDresetcheck = CreateFrame("Button", "BMUDResetButton", BeamMeUpDejaPanel, "UIPanelButtonTemplate")
	BMUDresetcheck:ClearAllPoints()
	BMUDresetcheck:SetPoint("BOTTOMLEFT", 5, 5)
	BMUDresetcheck:SetScale(1.25)
	BMUDresetcheck:SetWidth(125)
	BMUDresetcheck:SetHeight(30)
	_G[BMUDresetcheck:GetName() .. "Text"]:SetText("Reset to Default")
	BMUDresetcheck:SetScript("OnClick", function (self, button, down)
 		BeamMeUpDejaDBPC = private.defaults;
		ReloadUI();
end)

--Open Categaories Fix
do
	local function get_panel_name(panel)
		local tp = type(panel)
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		if tp == "string" then
			for i = 1, #cat do
				local p = cat[i]
				if p.name == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel
					end
				end
			end
		elseif tp == "table" then
			for i = 1, #cat do
				local p = cat[i]
				if p == panel then
					if p.parent then
						return get_panel_name(p.parent)
					else
						return panel.name
					end
				end
			end
		end
	end

	local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
		if doNotRun or InCombatLockdown() then return end
		local panelName = get_panel_name(panel)
		if not panelName then return end -- if its not part of our list return early
		local noncollapsedHeaders = {}
		local shownpanels = 0
		local mypanel
		local t = {}
		local cat = INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, #cat do
			local panel = cat[i]
			if not panel.parent or noncollapsedHeaders[panel.parent] then
				if panel.name == panelName then
					panel.collapsed = true
					t.element = panel
					InterfaceOptionsListButton_ToggleSubCategories(t)
					noncollapsedHeaders[panel.name] = true
					mypanel = shownpanels + 1
				end
				if not panel.collapsed then
					noncollapsedHeaders[panel.name] = true
				end
				shownpanels = shownpanels + 1
			end
		end
		local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
		if shownpanels > 15 and Smin < Smax then 
		  local val = (Smax/(shownpanels-15))*(mypanel-2)
		  InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
		end
		doNotRun = true
		InterfaceOptionsFrame_OpenToCategory(panel)
		doNotRun = false
	end

	hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

--BMUD Slash Setup
local RegisteredEvents = {};
local BMUDslash = CreateFrame("Frame", "BeamMeUpDejaSlash", UIParent)

BMUDslash:SetScript("OnEvent", function (self, event, ...) 
	if (RegisteredEvents[event]) then 
	return RegisteredEvents[event](self, event, ...) 
	end
end)

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "BeamMeUpDeja") then
		SLASH_BEAMMEUPDEJA1 = '/bmud'
		SlashCmdList["BeamMeUpDeja"] = function (msg, editbox)
			BeamMeUpDeja.SlashCmdHandler(msg, editbox)	
		end
		DEFAULT_CHAT_FRAME:AddMessage("BeamMeUpDeja loaded successfully. Type /bmud for usage",0,192,255)
	end
end

for k, v in pairs(RegisteredEvents) do
	BMUDslash:RegisterEvent(k)
end

function BeamMeUpDeja.ShowHelp()
	DEFAULT_CHAT_FRAME:AddMessage("BeamMeUpDeja Slash commands (/bmud):",0,192,255)
	DEFAULT_CHAT_FRAME:AddMessage("  /bmud config: Open the BeamMeUpDeja addon config menu.",0,192,255)
	DEFAULT_CHAT_FRAME:AddMessage("  /bmud reset:  Resets BeamMeUpDeja frames to default positions.",0,192,255)
end

function BeamMeUpDeja.SetConfigToDefaults()
	print("Resetting config to defaults")
	BeamMeUpDejaDBPC = DefaultConfig
	RELOADUI()
end

function BeamMeUpDeja.GetConfigValue(key)
	return BeamMeUpDejaDBPC[key]
end

function BeamMeUpDeja.PrintPerformanceData()
	UpdateAddOnMemoryUsage()
	local mem = GetAddOnMemoryUsage("BeamMeUpDeja")
	print("BeamMeUpDeja is currently using " .. mem .. " kbytes of memory")
	collectgarbage(collect)
	UpdateAddOnMemoryUsage()
	mem = GetAddOnMemoryUsage("BeamMeUpDeja")
	print("BeamMeUpDeja is currently using " .. mem .. " kbytes of memory after garbage collection")
end

function BeamMeUpDeja.SlashCmdHandler(msg, editbox)
	--print("command is " .. msg .. "\n")
	if (string.lower(msg) == "config") then
		InterfaceOptionsFrame_OpenToCategory("BeamMeUpDeja");
	elseif (string.lower(msg) == "dumpconfig") then
		print("With defaults")
		for k,v in pairs(BMUDDefaultConfig) do
			print(k,BeamMeUpDeja.GetConfigValue(k))
		end
		print("Direct table")
		for k,v in pairs(BMUDDefaultConfig) do
			print(k,v)
		end
	elseif (string.lower(msg) == "lock") then
		BMUDlockcheckframe:Hide()
		BMUDlockcheck:SetChecked(true)
	elseif (string.lower(msg) == "unlock") then
		BMUDlockcheckframe:Show()
		BMUDlockcheck:SetChecked(false)
	elseif (string.lower(msg) == "reset") then
		BeamMeUpDejaDBPC = private.defaults;
		ReloadUI();
	elseif (string.lower(msg) == "perf") then
		BeamMeUpDeja.PrintPerformanceData()
	else
		BeamMeUpDeja.ShowHelp()
	end
end
	SlashCmdList["BEAMMEUPDEJA"] = BeamMeUpDeja.SlashCmdHandler;

	private.defaults.BMUDsliderSetScale = {
	BMUDScale = 1.0, 

}	

-- BMUD Slider:
local BMUDSlider = CreateFrame("Slider", "BMUDSlider", BeamMeUpDejaPanel, "OptionsSliderTemplate")
	BMUDSlider:RegisterEvent("PLAYER_LOGIN")
	BMUDSlider:RegisterEvent("PLAYER_ENTERING_WORLD")
	BMUDSlider:RegisterEvent("ADDON_LOADED")
	BMUDSlider:SetPoint("CENTER", BeamMeUpDejaPanel, "CENTER", 0, 0)
	BMUDSlider:SetWidth(200)
	BMUDSlider:SetHeight(10)
	BMUDSlider:SetOrientation('HORIZONTAL')
	BMUDSlider:SetMinMaxValues(0.50, 3.0)
	BMUDSlider.minValue, BMUDSlider.maxValue = BMUDSlider:GetMinMaxValues() 
	BMUDSlider:SetValueStep(0.05)
	BMUDSlider:SetObeyStepOnDrag(true)

	BMUDSlider.tooltipText = 'Scale the minimap in increments or decrements of 5' --Creates a tooltip on mouseover.

	getglobal(BMUDSlider:GetName() .. 'Low'):SetText(BMUDSlider.minValue); --Sets the left-side slider text (default is "Low").
	getglobal(BMUDSlider:GetName() .. 'High'):SetText(BMUDSlider.maxValue); --Sets the right-side slider text (default is "High").

	BMUDSlider:Show()
			
	BMUDSlider:SetScript("OnEvent", function(self, event, arg1)
		if event == "PLAYER_LOGIN" then
		local slideValue = private.db.BMUDsliderSetScale.BMUDScale
		--print(slideValue)--Debugging
			self:SetValue(slideValue)
			BeamMeUpDejaDragFrame:SetScale(slideValue)
			getglobal(BMUDSlider:GetName() .. 'Text'):SetFormattedText("BeamMeUpDeja Scale = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		end
	end)

	BMUDSlider:SetScript("OnValueChanged", function(self, value)
		local slideValue = BMUDSlider:GetValue()
		BeamMeUpDejaDragFrame:SetScale(slideValue)
		getglobal(BMUDSlider:GetName() .. 'Text'):SetFormattedText("BeamMeUpDeja Scale = (%.2f)", (slideValue)); --Sets the "title" text (top-centre of slider).
		private.db.BMUDsliderSetScale.BMUDScale = slideValue
	end)	

-- BeamMeUpDeja
local name,addon = ...
local _, gdbprivate = ...

	-- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, 
	-- itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = 
	-- GetItemInfo(itemID or "itemString" or "itemName" or "itemLink")

local function ddebug()
	local status = issecurevariable("BMUDButton")
	local info = "Frame is %s tainted"
	local addend = ""
	if status then addend = "not" end
	info = format(info,addend)
	print(info," on loop")
end

private.defaults.BMUDDragFrameSetPoints = {
	point = "CENTER", 
	relativeTo = "UIParent", 
	relativePoint = "CENTER", 
	xOffset = 0, 
	yOffset = 0,
}	
	
local BeamMeUpDejaDragFrame = CreateFrame("Frame", "BeamMeUpDejaDragFrame", UIParent)
	BeamMeUpDejaDragFrame:RegisterEvent("PLAYER_LOGIN")
	BeamMeUpDejaDragFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	BeamMeUpDejaDragFrame:RegisterEvent("ADDON_LOADED")
	BeamMeUpDejaDragFrame:RegisterEvent("ZONE_CHANGED")
	BeamMeUpDejaDragFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	BeamMeUpDejaDragFrame:RegisterEvent("WORLD_MAP_UPDATE")
	BeamMeUpDejaDragFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	BeamMeUpDejaDragFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	
	BeamMeUpDejaDragFrame:SetClampedToScreen(true)
	BeamMeUpDejaDragFrame:ClearAllPoints()
	BeamMeUpDejaDragFrame:SetPoint("CENTER", UIParent, 0, 0)
	BeamMeUpDejaDragFrame:SetSize(basewidth, baseheight)
	BeamMeUpDejaDragFrame:Show()

	--Basic draggable frames
	BeamMeUpDejaDragFrame:SetMovable(true)
	--BeamMeUpDejaDragFrame:EnableMouse(true)
	BeamMeUpDejaDragFrame:RegisterForDrag("LeftButton","RightButton")
	
	--Debugging Texture
	--local BeamMeUpDejaDragFrametexture=BeamMeUpDejaDragFrame:CreateTexture(nil,"ARTWORK")
	--BeamMeUpDejaDragFrametexture:SetAllPoints(BeamMeUpDejaDragFrame)
	--BeamMeUpDejaDragFrametexture:SetColorTexture(1, 1, 1, 0.7)

	BeamMeUpDejaDragFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			local point = private.db.BMUDDragFrameSetPoints
			self:ClearAllPoints()		
			self:SetPoint(
				point.point, 
				point.relativeTo, 
				point.relativePoint, 
				point.xOffset, 
				point.yOffset)
		end
		if event == "MODIFIER_STATE_CHANGED" then
			if IsShiftKeyDown() or  IsControlKeyDown() then
				self:EnableMouse(true)
				--print("mod down")
			else
				self:EnableMouse(false)
				self:StopMovingOrSizing() 
				--print("mod up")
			end
		end
	end)

	BeamMeUpDejaDragFrame:SetScript("OnDragStart", BeamMeUpDejaDragFrame.StartMoving) 
	
	BeamMeUpDejaDragFrame:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing() 
		self:SetUserPlaced(false) 
		
		point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
			if ( relativeTo ) then
				relativeTo = relativeTo:GetName();
			else
				relativeTo = self:GetParent():GetName();
			end
	
		-- These are debugging messages for the frame points
		-- DEFAULT_CHAT_FRAME:AddMessage(point)
		-- DEFAULT_CHAT_FRAME:AddMessage(relativeTo)
		-- DEFAULT_CHAT_FRAME:AddMessage(relativePoint)
		-- DEFAULT_CHAT_FRAME:AddMessage(xOfs)
		-- DEFAULT_CHAT_FRAME:AddMessage(yOfs)

		private.db.BMUDDragFrameSetPoints.point = point
		private.db.BMUDDragFrameSetPoints.relativeTo = relativeTo
		private.db.BMUDDragFrameSetPoints.relativePoint = relativePoint
		private.db.BMUDDragFrameSetPoints.xOffset = xOfs
		private.db.BMUDDragFrameSetPoints.yOffset = yOfs			
	end)
	
	
local BeamMeUpDejaHideFrame = CreateFrame("Frame", "BeamMeUpDejaHideFrame", BeamMeUpDejaDragFrame)
	BeamMeUpDejaHideFrame:RegisterEvent("PLAYER_LOGIN")
	BeamMeUpDejaHideFrame:SetClampedToScreen(true)
	BeamMeUpDejaHideFrame:ClearAllPoints()
	BeamMeUpDejaHideFrame:SetPoint("BOTTOMLEFT", BeamMeUpDejaDragFrame)
	BeamMeUpDejaHideFrame:SetSize(basewidth, baseheight)

	
	--Debugging Texture
	--local BeamMeUpDejaHideFrametexture=BeamMeUpDejaHideFrame:CreateTexture(nil,"ARTWORK")
	--BeamMeUpDejaHideFrametexture:SetAllPoints(BeamMeUpDejaHideFrame)
	--BeamMeUpDejaHideFrametexture:SetColorTexture(0, 0.75, 1, 0.7)


private.defaults.BMUDShowHideButtonChecked = {
	BMUDShowHideButtonShownCheck = true,
}	

local function BeamMeUpDejaShowHideTooltipChangeText()
	GameTooltip:SetOwner(BeamMeUpDejaShowHideButton, "ANCHOR_RIGHT");
	GameTooltip:SetText(BeamMeUpDejaShowHideButtontooltipText, 1, 1, 1, 1, true)
end

local BeamMeUpDejaShowHideButton = CreateFrame("Button", "BeamMeUpDejaShowHideButton", BeamMeUpDejaDragFrame, "UIPanelButtonGrayTemplate")
	BeamMeUpDejaShowHideButton:RegisterEvent("PLAYER_LOGIN")
	BeamMeUpDejaShowHideButton:ClearAllPoints()
	BeamMeUpDejaShowHideButton:SetPoint("BOTTOMLEFT", BeamMeUpDejaHideFrame, -2, 0)
	BeamMeUpDejaShowHideButton:SetWidth(94)
	BeamMeUpDejaShowHideButton:SetHeight(30)
	BeamMeUpDejaShowHideButton:Show()

	--Button Color (Overrides default red buttons)
--local BeamMeUpDejaShowHideButtonTexture=BeamMeUpDejaShowHideButton:CreateTexture(nil,"ARTWORK")
--	BeamMeUpDejaShowHideButtonTexture:SetAllPoints(BeamMeUpDejaShowHideButton)
--	BeamMeUpDejaShowHideButtonTexture:SetColorTexture(0, 0.75, 1, 1)

local BeamMeUpDejaShowHideButtonFS = BeamMeUpDejaShowHideButton:CreateFontString("FontString","OVERLAY","GameTooltipText")
	BeamMeUpDejaShowHideButtonFS:SetPoint("CENTER", BeamMeUpDejaShowHideButton)
	BeamMeUpDejaShowHideButtonFS:SetFont("Fonts\\FRIZQT__.TTF", 12)
	BeamMeUpDejaShowHideButtonFS:SetShadowOffset(1, -1)
	BeamMeUpDejaShowHideButtonFS:SetTextColor(1, 1, 0);
	BeamMeUpDejaShowHideButtonFS:SetText("")

			
	BeamMeUpDejaShowHideButton:SetScript("OnEvent", function(self, button, up)
		ShowHideButtonShownCheck = private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck
		if ShowHideButtonShownCheck == true then
			BeamMeUpDejaHideFrame:Show()
			BeamMeUpDejaShowHideButtontooltipText = ("Hide the Sentinax beacon buttons.") --Creates a tooltip on mouseover.
			BeamMeUpDejaShowHideButtonFS:SetText("Hide")
			--print("Shown")--Debugging
			private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck = true
		else
			BeamMeUpDejaHideFrame:Hide()
			BeamMeUpDejaShowHideButtontooltipText = ("Show buttons for Sentinax beacons in your bags.") --Creates a tooltip on mouseover.
			BeamMeUpDejaShowHideButtonFS:SetText("Show")
			--print("Hidden")--Debugging
			private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck = false
		end
	end)
	
	BeamMeUpDejaShowHideButton:SetScript("OnClick", function(self, button, up)
		if ShowHideButtonShownCheck == true then
			BeamMeUpDejaHideFrame:Hide()
			BeamMeUpDejaShowHideButtontooltipText = ("Show buttons for Sentinax beacons in your bags.") --Creates a tooltip on mouseover.
			BeamMeUpDejaShowHideButtonFS:SetText("Show")
			BeamMeUpDejaShowHideTooltipChangeText()
			private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck = false
			--print("Hidden")--Debugging
		else
			BeamMeUpDejaHideFrame:Show()
			BeamMeUpDejaShowHideButtontooltipText = ("Hide the Sentinax beacon buttons.") --Creates a tooltip on mouseover.
			BeamMeUpDejaShowHideButtonFS:SetText("Hide")
			BeamMeUpDejaShowHideTooltipChangeText()
			private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck = true
			--print("Shown")--Debugging
		end
		ShowHideButtonShownCheck = private.db.BMUDShowHideButtonChecked.BMUDShowHideButtonShownCheck
	end)
 
 	BeamMeUpDejaShowHideButton:SetScript("OnEnter", function(self)
		BeamMeUpDejaShowHideTooltipChangeText()
		GameTooltip:Show()
	end)

	BeamMeUpDejaShowHideButton:SetScript("OnLeave", function(self)
		GameTooltip_Hide()
	end)
	
	--Nethershard Parent Frame
local NethershardFrame = CreateFrame("Frame", "NethershardFrame", BeamMeUpDejaDragFrame)
	NethershardFrame:RegisterEvent("PLAYER_LOGIN")
	NethershardFrame:ClearAllPoints()
	NethershardFrame:SetPoint("BOTTOMLEFT", BeamMeUpDejaShowHideButton, "BOTTOMRIGHT", 0, 0)
	NethershardFrame:SetWidth(142)
	NethershardFrame:SetHeight(28)
	NethershardFrame:Show()

	--Debugging Texture
local NethershardFrameTexture=NethershardFrame:CreateTexture(nil,"ARTWORK")
	NethershardFrameTexture:SetAllPoints(NethershardFrame)
	--NethershardFrameTexture:SetColorTexture(0.3, 0.75, 0.1, 1)--Optional Color
	NethershardFrameTexture:SetColorTexture(0.15, 0.15, 0.15, 0.7)

	--Nethershard Icon Frame
local NethershardIconFrame = CreateFrame("Frame", "NethershardIconFrame", NethershardFrame)
	NethershardIconFrame:RegisterEvent("PLAYER_LOGIN")
	NethershardIconFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	NethershardIconFrame:ClearAllPoints()
	NethershardIconFrame:SetPoint("TOPLEFT", NethershardFrame, "TOPLEFT", 0, 0)
	NethershardIconFrame:SetWidth(14)
	NethershardIconFrame:SetHeight(14)
	NethershardIconFrame:Show()
	
local NethershardFS = NethershardFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	NethershardFS:SetPoint("LEFT", NethershardIconFrame, "RIGHT", -1, 1)
	NethershardFS:SetFont("Fonts\\FRIZQT__.TTF", 12)
	NethershardFS:SetFormattedText("")
	NethershardFS:SetShadowOffset(1, -1)
	NethershardFS:SetTextColor(1, 1, 1, 1);
	NethershardFS:Show()

local NethershardFSTexture=NethershardIconFrame:CreateTexture(nil,"ARTWORK")
	NethershardFSTexture:SetAllPoints(NethershardIconFrame)
			
	NethershardIconFrame:SetScript("OnEvent", function(self, event, ...)
		local name, currentAmount, texture, _, _, totalMax = GetCurrencyInfo(1226)--Nethershards
		NethershardFS:SetFormattedText("Nethershards: %.0f", currentAmount)
		--NethershardFS:SetText("Nethershards: "..currentAmount);
		NethershardFSTexture:SetTexture(texture)
	end)

local LWSuppliesIconFrame = CreateFrame("Frame", "LWSuppliesIconFrame", NethershardFrame)
	LWSuppliesIconFrame:RegisterEvent("PLAYER_LOGIN")
	LWSuppliesIconFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	LWSuppliesIconFrame:ClearAllPoints()
	LWSuppliesIconFrame:SetPoint("BOTTOMLEFT", NethershardFrame, "BOTTOMLEFT", 0, 0)
	LWSuppliesIconFrame:SetWidth(14)
	LWSuppliesIconFrame:SetHeight(14)
	LWSuppliesIconFrame:Show()
	
local LWSuppliesFS = NethershardFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	LWSuppliesFS:SetPoint("LEFT", LWSuppliesIconFrame, "RIGHT", -1, 0)
	LWSuppliesFS:SetFont("Fonts\\FRIZQT__.TTF", 12)
	LWSuppliesFS:SetFormattedText("")
	LWSuppliesFS:SetShadowOffset(1, -1)
	LWSuppliesFS:SetTextColor(1, 1, 1, 1);
	NethershardFS:Show()

local LWSuppliesFSTexture=LWSuppliesIconFrame:CreateTexture(nil,"ARTWORK")
	LWSuppliesFSTexture:SetAllPoints(LWSuppliesIconFrame)
	LWSuppliesFSTexture:SetTexture(texture)
			
			
	LWSuppliesIconFrame:SetScript("OnEvent", function(self, event, ...)
		local name, currentAmount, texture, _, _, totalMax = GetCurrencyInfo(1342)--Legionfall War Supplies
		LWSuppliesFS:SetFormattedText("War  Supplies: %.0f", currentAmount)
		--NethershardFS:SetText("War  Supplies: "..currentAmount);
		LWSuppliesFSTexture:SetTexture(texture)
	end)

--Beam Me Up Deja Initialization Frames/Buttons
		
		local function CreateButton(parent)
			local button = CreateFrame("Frame", nil, parent)
			local index = #parent.beacons + 1 or 1
			
			button:SetSize(buttonSize, buttonSize);
			button.access = {}
			
			button.slot = CreateFrame("Button", nil, button, "ContainerFrameItemButtonTemplate")
			button.slot:RegisterForClicks("RightButtonUp");
			button.slot:SetClampedToScreen(true)
			button.slot:SetSize(buttonSize, buttonSize)
			button.slot:SetPoint("CENTER")
			button.slot:SetScript("OnEnter", function()
				local bag = button:GetID()
				local slot = button.slot:GetID()
				
				GameTooltip:SetOwner(button, "ANCHOR_CURSOR")
				GameTooltip:SetBagItem(bag, slot);
				GameTooltip:Show()
			end)
			
			button.slot.Count = button.slot:CreateFontString("$parent_FontString","OVERLAY")
			button.slot.Count:SetPoint("BOTTOMRIGHT", button.slot)
			button.slot.Count:SetFont("Fonts\\FRIZQT__.TTF", 14, "THINOUTLINE")
			button.slot.Count:SetTextColor(1, 1, 1);
			
			
			
			button.slot:SetScript("OnLeave", GameTooltip_Hide)
			button.slot:Show()
			
			button.slot.icon:SetTexCoord(0.075, 0.925, 0.075, 0.925);
			button.slot.BattlepayItemTexture:Hide()
			
			return button
		end
		 
		local function UpdateButton(button)
		 
			-- no access found: reset button
			if #button.access == 0 then
				button:Hide()
				button.slot.Count:SetText("")
				button.slot:SetNormalTexture("")
				return
			end
		 
			local totalCount = 0;
			local texture, bagID, slotID;
			for info, values in pairs(button.access) do
				local bag, slot = unpack(values)
				local icon, count, _, quality, _, _, _, _, _, itemID   = GetContainerItemInfo(bag, slot)
				--print(icon, count, quality, link, itemID )--Debugging
				
				BMUDRarity = quality
				if (itemID == 147729) or (itemID == 147355) or (itemID == 146923) or (itemID == 146922) then BMUDRarity = 5 end
				BMUDRarityTable[BMUDRarity] = 1
				if count then
					totalCount = totalCount + count
				end
				
				-- get the first possible identification for access later
				if not bagID or not slotID or not texture then
					texture = icon
					bagID = bag
					slotID = slot
				end
			end
			
			-- we do not need to show a count there is only 1 item existing
			if totalCount == 1 then
				totalCount = ""
			end
		 
			-- update count & texture
			button.slot.icon:SetTexture(texture)
			
			--print(totalCount,name) debug
			button.slot.Count:SetText(totalCount)
				
			-- update access
			button:SetID(bagID)
			button.slot:SetID(slotID)
			button:Show()
		end
		 
		local function ResetButtons(self)
			local bmudtable = self.beacons
			
			for _, button in pairs(bmudtable) do
				button:Hide();
				button.access = {}
			end
		end
		 
		local function CacheAccess(self)
			local bmudtable = self.beacons
			BMUDRarityTable = {} --X position of rows stack and collapsing 
			
			for bag = 0, 4 do
				for slot = 1, GetContainerNumSlots(bag) do
					local itemID = GetContainerItemID(bag, slot)
					if SEARCHED_ITEMS[itemID] then
						--local _,_,_, quality = GetContainerItemInfo(bag, slot)
						--print(quality)--Debugging

						--BMUDRarity = quality
						--if (itemID == 147729) or (itemID == 147355) or (itemID == 146923) or (itemID == 146922) then BMUDRarity = 5 end
						--BMUDRarityTable[BMUDRarity] = 1
						--print(BMUDRarityTable[BMUDRarity])

						-- beacon found!!!
						local button = bmudtable[itemID]
						
						-- no button found: create it
						if not button then
							button = CreateButton(self)
							bmudtable[itemID] = button
						end
						
						-- store access
						if button then
							tinsert(button.access, {bag, slot})
						end
					end
				end
			end
		end
		 
		local function UpdateAllButtons(self)
			local bmudtable = self.beacons
			local BMUDIndexes = {}
			
			for i = 1, 5 do
				BMUDIndexes[i] = 0
			end

			local BMUDFalseRarityTable = {}

			for i = 1, 5 do
				if  not BMUDRarityTable[i] then BMUDRarityTable[i] = 0 end
			end

			for i = 1, 5 do
				local sum = -1
				for i = 1, i do
					sum = sum + BMUDRarityTable[i]
				end
				BMUDFalseRarityTable[i] = sum
			end
		
			local button_padding = (buttonSize + padding)
			
			for _, button in pairs(bmudtable) do
				if button then
					UpdateButton(button)
					if button:IsShown() then
						if BMUDRarity>-1 then
							local y = BMUDFalseRarityTable[BMUDRarity] * button_padding
							local x = BMUDIndexes[BMUDRarity]*button_padding

							button:SetPoint("BOTTOMLEFT", self, x, y)
							BMUDIndexes[BMUDRarity] = BMUDIndexes[BMUDRarity] + 1
						end
					end
				end
			end
		end
	 
local BeamMeUpDejaInitFrame = CreateFrame("Frame", "BeamMeUpDejaInitFrame", BeamMeUpDejaHideFrame)
		 
	BeamMeUpDejaInitFrame.beacons = {}
	BeamMeUpDejaInitFrame:SetPoint("BOTTOMLEFT", BeamMeUpDejaHideFrame, 0, buttonSize );
	BeamMeUpDejaInitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	BeamMeUpDejaInitFrame:SetSize(basewidth, baseheight - buttonSize)
	BeamMeUpDejaInitFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			--print(event)--Debugging
			self:RegisterEvent("BAG_UPDATE_DELAYED")
			
			-- pre call the event for initialization
			ResetButtons(self)
			CacheAccess(self)
			UpdateAllButtons(self)
			
		end
		ResetButtons(self)
		CacheAccess(self)
		UpdateAllButtons(self)
	end)

local function BMUD_GetZone()
	mapID = GetCurrentMapAreaID();
	mapName = GetMapNameByID(mapID);
		--print("mapName:", mapName);
	--ZoneName = GetRealZoneText();
		--print("ZoneName:", ZoneName);
	--subzone = GetSubZoneText();
		--print("subzone:", subzone);
end	
	
local function BMUD_ShowEnableFrames()
	BeamMeUpDejaDragFrame:Show()
	BeamMeUpDejaShowHideButton:Show()
	NethershardFrame:Show()
end

local function BMUD_HideEnableFrames()
	BeamMeUpDejaDragFrame:Hide()
	BeamMeUpDejaShowHideButton:Hide()
	NethershardFrame:Hide()
end

private.defaults.BMUDzoneChecked = {
	BMUDzoneCheck = true,
}	

local BMUDzonecheck = CreateFrame("CheckButton", "BeamMeUpDejaZoneCheck", BeamMeUpDejaPanel, "InterfaceOptionsCheckButtonTemplate")
	BMUDzonecheck:RegisterEvent("PLAYER_LOGIN")
	BMUDzonecheck:RegisterEvent("PLAYER_ENTERING_WORLD")
	BMUDzonecheck:RegisterEvent("ADDON_LOADED")
	BMUDzonecheck:RegisterEvent("ZONE_CHANGED")
	BMUDzonecheck:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	BMUDzonecheck:RegisterEvent("WORLD_MAP_UPDATE")
	BMUDzonecheck:RegisterEvent("ZONE_CHANGED_INDOORS")
	BMUDzonecheck:ClearAllPoints()
	BMUDzonecheck:SetPoint("TOPLEFT", 25, -50)
	BMUDzonecheck:SetScale(1.25)
	_G[BMUDzonecheck:GetName() .. "Text"]:SetText("Automatic")
	BMUDzonecheck.tooltipText = 'Checked shows BeamMeUpDeja only when on the Broken Shore. Unchecked always shows BeamMeUpDeja.' --Creates a tooltip on mouseover.
	
	BMUDzonecheck:SetScript("OnEvent", function(self, button, up)
		local checked = private.db.BMUDzoneChecked
		self:SetChecked(checked.BMUDzoneCheck)
		if self:GetChecked(true) then
			BMUD_GetZone()
			if mapName == "Broken Shore" then
				BMUD_ShowEnableFrames()
			else
				BMUD_HideEnableFrames()
			end
			private.db.BMUDzoneChecked.BMUDzoneCheck = true
		else
			BMUD_ShowEnableFrames()
			private.db.BMUDzoneChecked.BMUDzoneCheck = false
		end
	end)	
	
	BMUDzonecheck:SetScript("OnClick", function(self, button, up)
		if self:GetChecked(true) then
			BMUD_GetZone()
			if mapName == "Broken Shore" then
				BMUD_ShowEnableFrames()
			else
				BMUD_HideEnableFrames()
			end
			private.db.BMUDzoneChecked.BMUDzoneCheck = true
		else
			BMUD_ShowEnableFrames()
			private.db.BMUDzoneChecked.BMUDzoneCheck = false
		end
	end)