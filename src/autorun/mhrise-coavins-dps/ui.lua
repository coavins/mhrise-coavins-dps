local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'
local DATA   = require 'mhrise-coavins-dps.data'
local REPORT = require 'mhrise-coavins-dps.report'
local LANG   = require 'mhrise-coavins-dps.lang'

local this = {}

-- Utility functions
this.showTextboxForSetting = function(setting)
	local changed, value = imgui.input_text(LANG.OPTION(setting), CORE.CFG(setting))
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showCheckboxForSetting = function(setting)
	local changed, value = imgui.checkbox(LANG.OPTION(setting), CORE.CFG(setting))
	if changed then
		CORE.SetCFG(setting, value)
		STATE.NEEDS_UPDATE = true
	end
end

this.showDropdownForSetting = function(setting, numberOfOptions, textOverride, minimumOption)
	if not minimumOption then
		minimumOption = 1
	end

	local k=1
	local options = {}
	for i=minimumOption, numberOfOptions, 1 do
		if textOverride then
			options[k] = LANG.OPTION(textOverride .. '_' .. i)
		else
			options[k] = LANG.OPTION(setting .. '_' .. i)
		end
		k = k+1
	end

	local changed, wantsIt = imgui.combo(LANG.OPTION(setting), CORE.CFG(setting), options)
	if changed then
		CORE.SetCFG(setting, wantsIt)
		STATE.NEEDS_UPDATE = true
	end
end

this.showSliderForFloatSetting = function(setting)
	local changed, value = imgui.slider_float(
		LANG.OPTION(setting), CORE.CFG(setting), CORE.MIN(setting), CORE.MAX(setting), '%.2f'
	)
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showSliderForIntSetting = function(setting)
	local changed, value = imgui.slider_int(
		LANG.OPTION(setting), CORE.CFG(setting), CORE.MIN(setting), CORE.MAX(setting), '%d'
	)
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showColorPicker = function(setting)
	local text = LANG.COLOR(setting)
	if imgui.tree_node(text) then
		local changed, value = imgui.color_picker_argb(text, CORE.COLOR(setting), STATE.PICKER_FLAGS)
		if changed then
			CORE.SetColor(setting, value)
		end
		imgui.tree_pop()
	end
end

this.showColorPickerForUnique = function(text, setting, playerNumber)
	if imgui.tree_node(text) then
		local changed, value = imgui.color_picker_argb(text, CORE.COLOR(setting)[playerNumber], STATE.PICKER_FLAGS)
		if changed then
			STATE._COLORS[setting][playerNumber] = value
		end
		imgui.tree_pop()
	end
end

this.showCheckboxForDamageType = function(type)
	local typeIsInReport = STATE._FILTERS.DAMAGE_TYPES[type]
	local changed, wantsIt = imgui.checkbox(LANG.DAMAGETYPE(type), typeIsInReport)
	if changed then
		if wantsIt then
			CORE.AddDamageTypeToReport(type)
		else
			CORE.RemoveDamageTypeFromReport(type)
		end
		REPORT.generateReport(STATE.REPORT_MONSTERS)
	end
end

