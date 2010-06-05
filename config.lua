local _NAME, _NS = ...
local Butsu = _G[_NAME]

do
	-- Used to setup our DB and such.
	Butsu:SetScript('OnShow', function(self)
		-- We only need this once.
		self:SetScript('OnShow', nil)

		local db = ButsuDB or {}
		_NS.db = setmetatable(db,
		{
			__index = {
				iconSize = 22;

				-- Attempt to set sane defaults.
				fontSizeTitle = select(2, GameTooltipHeaderText:GetFont());
				fontSizeItem = select(2, GameFontWhite:GetFont());
				fontSizeCount = select(2, NumberFontNormalSmall:GetFont());

				frameScale = 1;
				framePosition = 'TOPLEFT\031UIParent\0310\031-104';
			}
		})

		if(not ButsDB) then
			ButsuDB = db
		end

		self.title:SetFont(GameTooltipHeaderText:GetFont(), db.fontSizeTitle, 'OUTLINE')
		self:SetScale(db.frameScale)

		self:LoadPosition()
	end)
end
