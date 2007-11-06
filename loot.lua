--[[-------------------------------------------------------------------------
  Copyright (c) 2007, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of Butsu nor the names of its contributors may
        be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]
local addon = CreateFrame"Frame"
addon:Hide()

local print = function(a) ChatFrame1:AddMessage("|cff33ff99Butsu:|r "..a) end
local iconsize = 22

print"Initial write-up, master loot won't work"

local createSlot = function(id)
	local frame = CreateFrame("Button", nil, addon)
	frame:SetPoint("LEFT", 8, 0)
	frame:SetPoint("RIGHT", -8, 0)
	frame:SetHeight(iconsize)
	frame:SetID(id)

	frame:SetScript("OnEnter", function(self)
		local slot = self:GetID()
		if(LootSlotIsItem(slot)) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetLootItem(slot)
			CursorUpdate()
		end
		self.drop:Show()
		self.drop:SetVertexColor(1, 1, 0)
	end)
	frame:SetScript("OnLeave", function(self)
		if(self.quality > 1) then
			local color = ITEM_QUALITY_COLORS[self.quality]
			self.drop:SetVertexColor(color.r, color.g, color.b)
		else
			self.drop:Hide()
		end
		GameTooltip:Hide()
		ResetCursor()
	end)
	frame:SetScript("OnClick", function(self)
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(self:GetID())
	end)

	local iconFrame = CreateFrame("Button", nil, frame)
	iconFrame:EnableMouse(true)
	iconFrame:SetHeight(iconsize)
	iconFrame:SetWidth(iconsize)
	iconFrame:ClearAllPoints()
	iconFrame:SetPoint("RIGHT", frame)

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAlpha(.8)
	icon:SetAllPoints(iconFrame)
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:ClearAllPoints()
	count:SetJustifyH"RIGHT"
	count:SetPoint("BOTTOMRIGHT", iconFrame, 2, 2)
	count:SetFontObject(NumberFontNormalSmall)
	count:SetShadowOffset(.8, -.8)
	count:SetShadowColor(0, 0, 0, 1)
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH"LEFT"
	name:ClearAllPoints()
	name:SetPoint("LEFT", frame)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:SetFont(STANDARD_TEXT_FONT, 10)
	name:SetShadowOffset(.8, -.8)
	name:SetShadowColor(0, 0, 0, 1)
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"

	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop

	frame:SetPoint("TOP", addon, 4, (-7+iconsize)-(id*(iconsize+1)))
	addon.slots[id] = frame
	return frame
end

local title = addon:CreateFontString(nil, "OVERLAY")
title:SetFontObject(GameTooltipHeaderText)
title:SetPoint("BOTTOMLEFT", addon, "TOPLEFT", 5, 0)
addon.title = title

addon:SetParent(UIParent)
addon:SetPoint("TOP", -200, -50)
addon:SetBackdrop{
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
addon:SetWidth(256)
addon:SetHeight(64)
addon:SetBackdropColor(0, 0, 0, 1)

addon.slots = {}
addon.LOOT_OPENED = function(self, event, autoloot)
	local items = GetNumLootItems()
	local x, y = GetCursorPosition()
	x = x / self:GetEffectiveScale()
	y = y / self:GetEffectiveScale()
	local posX = x - 175
	local posY = y + 25

	if (items > 0) then
		posX = x - 40
		posY = y + 55
		posY = posY + 40
	end

	if( posY < 350 ) then
		posY = 350
	end

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY)
	self:GetCenter()
	self:Raise()

	title:SetText(UnitName"target")

	local m, w, t = 0, 0, title:GetStringWidth()
	for i=1, items do
		local slot = addon.slots[i] or createSlot(i)
		local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
		local color = ITEM_QUALITY_COLORS[quality]

		if(LootSlotIsCoin(i)) then
			item = item:gsub("\n", ", ")
		end

		if(quantity > 1) then
			slot.count:SetText(quantity)
			slot.count:Show()
		else
			slot.count:Hide()
		end

		if(quality > 1) then
			slot.drop:SetVertexColor(color.r, color.g, color.b)
			slot.drop:Show()
		else
			slot.drop:Hide()
		end

		slot.quality = quality

		slot.name:SetText(item)
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture(texture)

		m = math.max(m, quality)
		w = math.max(w, slot.name:GetStringWidth())
		slot:Show()
	end

	w = w + 60
	t = t + 5

	local color = ITEM_QUALITY_COLORS[m]
	self:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	self:SetHeight((items*iconsize+1)+16)
	self:SetWidth(w > t and w or t)

	self:Show()
end

addon.LOOT_SLOT_CLEARED = function(self, event, slot)
	addon.slots[slot]:Hide()
end

addon.LOOT_CLOSED = function(self, event)
	self:Hide()
	StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"

	for k, v in pairs(self.slots) do
		v:Hide()
	end
end

addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

addon:RegisterEvent"LOOT_OPENED"
addon:RegisterEvent"LOOT_SLOT_CLEARED"
addon:RegisterEvent"LOOT_CLOSED"

LootFrame:UnregisterAllEvents()