this.DrawWindowSettings = function()
	local changed, wantsIt

	wantsIt = imgui.begin_window('coavins dps meter - settings', STATE.DRAW_WINDOW_SETTINGS, STATE.WINDOW_FLAGS)
	if STATE.DRAW_WINDOW_SETTINGS and not wantsIt then
		STATE.DRAW_WINDOW_SETTINGS = false

		if DATA.isInTestMode() then
			DATA.clearTestData()
			STATE.NEEDS_UPDATE = true
		end

		if CORE.CFG('AUTO_SAVE') then
			-- save when the window is closed
			CORE.saveCurrentConfig()
		end
	end

	-- Enabled
	changed, wantsIt = imgui.checkbox(LANG.MESSAGE('Enabled'), STATE.DPS_ENABLED)
	if changed then
		STATE.DPS_ENABLED = wantsIt
	end

	imgui.same_line()
	if imgui.button(LANG.MESSAGE('btn_reset_default')) then
		CORE.loadDefaultConfig()
		if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			DATA.initializeTestData()
		else
			DATA.clearTestData()
		end

		STATE.NEEDS_UPDATE = true
	end

	imgui.same_line()
	if imgui.button(LANG.MESSAGE('btn_clear_data')) then
		if DATA.isInTestMode() then
			-- reinitialize test data
			DATA.initializeTestData()
		else
			CORE.cleanUpData('user clicked reset')
		end

		STATE.NEEDS_UPDATE = true
	end

	if imgui.button(LANG.MESSAGE('btn_save_settings')) then
		CORE.saveCurrentConfig()
	end
	imgui.same_line()
	if imgui.button(LANG.MESSAGE('btn_load_settings')) then
		CORE.loadSavedConfigIfExist()
		LANG.applySavedLanguage()
		if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			DATA.initializeTestData()
		else
			DATA.clearTestData()
			STATE.NEEDS_UPDATE = true
		end
	end

	if not STATE.USE_PLUGIN_D2D then
		imgui.new_line()
		imgui.text(LANG.MESSAGE('msg_plugin_missing1'))
		imgui.text(LANG.MESSAGE('msg_plugin_missing2'))
	end

	-- Languages
	if imgui.button(LANG.MESSAGE('btn_apply_language')) then
		LANG.applySelectedLanguage()
	end
	imgui.same_line()
	changed, wantsIt = imgui.combo(LANG.MESSAGE('Languages'), STATE.LOCALE_OPTIONS_SELECTED, STATE.LOCALE_OPTIONS)
	if changed then
		STATE.LOCALE_OPTIONS_SELECTED = wantsIt
	end

	-- Presets
	if imgui.button(LANG.MESSAGE('btn_apply_preset')) then
		CORE.applySelectedPreset()
		STATE.NEEDS_UPDATE = true
	end
	imgui.same_line()
	changed, wantsIt = imgui.combo(LANG.MESSAGE('msg_presets'), STATE.PRESET_OPTIONS_SELECTED, STATE.PRESET_OPTIONS)
	if changed then
		STATE.PRESET_OPTIONS_SELECTED = wantsIt
	end

	if imgui.button(LANG.MESSAGE('btn_set_hotkeys')) then
		STATE.DRAW_WINDOW_HOTKEYS = not STATE.DRAW_WINDOW_HOTKEYS
	end

	imgui.new_line()

	imgui.text(LANG.MESSAGE('Settings'))

	-- Settings
	if imgui.collapsing_header(LANG.MESSAGE('msg_general')) then
		--showSliderForFloatSetting('UPDATE_RATE')

		-- Show test data
		changed, wantsIt = imgui.checkbox(LANG.OPTION('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'),
		                                  CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'))
		if changed then
			CORE.SetCFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN', wantsIt)
			if wantsIt then
				DATA.initializeTestData()
				STATE.NEEDS_UPDATE = true
			else
				DATA.clearTestData()
				STATE.NEEDS_UPDATE = true
			end
		end

		this.showCheckboxForSetting('AUTO_SAVE')
		this.showCheckboxForSetting('SAVE_RESULTS_TO_DISK')

		imgui.new_line()
	end

	if imgui.collapsing_header(LANG.MESSAGE('msg_report')) then
		if imgui.tree_node(LANG.MESSAGE('msg_columns')) then
			this.showSectionSelectColumns()

			imgui.new_line()

			imgui.tree_pop()
		end

		if imgui.tree_node(LANG.MESSAGE('msg_fighters')) then
			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_player'), STATE._FILTERS.INCLUDE_PLAYER)
			if changed then
				CORE.SetReportPlayer(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_otomo'), STATE._FILTERS.INCLUDE_OTOMO)
			if changed then
				CORE.SetReportOtomo(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_servant'), STATE._FILTERS.INCLUDE_SERVANT)
			if changed then
				CORE.SetReportServant(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_servantotomo'), STATE._FILTERS.INCLUDE_SERVANTOTOMO)
			if changed then
				CORE.SetReportServantOtomo(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_boss'), STATE._FILTERS.INCLUDE_LARGE)
			if changed then
				CORE.SetReportLarge(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_fighter_other'), STATE._FILTERS.INCLUDE_OTHER)
			if changed then
				CORE.SetReportOther(wantsIt)
				REPORT.generateReport(STATE.REPORT_MONSTERS)
			end

			imgui.new_line()

			imgui.tree_pop()
		end

		-- draw buttons for each boss monster in the cache
		if imgui.tree_node(LANG.MESSAGE('msg_target')) then
			changed, wantsIt = imgui.checkbox(LANG.OPTION('ADD_TARGETS_TO_REPORT'), CORE.CFG('ADD_TARGETS_TO_REPORT'))
			if changed then
				CORE.SetCFG('ADD_TARGETS_TO_REPORT', wantsIt)
				STATE.NEEDS_UPDATE = true
				CORE.resetReportMonsters()
			end
			imgui.text(LANG.MESSAGE('msg_target_help'))
			local monsterCollection = STATE.TEST_MONSTERS or STATE.LARGE_MONSTERS
			local foundMonster = false
			for enemy,boss in pairs(monsterCollection) do
				foundMonster = true
				local monsterIsInReport = STATE.REPORT_MONSTERS[enemy]
				changed, wantsIt = imgui.checkbox(boss.name, monsterIsInReport)
				if changed then
					if wantsIt then
						CORE.AddMonsterToReport(enemy, boss)
					else
						CORE.RemoveMonsterFromReport(enemy)
					end
					REPORT.generateReport(STATE.REPORT_MONSTERS)
				end
			end

			if not foundMonster then
				imgui.text('  ' .. LANG.MESSAGE('msg_target_none'))
			end

			imgui.new_line()

			imgui.tree_pop()
		end

		-- Filter by damage types
		if imgui.tree_node(LANG.MESSAGE('msg_damagetype')) then
			this.showSectionFilterByDamageType()

			imgui.new_line()

			imgui.tree_pop()
		end

		imgui.new_line()

		-- Report settings
		this.showCheckboxForSetting('COMBINE_OTOMO_WITH_HUNTER')
		this.showCheckboxForSetting('COMBINE_ALL_OTHERS')
		this.showCheckboxForSetting('HIDE_COMBINED_OTHERS')
		this.showCheckboxForSetting('SHOW_MISSING_DAMAGE')

		imgui.new_line()

		this.showCheckboxForSetting('TABLE_SORT_IN_ORDER')
		this.showCheckboxForSetting('TABLE_SORT_ASC')

		imgui.new_line()
	end

	if imgui.collapsing_header(LANG.MESSAGE('msg_rules')) then
		this.showCheckboxForSetting('CONDITION_LIKE_DAMAGE')
		this.showCheckboxForSetting('PDPS_BASED_ON_FIRST_STRIKE')
		this.showCheckboxForSetting('MARIONETTE_IS_PLAYER_DMG')

		imgui.new_line()
	end

	if imgui.collapsing_header(LANG.MESSAGE('msg_privacy')) then
		this.showCheckboxForSetting('DRAW_BAR_TEXT_YOU')
		this.showCheckboxForSetting('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES')

		this.showDropdownForSetting('DRAW_BAR_REVEAL_RANK', 3)

		imgui.new_line()
	end

	-- Visibility
	if imgui.collapsing_header(LANG.MESSAGE('msg_visibility')) then
		imgui.text(LANG.MESSAGE('msg_visibility_help'))

		this.showDropdownForSetting('SHOW_OVERLAY_AT_BOOT'        , 3, 'SHOW_OVERLAY', 2)
		this.showDropdownForSetting('SHOW_OVERLAY_IN_QUEST'       , 3, 'SHOW_OVERLAY')
		this.showDropdownForSetting('SHOW_OVERLAY_POST_QUEST'     , 3, 'SHOW_OVERLAY')
		this.showDropdownForSetting('SHOW_OVERLAY_RESULT_SCREEN'  , 3, 'SHOW_OVERLAY')
		this.showDropdownForSetting('SHOW_OVERLAY_IN_VILLAGE'     , 3, 'SHOW_OVERLAY')
		this.showDropdownForSetting('SHOW_OVERLAY_IN_TRAININGHALL', 3, 'SHOW_OVERLAY')

		imgui.new_line()
	end

	imgui.new_line()

	-- Appearance
	imgui.text(LANG.MESSAGE('msg_appearance'))

	-- Size and position
	if imgui.collapsing_header(LANG.MESSAGE('msg_sizeandposition')) then
		imgui.text(LANG.MESSAGE('msg_sizeandposition_help1'))
		this.showSliderForFloatSetting('TABLE_SCALE')
		imgui.text(LANG.MESSAGE('msg_sizeandposition_help2'))

		imgui.new_line()

		this.showSliderForFloatSetting('TABLE_X')
		this.showSliderForFloatSetting('TABLE_Y')
		this.showSliderForIntSetting('TABLE_WIDTH')

		imgui.new_line()

		this.showCheckboxForSetting('TABLE_GROWS_UPWARD')

		imgui.new_line()
	end

		-- Text
		if imgui.collapsing_header(LANG.MESSAGE('msg_text')) then
			this.showTextboxForSetting('FONT_FAMILY')
			if not STATE.USE_PLUGIN_D2D then
				imgui.text(LANG.MESSAGE('msg_text_help1'))
			else
				imgui.text(LANG.MESSAGE('msg_text_help2'))
			end

			imgui.new_line()

			this.showCheckboxForSetting('TEXT_DRAW_SHADOWS')
			this.showSliderForIntSetting('TEXT_SHADOW_OFFSET_X')
			this.showSliderForIntSetting('TEXT_SHADOW_OFFSET_Y')

			imgui.new_line()

			imgui.text(LANG.MESSAGE('msg_format_help'))
			this.showTextboxForSetting('FORMAT_DPS')

			if imgui.button(LANG.MESSAGE('btn_reset_default_formats')) then
				CORE.SetCFG('FORMAT_DPS', '%.1f')
			end

			imgui.new_line()
		end

	-- Color
	if imgui.collapsing_header(LANG.MESSAGE('msg_color')) then
		this.showSectionColor()
		imgui.new_line()
	end

	-- Title
	if imgui.collapsing_header(LANG.MESSAGE('msg_title')) then
		this.showCheckboxForSetting('DRAW_TITLE')
		this.showCheckboxForSetting('DRAW_TITLE_TEXT')
		this.showCheckboxForSetting('DRAW_TITLE_MONSTER')
		this.showSliderForIntSetting('DRAW_TITLE_HEIGHT')
		this.showCheckboxForSetting('DRAW_TITLE_BACKGROUND')
		this.showSliderForIntSetting('TABLE_HEADER_TEXT_OFFSET_X')

		imgui.new_line()
	end

	-- Header
	if imgui.collapsing_header(LANG.MESSAGE('msg_header')) then
		this.showCheckboxForSetting('DRAW_HEADER')
		this.showSliderForIntSetting('DRAW_HEADER_HEIGHT')
		this.showCheckboxForSetting('DRAW_HEADER_BACKGROUND')

		imgui.new_line()
	end

	-- Rows
	if imgui.collapsing_header(LANG.MESSAGE('msg_rows')) then
		this.showCheckboxForSetting('DRAW_TABLE_BACKGROUND')
		this.showCheckboxForSetting('DRAW_BAR_OUTLINES')
		this.showCheckboxForSetting('DRAW_BAR_COLORBLOCK')
		this.showCheckboxForSetting('DRAW_BAR_USE_PLAYER_COLORS')
		this.showCheckboxForSetting('DRAW_BAR_USE_UNIQUE_COLORS')

		imgui.new_line()

		this.showCheckboxForSetting('DRAW_BAR_RELATIVE_TO_PARTY')
		this.showCheckboxForSetting('USE_MINIMAL_BARS')

		imgui.new_line()

		this.showSliderForIntSetting('TABLE_ROWH')
		this.showSliderForIntSetting('TABLE_ROW_PADDING')

		this.showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_X')
		this.showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_Y')

		imgui.new_line()
	end

	-- Total
	if imgui.collapsing_header(LANG.MESSAGE('msg_total')) then
		this.showCheckboxForSetting('DRAW_TOTAL')
		this.showCheckboxForSetting('DRAW_TOTAL_BACKGROUND')
		this.showSliderForIntSetting('TABLE_TOTAL_TEXT_OFFSET_X')
	end

	-- Column width
	if imgui.collapsing_header(LANG.MESSAGE('msg_width')) then
		for i,currentWidth in ipairs(STATE._CFG['TABLE_COLS_WIDTH']) do
			-- skip 'None'
			if i > 1 then
				-- show slider for width
				local changedWidth, newWidth = imgui.slider_int(LANG.HEADER(i), currentWidth, 0, 250)
				if changedWidth then
					STATE._CFG['TABLE_COLS_WIDTH'][i] = newWidth
				end
			end
		end
		imgui.new_line()
	end

	imgui.new_line()

	-- Cheat
	if imgui.collapsing_header(LANG.MESSAGE('msg_cheats')) then
		this.showCheckboxForSetting('CHEAT_SHOW_MONSTER_HP')
	end

	-- Debug
	if imgui.collapsing_header(LANG.MESSAGE('msg_debug')) then
		if imgui.button(LANG.MESSAGE('btn_open_debug')) then
			STATE.DRAW_WINDOW_DEBUG = not STATE.DRAW_WINDOW_DEBUG
		end

		imgui.new_line()
	end

	imgui.new_line()

	imgui.end_window()
end

this.showSectionFilterByDamageType = function()
	-- draw buttons for damage types
	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_general')) then
		this.showCheckboxForDamageType('PlayerWeapon')
		this.showCheckboxForDamageType('Monster')
		this.showCheckboxForDamageType('marionette')

		imgui.new_line()

		imgui.tree_pop()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_otomo')) then
		this.showCheckboxForDamageType('Otomo')
		this.showCheckboxForDamageType('OtAirouShell014')
		this.showCheckboxForDamageType('OtAirouShell102')

		imgui.new_line()

		imgui.tree_pop()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_moves')) then
		this.showCheckboxForDamageType('Kabutowari')

		imgui.new_line()

		imgui.tree_pop()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_items')) then
		this.showCheckboxForDamageType('BarrelBombSmall')
		this.showCheckboxForDamageType('BarrelBombLarge')
		this.showCheckboxForDamageType('Nitro')
		this.showCheckboxForDamageType('CaptureSmokeBomb')
		this.showCheckboxForDamageType('CaptureBullet')
		this.showCheckboxForDamageType('Kunai')

		imgui.new_line()

		imgui.tree_pop()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_huntinginstallations')) then
		this.showCheckboxForDamageType('HmBallista')
		this.showCheckboxForDamageType('HmCannon')
		this.showCheckboxForDamageType('HmGatling')
		this.showCheckboxForDamageType('HmTrap')
		this.showCheckboxForDamageType('HmNpc')
		this.showCheckboxForDamageType('HmFlameThrower')
		this.showCheckboxForDamageType('HmDragnator')

		imgui.new_line()

		imgui.tree_pop()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_damagetype_unknown')) then
		imgui.text(LANG.MESSAGE('msg_damagetype_unknown_help'))
		this.showCheckboxForDamageType('Makimushi')
		this.showCheckboxForDamageType('OnibiMine')
		this.showCheckboxForDamageType('BallistaHate')
		this.showCheckboxForDamageType('WaterBeetle')
		this.showCheckboxForDamageType('DetonationGrenade')
		this.showCheckboxForDamageType('FlashBoll')
		this.showCheckboxForDamageType('Fg005')
		this.showCheckboxForDamageType('EcBatExplode')
		this.showCheckboxForDamageType('EcWallTrapBugExplode')
		this.showCheckboxForDamageType('EcPiranha')
		this.showCheckboxForDamageType('EcFlash')
		this.showCheckboxForDamageType('EcSandWallShooter')
		this.showCheckboxForDamageType('EcForestWallShooter')
		this.showCheckboxForDamageType('EcSwampLeech')
		this.showCheckboxForDamageType('EcPenetrateFish')
		this.showCheckboxForDamageType('Max')

		imgui.new_line()

		imgui.tree_pop()
	end
end

this.showSectionSelectColumns = function()
	-- draw combo and slider for each column
	for i,currentCol in ipairs(STATE._CFG['TABLE_COLS']) do
		local selected = 1
		-- find option id for selected column
		for idxId,key in ipairs(ENUM.TABLE_COLUMNS_OPTIONS_ID) do
			if key == currentCol then
				selected = idxId
			end
		end
		-- show combo for choice
		local changedCol, newCol = imgui.combo(LANG.MESSAGE('Column') .. ' ' .. i,
		                                       selected, ENUM.TABLE_COLUMNS_OPTIONS_READABLE)
		if changedCol then
			STATE._CFG['TABLE_COLS'][i] = ENUM.TABLE_COLUMNS_OPTIONS_ID[newCol]
		end
	end
end

this.showSectionColor = function()
	if imgui.button(LANG.MESSAGE('btn_apply_colorscheme')) then
		CORE.applySelectedColorscheme()
	end
	imgui.same_line()
	local changed, value = imgui.combo(LANG.MESSAGE('Color_Scheme'),
	                                   STATE.COLORSCHEME_OPTIONS_SELECTED, STATE.COLORSCHEME_OPTIONS)
	if changed then
		STATE.COLORSCHEME_OPTIONS_SELECTED = value
	end

	if imgui.button(LANG.MESSAGE('btn_reset_default_colors')) then
		CORE.loadDefaultColors()
	end

	if imgui.tree_node(LANG.MESSAGE('msg_customize_colors')) then
		this.showColorPicker('TITLE_BG')
		this.showColorPicker('TITLE_FG')
		this.showColorPicker('BAR_BG')
		this.showColorPicker('BAR_OUTLINE')

		imgui.new_line()

		this.showColorPickerForUnique(LANG.COLOR('PLAYER_1'), 'PLAYER', 1)
		this.showColorPickerForUnique(LANG.COLOR('PLAYER_2'), 'PLAYER', 2)
		this.showColorPickerForUnique(LANG.COLOR('PLAYER_3'), 'PLAYER', 3)
		this.showColorPickerForUnique(LANG.COLOR('PLAYER_4'), 'PLAYER', 4)
		this.showColorPicker('OTOMO')
		this.showColorPicker('SERVANT')

		imgui.new_line()

		this.showColorPicker('BAR_DMG_PHYSICAL')
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_PHYSICAL_UNIQUE_1'), 'BAR_DMG_PHYSICAL_UNIQUE', 1)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_PHYSICAL_UNIQUE_2'), 'BAR_DMG_PHYSICAL_UNIQUE', 2)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_PHYSICAL_UNIQUE_3'), 'BAR_DMG_PHYSICAL_UNIQUE', 3)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_PHYSICAL_UNIQUE_4'), 'BAR_DMG_PHYSICAL_UNIQUE', 4)

		imgui.new_line()

		this.showColorPicker('BAR_DMG_ELEMENT')
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_ELEMENT_UNIQUE_1'), 'BAR_DMG_ELEMENT_UNIQUE', 1)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_ELEMENT_UNIQUE_2'), 'BAR_DMG_ELEMENT_UNIQUE', 2)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_ELEMENT_UNIQUE_3'), 'BAR_DMG_ELEMENT_UNIQUE', 3)
		this.showColorPickerForUnique(LANG.COLOR('BAR_DMG_ELEMENT_UNIQUE_4'), 'BAR_DMG_ELEMENT_UNIQUE', 4)

		imgui.new_line()

		this.showColorPicker('BAR_DMG_OTOMO')
		this.showColorPicker('BAR_DMG_POISON')
		this.showColorPicker('BAR_DMG_BLAST')
		this.showColorPicker('BAR_DMG_OTHER')
		this.showColorPicker('BAR_DMG_AILMENT')

		imgui.tree_pop()
	end
