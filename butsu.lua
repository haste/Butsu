local _NAME, _NS = ...
local Butsu = CreateFrame("Button", _NAME)
Butsu:Hide()

Butsu:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

function Butsu:LOOT_OPENED(event, autoloot)
	self:Show()

	if(not self:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local L = _NS.L
	if(IsFishingLoot()) then
		self.title:SetText(L.fish)
	elseif(not UnitIsFriend("player", "target") and UnitIsDead"target") then
		self.title:SetText(UnitName"target")
	else
		self.title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
		self:GetCenter()
		self:Raise()
	end

	local m = 0
	local items = GetNumLootItems()
	if(items > 0) then
		for i=1, items do
			local slot = _NS.slots[i] or _NS.CreateSlot(i)
			local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			if(texture) then
				local color = ITEM_QUALITY_COLORS[quality]
				local r, g, b = color.r, color.g, color.b

				local slotType = GetLootSlotType(i)
				if(slotType == LOOT_SLOT_MONEY) then
					item = item:gsub("\n", ", ")
				end

				if(quantity > 1) then
					slot.count:SetText(quantity)
					slot.count:Show()
				else
					slot.count:Hide()
				end

				if(questId and not isActive) then
					slot.quest:Show()
				else
					slot.quest:Hide()
				end

				if(quality > 1 or questId or isQuestItem) then
					if(questId or isQuestItem) then
						r, g, b = 1, 1, .2
					end

					slot.drop:SetVertexColor(r, g, b)
					slot.drop:Show()
				else
					slot.drop:Hide()
				end

				slot.isQuestItem = isQuestItem
				slot.quality = quality

				slot.name:SetText(item)
				slot.name:SetTextColor(r, g, b)
				slot.icon:SetTexture(texture)

				m = math.max(m, quality)

				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = _NS.slots[1] or _NS.CreateSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L.empty)
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	self:AnchorSlots()

	local color = ITEM_QUALITY_COLORS[m]
	self:SetBackdropBorderColor(color.r, color.g, color.b, .8)

	self:UpdateWidth()
end
Butsu:RegisterEvent"LOOT_OPENED"

function Butsu:LOOT_SLOT_CLEARED(event, slot)
	if(not self:IsShown()) then return end

	_NS.slots[slot]:Hide()
	self:AnchorSlots()
end
Butsu:RegisterEvent"LOOT_SLOT_CLEARED"

function Butsu:LOOT_CLOSED()
	StaticPopup_Hide"LOOT_BIND"
	self:Hide()

	for _, v in pairs(_NS.slots) do
		v:Hide()
	end
end
Butsu:RegisterEvent"LOOT_CLOSED"

function Butsu:OPEN_MASTER_LOOT_LIST()
	ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0)
end
Butsu:RegisterEvent"OPEN_MASTER_LOOT_LIST"

function Butsu:UPDATE_MASTER_LOOT_LIST()
	UIDropDownMenu_Refresh(GroupLootDropDown)
end
Butsu:RegisterEvent"UPDATE_MASTER_LOOT_LIST"

do
	local round = function(n)
		return math.floor(n * 1e5 + .5) / 1e5
	end

	function Butsu:SavePosition()
		local point, parent, _, x, y = self:GetPoint()

		_NS.db.framePosition = string.format(
			'%s\031%s\031%d\031%d',
			point, 'UIParent', round(x), round(y)
		)
	end

	function Butsu:LoadPosition()
		local scale = self:GetScale()
		local point, parentName, x, y = string.split('\031', _NS.db.framePosition)

		self:ClearAllPoints()
		self:SetPoint(point, parentName, point, x / scale, y / scale)
	end
end
