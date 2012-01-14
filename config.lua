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
		local createFontString = function(parent, text, template,  ...)
			local label = parent:CreateFontString(nil, nil, template or 'GameFontHighlight')
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

			createSlider = function(parent, name, min, max, cur, ...)
				local slider = CreateFrame('Slider', nil, parent)
				slider:SetOrientation'HORIZONTAL'
				slider:SetPoint(...)
				slider:SetSize(144, 17)
				slider:SetHitRectInsets(0, 0, -10, -10)
				slider:SetBackdrop(sliderBackdrop)

				slider:SetThumbTexture[[Interface\Buttons\UI-SliderBar-Button-Horizontal]]
				slider:SetMinMaxValues(min, max)
				slider:SetValue(cur)

				slider.label = createFontString(parent, name, 'GameFontHighlightCenter', 'BOTTOM', slider, 'TOP')
				slider.min = createFontString(parent, min, 'GameFontHighlightSmall', 'TOPLEFT', slider, 'BOTTOMLEFT', 2, 2)
				slider.max = createFontString(parent, max, 'GameFontHighlightSmall', 'TOPRIGHT', slider, 'BOTTOMRIGHT', -2, 2)
				slider.current = createFontString(parent, cur, 'GameFontHighlightSmall', 'TOP', slider, 'BOTTOM')

				return slider
			end
		end

		local boxBackdrop = {
			bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
			edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		}

		local title = createFontString(self, _NAME, 'GameFontNormalLarge', 'TOPLEFT', 16, -16)
		title:SetPoint('TOPRIGHT', -16, -16)
		title:SetJustifyH'LEFT'

		local fontBox = CreateFrame('Frame', nil, self)
		fontBox:SetBackdrop(boxBackdrop)
		fontBox:SetBackdropBorderColor(.3, .3, .3)
		fontBox:SetBackdropColor(.1, .1, .1, .5)

		fontBox:SetHeight(64)
		fontBox:SetPoint('LEFT', 12, 0)
		fontBox:SetPoint('RIGHT', -12, 0)
		fontBox:SetPoint('TOP', title, 'BOTTOM', 0, -32)

		local L = _NS.L
		local fontBoxTitle = createFontString(fontBox, L.uiFontSizeTitle, nil, 'BOTTOMLEFT', fontBox, 'TOPLEFT', 6, 0)

		local fontSizeTitle = createSlider(fontBox, L.uiTitleSize, 7, 40, db.fontSizeTitle, 'LEFT', fontBox, 12, 0)
		fontSizeTitle:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.fontSizeTitle = value
			self.current:SetText(value)

			local font, size, outline = Butsu.title:GetFont()
			Butsu.title:SetFont(font, value, outline)
		end)

		local fontSizeItem = createSlider(fontBox, L.uiItemSize, 7, 40, db.fontSizeItem, 'CENTER')
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

		local fontSizeCount = createSlider(fontBox, L.uiCountSize, 7, 40, db.fontSizeCount, 'RIGHT', -12, 0)
		fontSizeCount:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.fontSizeCount = value
			self.current:SetText(value)

			for _, slot in next, _NS.slots do
				local font, size, outline = slot.count:GetFont()
				slot.count:SetFont(font, value, outline)
			end
		end)

		local settBox = CreateFrame('Frame', nil, self)
		settBox:SetBackdrop(boxBackdrop)
		settBox:SetBackdropBorderColor(.3, .3, .3)
		settBox:SetBackdropColor(.1, .1, .1, .5)

		settBox:SetHeight(64)
		settBox:SetPoint('LEFT', 12, 0)
		settBox:SetPoint('RIGHT', -12, 0)
		settBox:SetPoint('TOP', fontBox, 'BOTTOM', 0, -32)

		local settBoxTitle = createFontString(settBox, L.uiScaleSizeTitle, nil, 'BOTTOMLEFT', settBox, 'TOPLEFT', 6, 0)

		local iconSize = createSlider(settBox, L.uiIconSize, 14, 80, db.iconSize, 'LEFT', 12, 0)
		iconSize:SetScript('OnValueChanged', function(self, value)
			value = math.floor(value + .5)

			db.iconSize = value
			self.current:SetText(value)

			for _, slot in next, _NS.slots do
				slot:SetHeight(value)
				slot.iconFrame:SetSize(value, value)

				slot.quest:SetSize(value * .8, value * .8)
				slot.quest:ClearAllPoints()
				slot.quest:SetPoint('BOTTOMLEFT', -value * .15, 0)
			end

			Butsu:UpdateWidth()
			Butsu:AnchorSlots()
		end)

		local frameScale = createSlider(settBox, L.uiFrameScale, .4, 3, db.frameScale, 'CENTER')
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