end

this.drawHotkeyButton = function(name)
	local hotkey = CORE.HOTKEY(name)
	imgui.text(LANG.HOTKEY(name) .. ':')

	imgui.same_line()

	-- make sure you don't have two buttons with the same text
	local text = LANG.KEY(hotkey.KEY)
	if STATE.HOTKEY_WAITING_TO_REGISTER == name then
		text = LANG.MESSAGE('msg_press_key')
	end
	if imgui.button(text) then
		if STATE.HOTKEY_WAITING_TO_REGISTER == name then
			-- cancel registration
			STATE.HOTKEY_WAITING_TO_REGISTER = nil
			STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER = {}
		else
			-- begin registration
			STATE.HOTKEY_WAITING_TO_REGISTER = name
			STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER = {}
		end
	end
end

this.DrawWindowHotkeys = function()
	local wantsIt

	wantsIt = imgui.begin_window('coavins dps meter - hotkeys', STATE.DRAW_WINDOW_HOTKEYS, STATE.WINDOW_FLAGS)
	if STATE.DRAW_WINDOW_HOTKEYS and not wantsIt then
		STATE.DRAW_WINDOW_HOTKEYS = false
		STATE.HOTKEY_WAITING_TO_REGISTER = nil
		STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER = {}
	end

	imgui.text('Supports modifiers (Shift,Ctrl,Alt)')

	imgui.new_line()

	this.drawHotkeyButton('TOGGLE_OVERLAY')
	this.drawHotkeyButton('MONSTER_NEXT')
	this.drawHotkeyButton('MONSTER_PREV')

	imgui.end_window()
