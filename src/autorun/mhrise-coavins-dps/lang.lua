local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'

-- https://i18ns.com/languagecode.html

local this = {}

-- load locales
this.loadLocales = function()
	local paths = fs.glob([[mhrise-coavins-dps\\translations\\.*json]])

	for _,path in ipairs(paths) do
		local name = string.match(path, '\\([%a-]+).json')
		if name then
			local file = CORE.readDataFile('translations/' .. name .. '.json')
			if file then
				STATE._LOCALES[name] = file
				CORE.log_info('loaded locale ' .. name)
			else
				CORE.log_error('Failed to load file for path: ' .. path)
			end
		else
			CORE.log_error('Failed to get filename from path: ' .. path)
		end
	end

	-- build options list
	for locale,_ in pairs(STATE._LOCALES) do
		local language,_ = string.match(locale, "(.*)%-(.*)")
		local text
		-- find name for locale first
		if ENUM.LANGUAGES[locale] then
			text = ENUM.LANGUAGES[locale] .. ' (' .. locale .. ')'
		-- find name for language
		elseif ENUM.LANGUAGES[language] then
			text = ENUM.LANGUAGES[language] .. ' (' .. locale .. ')'
		-- just print the locale string
		else
			text = locale
		end
		table.insert(STATE.LOCALE_OPTIONS, text)
		STATE.LOCALE_OPTIONS_TXT2LOCALE[text] = locale
	end
	table.sort(STATE.LOCALE_OPTIONS)
end

this.applySavedLanguage = function()
	local savedLocale = CORE.CFG('LOCALE')
	for i, locale in pairs(STATE.LOCALE_OPTIONS) do
		locale = STATE.LOCALE_OPTIONS_TXT2LOCALE[locale]
		if locale == savedLocale then
			CORE.log_info('Switching to saved locale ' .. locale)
			STATE.LOCALE_OPTIONS_SELECTED = i
			this.applySelectedLanguage()
			return
		end
	end

	CORE.log_error('Couldn\'t find saved locale ' .. savedLocale)

	for i, locale in pairs(STATE.LOCALE_OPTIONS) do
		locale = STATE.LOCALE_OPTIONS_TXT2LOCALE[locale]
		if locale == 'en-US' then
			CORE.log_info('Switching to default locale en-US')
			STATE.LOCALE_OPTIONS_SELECTED = i
			this.applySelectedLanguage()
			return
		end
	end

	CORE.log_error('Couldn\'t find default locale en-US')
end

this.loadFontForLanguage = function(locale)
	if locale == 'zh-CN' then
		STATE.CHANGE_IMGUI_FONT = imgui.load_font(STATE.RE_FONT_NAME_SC, STATE.RE_FONT_SIZE, STATE.CJK_GLYPH_RANGES)
	elseif locale == 'zh-HK' then
		STATE.CHANGE_IMGUI_FONT = imgui.load_font(STATE.RE_FONT_NAME_HK, STATE.RE_FONT_SIZE, STATE.CJK_GLYPH_RANGES)
	else
		STATE.CHANGE_IMGUI_FONT = imgui.load_font(STATE.RE_FONT_NAME_JP, STATE.RE_FONT_SIZE, STATE.CJK_GLYPH_RANGES)
	end
end

this.applySelectedLanguage = function()
	local locale = STATE.LOCALE_OPTIONS[STATE.LOCALE_OPTIONS_SELECTED]

	-- get locale string from human readable option text
	locale = STATE.LOCALE_OPTIONS_TXT2LOCALE[locale]

	if STATE._LOCALES[locale] then
		CORE.SetCFG('LOCALE', locale)
		STATE.LOCALE = locale
		this.loadFontForLanguage(locale)

		-- update table columns combobox
		for i,col in ipairs(ENUM.TABLE_COLUMNS_OPTIONS_ID) do
			ENUM.TABLE_COLUMNS_OPTIONS_READABLE[i] = this.HEADER(col)
		end

		CORE.log_info(string.format('applied locale %s', locale))
	end
end

-- return string for locale, or fallback to en-US if it isn't found
this.getStringForLocale = function(locale, section, key)
	-- try to find it in given locale
	if STATE._LOCALES[locale]
	and STATE._LOCALES[locale][section]
	and STATE._LOCALES[locale][section][key] then
		return STATE._LOCALES[locale][section][key]
	else
		-- try to find it in en-US locale
		if STATE._LOCALES['en-US']
		and STATE._LOCALES['en-US'][section]
		and STATE._LOCALES['en-US'][section][key] then
			return STATE._LOCALES['en-US'][section][key]
		else
			-- return empty string
			return ''
		end
	end
end

-- Return message string for given key
this.MESSAGE = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'messages', key)
end

this.OPTION = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'options', key)
end

this.HOTKEY = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'hotkeys', key)
end

this.KEY = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'keys', string.format('%.0f', key))
end

this.COLOR = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'colors', key)
end

this.HEADER = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'column_headers', string.format('%.0f', key))
end

this.DAMAGETYPE = function(key)
	return this.getStringForLocale(STATE.LOCALE, 'damage_types', key)
end

return this
