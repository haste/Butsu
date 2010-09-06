local _NAME, _NS = ...
local Butsu = _G[_NAME]

local LoadSettings
do
	LoadSettings = function(self)
		-- We only need this once.
		self:SetScript('OnShow', nil)
		if(_NS.db) then return _NS.db end

		local db = ButsuDB or {}
		_NS.db = setmetatable(db,
		{
			__index = {
				iconSize = 22;

				-- Attempt to set sane defaults.
				fontSizeTitle = math.floor(select(2, GameTooltipHeaderText:GetFont()) + .5);
				fontSizeItem = math.floor(select(2, GameFontWhite:GetFont()) + .5);
				fontSizeCount = math.floor(select(2, NumberFontNormalSmall:GetFont()) + .5);

				frameScale = 1;
				framePosition = 'TOPLEFT\031UIParent\0310\031-104';
			}
		})

		if(not ButsuDB) then
			ButsuDB = db
		end

		self.title:SetFont(GameTooltipHeaderText:GetFont(), _NS.db.fontSizeTitle, 'OUTLINE')
		self:SetScale(_NS.db.frameScale)

		self:LoadPosition()
	end

	-- Used to setup our DB and such.
	Butsu:SetScript('OnShow', LoadSettings)
end

do
	local opt = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	opt:Hide()

	opt.name = _NAME
	opt:SetScript("OnShow", function(self)
		LoadSettings(Butsu)

		local db = _NS.db
		local createFontString = function(text, template,  ...)
			local label = self:CreateFontString(nil, nil, template or 'GameFontHighlight')
			label:SetPoint(...)
			label:SetText(text)

			return label
		end

		local createSlider
		do
			local sliderBackdrop = {
				bgFile = [[Interface\Buttons\UI-SliderBar-Background]], tile = true, tileSize = 8,
				edgeFile = [[Interface\Buttons\UI-SliderBar-Border]], edgeSize = 8,
				insets = {left = 3, right = 3, top = 6, bottom = 6},
			}

			createSlider = function(name, min, max, cur, ...)
				local slider = CreateFrame('Slider', nil, self)
				slider:SetOrientation'HORIZONTAL'
				slider:SetPoint(...)
				slider:SetSize(144, 17)
				slider:SetHitRectInsets(0, 0, -10, -10)
				slider:SetBackdrop(sliderBackdrop)

				slider:SetThumbTexture[[Interface\Buttons\UI-SliderBar-Button-Horizontal]]
				slider:SetMinMaxValues(min, max)
				slider:SetValue(cur)

				slider.label = createFontString(name, 'GameFontNormalCenter', 'BOTTOM', slider, 'TOP')
				slider.min = createFontString(min, 'GameFontHighlightSmall', 'TOPLEFT', slider, 'BOTTOMLEFT', -4, 3)
				slider.max = createFontString(max, 'GameFontHighlightSmall', 'TOPRIGHT', slider, 'BOTTOMRIGHT', 4, 3)
				slider.current = createFontString(cur, 'GameFontHighlightSmall', 'TOP', slider, 'BOTTOM')

				return slider
			end
		end

		local L = _NS.L

		local title = createFontString(_NAME, 'GameFontNormalLarge', 'TOPLEFT', 16, -16)
		title:SetPoint('TOPRIGHT', -16, -16);
		title:SetJustifyH('LEFT')

		local version = createFontString(nil, 'GameFontHighlightSmall', 'TOPLEFT', 16, -16)
		version:SetPoint('TOPRIGHT', -16, -16)
		version:SetJustifyH('RIGHT')
		version:SetFormattedText('%s', GetAddOnMetadata('Butsu', 'Version'))

		local desc = createFontString(L.configDesc, 'GameFontHighlightSmall', 'TOPLEFT', title, 'BOTTOMLEFT', 0, -10)
		desc:SetWidth(385)
		desc:SetJustifyH('LEFT')

		local note = createFontString(L.configNote, 'GameFontHighlightSmall', 'TOPLEFT', desc, 'BOTTOMLEFT', 0, -10)
		note:SetWidth(385)
		note:SetJustifyH('LEFT')
		note:SetTextColor(0.8, 0.8, 0.8)

		local fontSizeTitle = createSlider(L.uiTitleSize, 7, 40, db.fontSizeTitle, 'TOPLEFT', note, 'BOTTOMLEFT', 0, -28)
		fontSizeTitle:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.fontSizeTitle = value
			self.current:SetText(value)

			local font, size, outline = Butsu.title:GetFont()
			Butsu.title:SetFont(font, value, outline)
		end)

		local fontSizeItem = createSlider(L.uiItemSize, 7, 40, db.fontSizeItem, 'TOPLEFT', fontSizeTitle, 'BOTTOMLEFT', 0, -32)
		fontSizeItem:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.fontSizeItem = value
			self.current:SetText(value)

			for _, slot in next, _NS.slots do
				local font, size, outline = slot.name:GetFont()
				slot.name:SetFont(font, value, outline)
			end

			Butsu:UpdateWidth()
			Butsu:AnchorSlots()
		end)

		local fontSizeCount = createSlider(L.uiCountSize, 7, 40, db.fontSizeCount, 'TOPLEFT', fontSizeItem, 'BOTTOMLEFT', 0, -32)
		fontSizeCount:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.fontSizeCount = value
			self.current:SetText(value)

			for _, slot in next, _NS.slots do
				local font, size, outline = slot.count:GetFont()
				slot.count:SetFont(font, value, outline)
			end
		end)

		local iconSize = createSlider(L.uiIconSize, 14, 80, db.iconSize, 'TOPRIGHT', note, 'BOTTOMRIGHT', 0, -28)
		iconSize:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.iconSize = value
			self.current:SetText(value)

			for _, slot in next, _NS.slots do
				slot:SetHeight(value)
				slot.iconFrame:SetSize(value, value)
			end

			Butsu:UpdateWidth()
			Butsu:AnchorSlots()
		end)

		local frameScale = createSlider(L.uiFrameScale, .4, 3, db.frameScale, 'TOPLEFT', iconSize, 'BOTTOMLEFT', 0, -32)
		frameScale:SetValueStep(.05)
		frameScale:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value * 10^2 + .5) / 10^2

			db.frameScale = value
			self.current:SetFormattedText('%.02f', value)

			Butsu:SetScale(value)
		end)

		local UpdateSettings = function(self)
			fontSizeTitle:SetValue(db.fontSizeTitle)
			fontSizeItem:SetValue(db.fontSizeItem)
			fontSizeCount:SetValue(db.fontSizeCount)

			iconSize:SetValue(db.iconSize)
			frameScale:SetValue(db.frameScale)
		end

		self:SetScript('OnShow', UpdateSettings)
	end)

	InterfaceOptions_AddCategory(opt)
end

do
	SLASH_BUTSU1 = '/butsu'
	SlashCmdList['BUTSU'] = function(inp)
		InterfaceOptionsFrame_OpenToCategory(_NAME)
	end
end
