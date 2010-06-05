local _NAME, _NS = ...
local Butsu = _G[_NAME]

do
	-- Used to setup our DB and such.
	Butsu:SetScript('OnShow', function(self)
		-- We only need this once.
		self:SetScript('OnShow', nil)

		local db = setmetatable({},
		{
			__index = {
				iconSize = 22;

				-- Attempt to set sane defaults.
				fontSizeTitle = select(2, GameTooltipHeaderText:GetFont());
				fontSizeItem = select(2, GameFontWhite:GetFont());
				fontSizeCount = select(2, NumberFontNormalSmall:GetFont());

				frameScale = 1;
				framePosition = '';
			}
		})
		_NS.db = db

		self.title:SetFont(GameTooltipHeaderText:GetFont(), db.fontSizeTitle, 'OUTLINE')
		self:SetScale(db.frameScale)
	end)
end