end

this.DrawWindowDebug = function()
	local changed, wantsIt

	wantsIt = imgui.begin_window('coavins dps meter - debug', STATE.DRAW_WINDOW_DEBUG, STATE.WINDOW_FLAGS)
	if STATE.DRAW_WINDOW_DEBUG and not wantsIt then
		STATE.DRAW_WINDOW_DEBUG = false
	end

	this.showCheckboxForSetting('DEBUG_ENABLED')

	imgui.new_line()

	this.showCheckboxForSetting('DEBUG_SHOW_MISSING_DAMAGE')
	imgui.text('You can use this setting to see how much damage is not being captured.')
	imgui.text('Shows the result of the following formula: (x-y)')
	imgui.text('Where x is the amount of health that the game says the monster is missing')
	imgui.text('and y is the amount of damage that this mod says has been done.')
	imgui.text('If the mod is working perfectly, then these values will be the same')
	imgui.text('For accurate results, make sure to enable all filters.')

	imgui.new_line()

	this.showCheckboxForSetting('DEBUG_SHOW_ATTACKER_ID')

	imgui.new_line()

	-- Enabled
	changed, wantsIt = imgui.checkbox(LANG.MESSAGE('msg_not_use_hooks'), not STATE.HOOKS_ENABLED)
	if changed then
		STATE.HOOKS_ENABLED = not wantsIt
	end
	imgui.text('Use this setting to troubleshoot stuttering or freezing')
	imgui.text('during the quest, such as when attacks connect with the enemy.')
	imgui.text('While this box is checked, data not various things will not be')
	imgui.text('collected and your numbers will be wrong for the rest of the quest')

	imgui.new_line()

	imgui.end_window()
end

return this
