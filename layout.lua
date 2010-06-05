local _NAME, _NS = ...
local Butsu = _G[_NAME]

do
	local title = Butsu:CreateFontString(nil, "OVERLAY")
	title:SetPoint("BOTTOMLEFT", Butsu, "TOPLEFT", 5, 0)
	Butsu.title = title
end

Butsu:SetScript("OnMouseDown", function(self)
	if(IsAltKeyDown()) then
		self:StartMoving()
	end
end)

Butsu:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
	self:SavePosition()
end)

Butsu:SetScript("OnHide", function(self)
	StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
	CloseLoot()
end)

Butsu:SetMovable(true)
Butsu:RegisterForClicks"anyup"

Butsu:SetParent(UIParent)
Butsu:SetBackdrop{
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}
Butsu:SetBackdropColor(0, 0, 0, 1)

Butsu:SetClampedToScreen(true)
Butsu:SetClampRectInsets(0, 0, 14, 0)
Butsu:SetHitRectInsets(0, 0, -14, 0)
Butsu:SetFrameStrata"HIGH"
Butsu:SetToplevel(true)
