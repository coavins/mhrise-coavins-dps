local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'
local DATA   = require 'mhrise-coavins-dps.data'
local REPORT = require 'mhrise-coavins-dps.report'

local this = {}

this.showTextboxForSetting = function(setting)
	local changed, value = imgui.input_text(CORE.TXT(setting), CORE.CFG(setting))
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showCheckboxForSetting = function(setting)
	local changed, value = imgui.checkbox(CORE.TXT(setting), CORE.CFG(setting))
	if changed then
		CORE.SetCFG(setting, value)
		STATE.NEEDS_UPDATE = true
	end
end

this.showSliderForFloatSetting = function(setting)
	local changed, value = imgui.slider_float(
		CORE.TXT(setting), CORE.CFG(setting), CORE.MIN(setting), CORE.MAX(setting), '%.2f'
	)
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showSliderForIntSetting = function(setting)
	local changed, value = imgui.slider_int(
		CORE.TXT(setting), CORE.CFG(setting), CORE.MIN(setting), CORE.MAX(setting), '%d'
	)
	if changed then
		CORE.SetCFG(setting, value)
	end
end

this.showColorPicker = function(text, setting)
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

this.showCheckboxForAttackerType = function(type)
	local typeIsInReport = STATE._FILTERS.ATTACKER_TYPES[type]
	local changed, wantsIt = imgui.checkbox(ENUM.ATTACKER_TYPE_TEXT[type], typeIsInReport)
	if changed then
		if wantsIt then
			CORE.AddAttackerTypeToReport(type)
		else
			CORE.RemoveAttackerTypeFromReport(type)
		end
		REPORT.generateReport(STATE.REPORT_MONSTERS)
	end
end

this.showAppearanceSection = function()
	if imgui.collapsing_header('Size and position') then
		imgui.text('Scale Overlay')
		this.showSliderForFloatSetting('TABLE_SCALE')
		imgui.text('Save changes and RESET SCRIPTS to apply scaling to text')

		imgui.new_line()

		this.showSliderForFloatSetting('TABLE_X')
		this.showSliderForFloatSetting('TABLE_Y')
		this.showSliderForIntSetting('TABLE_WIDTH')

		imgui.new_line()

		this.showCheckboxForSetting('TABLE_GROWS_UPWARD')

		imgui.new_line()
	end

	if imgui.collapsing_header('Title') then
		this.showCheckboxForSetting('DRAW_TITLE')
		this.showCheckboxForSetting('DRAW_TITLE_TEXT')
		this.showCheckboxForSetting('DRAW_TITLE_MONSTER')
		this.showSliderForIntSetting('DRAW_TITLE_HEIGHT')
		this.showCheckboxForSetting('DRAW_TITLE_BACKGROUND')

		imgui.new_line()
	end

	if imgui.collapsing_header('Header') then
		this.showCheckboxForSetting('DRAW_HEADER')
		this.showSliderForIntSetting('DRAW_HEADER_HEIGHT')
		this.showCheckboxForSetting('DRAW_HEADER_BACKGROUND')

		this.showSliderForIntSetting('TABLE_HEADER_TEXT_OFFSET_X')

		imgui.new_line()
	end

	if imgui.collapsing_header('Rows') then
		this.showCheckboxForSetting('DRAW_TABLE_BACKGROUND')
		this.showCheckboxForSetting('DRAW_BAR_OUTLINES')
		this.showCheckboxForSetting('DRAW_BAR_COLORBLOCK')
		this.showCheckboxForSetting('DRAW_BAR_USE_PLAYER_COLORS')
		this.showCheckboxForSetting('DRAW_BAR_USE_UNIQUE_COLORS')

		imgui.new_line()

		this.showCheckboxForSetting('DRAW_BAR_RELATIVE_TO_PARTY')
		this.showCheckboxForSetting('USE_MINIMAL_BARS')
		this.
		imgui.new_line()

		this.showCheckboxForSetting('TABLE_SORT_ASC')
		this.showCheckboxForSetting('TABLE_SORT_IN_ORDER')

		imgui.new_line()

		this.showSliderForIntSetting('TABLE_ROWH')
		this.showSliderForIntSetting('TABLE_ROW_PADDING')

		this.showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_X')
		this.showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_Y')

		imgui.new_line()
	end
end

this.showTextSection = function()
	this.showTextboxForSetting('FONT_FAMILY')
	if not STATE.USE_PLUGIN_D2D then
		imgui.text('Requires plugin: reframework-d2d')
	else
		imgui.text('Save changes and RESET SCRIPTS to apply changes to font')
	end

	imgui.new_line()

	this.showCheckboxForSetting('TEXT_DRAW_SHADOWS')
	this.showSliderForIntSetting('TEXT_SHADOW_OFFSET_X')
	this.showSliderForIntSetting('TEXT_SHADOW_OFFSET_Y')
end

this.showSelectDataSection = function()
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
		local changedCol, newCol = imgui.combo('Column ' .. i, selected, ENUM.TABLE_COLUMNS_OPTIONS_READABLE)
		if changedCol then
			STATE._CFG['TABLE_COLS'][i] = ENUM.TABLE_COLUMNS_OPTIONS_ID[newCol]
		end
	end
end

this.showColumnWidthSection = function()
	for i,currentWidth in ipairs(STATE._CFG['TABLE_COLS_WIDTH']) do
		-- skip 'None'
		if i > 1 then
			-- show slider for width
			local changedWidth, newWidth = imgui.slider_int(ENUM.TABLE_COLUMNS[i], currentWidth, 0, 250)
			if changedWidth then
				STATE._CFG['TABLE_COLS_WIDTH'][i] = newWidth
			end
		end
	end
end

this.showFilterSection = function()
	if imgui.tree_node('Combatants') then
		local changed, wantsIt = imgui.checkbox('Show buddies', STATE._FILTERS.INCLUDE_OTOMO)
		if changed then
			STATE._FILTERS.INCLUDE_OTOMO = wantsIt
			REPORT.generateReport(STATE.REPORT_MONSTERS)
		end

		--[[
		changed, wantsIt = imgui.checkbox('Show Wyvern Riding', _FILTERS.INCLUDE_OTHER)
		if changed then
			_FILTERS.INCLUDE_OTHER = wantsIt
			generateReport(REPORT_MONSTERS)
		end
		]]

		changed, wantsIt = imgui.checkbox('Show monsters and villagers', STATE._FILTERS.INCLUDE_OTHER)
		if changed then
			STATE._FILTERS.INCLUDE_OTHER = wantsIt
			REPORT.generateReport(STATE.REPORT_MONSTERS)
		end

		imgui.new_line()

		imgui.tree_pop()
	end

	-- draw buttons for each boss monster in the cache
	if imgui.tree_node('Large monsters') then
		local monsterCollection = STATE.TEST_MONSTERS or STATE.LARGE_MONSTERS
		local foundMonster = false
		for enemy,boss in pairs(monsterCollection) do
			foundMonster = true
			local monsterIsInReport = STATE.REPORT_MONSTERS[enemy]
			local changed, wantsIt = imgui.checkbox('Include ' .. boss.name, monsterIsInReport)
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
			imgui.text('(n/a)')
		end

		imgui.new_line()

		imgui.tree_pop()
	end

	-- draw buttons for attacker types
	if imgui.tree_node('Attack type') then
		if imgui.tree_node('General') then
			this.showCheckboxForAttackerType('PlayerWeapon')
			this.showCheckboxForAttackerType('Otomo')
			this.showCheckboxForAttackerType('Invalid') -- Monster
			this.showCheckboxForAttackerType('marionette')

			imgui.new_line()

			imgui.tree_pop()
		end

		if imgui.tree_node('Items') then
			this.showCheckboxForAttackerType('BarrelBombSmall')
			this.showCheckboxForAttackerType('BarrelBombLarge')
			this.showCheckboxForAttackerType('Nitro')
			this.showCheckboxForAttackerType('CaptureSmokeBomb')
			this.showCheckboxForAttackerType('CaptureBullet')
			this.showCheckboxForAttackerType('Kunai')

			imgui.new_line()

			imgui.tree_pop()
		end

		if imgui.tree_node('Installations') then
			this.showCheckboxForAttackerType('HmBallista')
			this.showCheckboxForAttackerType('HmCannon')
			this.showCheckboxForAttackerType('HmGatling')
			this.showCheckboxForAttackerType('HmTrap')
			this.showCheckboxForAttackerType('HmNpc')
			this.showCheckboxForAttackerType('HmFlameThrower')
			this.showCheckboxForAttackerType('HmDragnator')

			imgui.new_line()

			imgui.tree_pop()
		end

		if imgui.tree_node('Unknown') then
			this.showCheckboxForAttackerType('Makimushi')
			this.showCheckboxForAttackerType('OnibiMine')
			this.showCheckboxForAttackerType('BallistaHate')
			this.showCheckboxForAttackerType('WaterBeetle')
			this.showCheckboxForAttackerType('DetonationGrenade')
			this.showCheckboxForAttackerType('Kabutowari')
			this.showCheckboxForAttackerType('FlashBoll')
			this.showCheckboxForAttackerType('Fg005')
			this.showCheckboxForAttackerType('EcBatExplode')
			this.showCheckboxForAttackerType('EcWallTrapBugExplode')
			this.showCheckboxForAttackerType('EcPiranha')
			this.showCheckboxForAttackerType('EcFlash')
			this.showCheckboxForAttackerType('EcSandWallShooter')
			this.showCheckboxForAttackerType('EcForestWallShooter')
			this.showCheckboxForAttackerType('EcSwampLeech')
			this.showCheckboxForAttackerType('EcPenetrateFish')
			this.showCheckboxForAttackerType('Max')

			imgui.new_line()

			imgui.tree_pop()
		end

		imgui.tree_pop()
	end
end

this.showColorSection = function()
	if imgui.button('Apply color scheme') then
		CORE.applySelectedColorscheme()
	end
	imgui.same_line()
	local changed, value = imgui.combo('Color Scheme', STATE.COLORSCHEME_OPTIONS_SELECTED, STATE.COLORSCHEME_OPTIONS)
	if changed then
		STATE.COLORSCHEME_OPTIONS_SELECTED = value
	end

	if imgui.button('Reset to default colors') then
		CORE.loadDefaultColors()
	end

	if imgui.tree_node('Customize colors') then
		this.showColorPicker('Title background', 'TITLE_BG')
		this.showColorPicker('Title foreground', 'TITLE_FG')
		this.showColorPicker('Bar background', 'BAR_BG')
		this.showColorPicker('Bar outline', 'BAR_OUTLINE')

		imgui.new_line()

		this.showColorPickerForUnique('Player 1', 'PLAYER', 1)
		this.showColorPickerForUnique('Player 2', 'PLAYER', 2)
		this.showColorPickerForUnique('Player 3', 'PLAYER', 3)
		this.showColorPickerForUnique('Player 4', 'PLAYER', 4)
		this.showColorPicker('Buddies', 'OTOMO')

		imgui.new_line()

		this.showColorPicker('Physical damage', 'BAR_DMG_PHYSICAL')
		this.showColorPickerForUnique('P1 Physical Damage', 'BAR_DMG_PHYSICAL_UNIQUE', 1)
		this.showColorPickerForUnique('P2 Physical Damage', 'BAR_DMG_PHYSICAL_UNIQUE', 2)
		this.showColorPickerForUnique('P3 Physical Damage', 'BAR_DMG_PHYSICAL_UNIQUE', 3)
		this.showColorPickerForUnique('P4 Physical Damage', 'BAR_DMG_PHYSICAL_UNIQUE', 4)

		imgui.new_line()

		this.showColorPicker('Element damage', 'BAR_DMG_ELEMENT')
		this.showColorPickerForUnique('P1 Element Damage', 'BAR_DMG_ELEMENT_UNIQUE', 1)
		this.showColorPickerForUnique('P2 Element Damage', 'BAR_DMG_ELEMENT_UNIQUE', 2)
		this.showColorPickerForUnique('P3 Element Damage', 'BAR_DMG_ELEMENT_UNIQUE', 3)
		this.showColorPickerForUnique('P4 Element Damage', 'BAR_DMG_ELEMENT_UNIQUE', 4)

		imgui.new_line()

		this.showColorPicker('Buddy damage', 'BAR_DMG_OTOMO')
		this.showColorPicker('Poison damage', 'BAR_DMG_POISON')
		this.showColorPicker('Blast damage', 'BAR_DMG_BLAST')
		this.showColorPicker('Other damage', 'BAR_DMG_OTHER')
		this.showColorPicker('Ailment buildup', 'BAR_DMG_AILMENT')

		imgui.tree_pop()
	end
end

this.DrawWindowSettings = function()
	local changed, wantsIt, value

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
	changed, wantsIt = imgui.checkbox('Enabled', STATE.DPS_ENABLED)
	if changed then
		STATE.DPS_ENABLED = wantsIt
	end

	imgui.same_line()
	if imgui.button('Reset to default') then
		CORE.loadDefaultConfig()
		if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			DATA.initializeTestData()
		else
			DATA.clearTestData()
			STATE.NEEDS_UPDATE = true
		end
	end

	imgui.same_line()
	if imgui.button('Clear combat data') then
		if DATA.isInTestMode() then
			-- reinitialize test data
			DATA.initializeTestData()
		else
			CORE.cleanUpData('user clicked reset')
		end

		STATE.NEEDS_UPDATE = true
	end

	imgui.same_line()
	if imgui.button('Set Hotkeys') then
		STATE.DRAW_WINDOW_HOTKEYS = not STATE.DRAW_WINDOW_HOTKEYS
	end

	imgui.new_line()

	if imgui.button('Save settings') then
		CORE.saveCurrentConfig()
	end
	imgui.same_line()
	if imgui.button('Load settings') then
		CORE.loadSavedConfigIfExist()
		if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			DATA.initializeTestData()
		else
			DATA.clearTestData()
			STATE.NEEDS_UPDATE = true
		end
	end

	this.showCheckboxForSetting('AUTO_SAVE')

	if not STATE.USE_PLUGIN_D2D then
		imgui.new_line()
		imgui.text('Missing plugin: reframework-d2d')
		imgui.text('Some features are not available')
	end

	-- Presets
	imgui.new_line()

	if imgui.button('Apply preset') then
		CORE.applySelectedPreset()
	end
	imgui.same_line()
	changed, value = imgui.combo('Presets', STATE.PRESET_OPTIONS_SELECTED, STATE.PRESET_OPTIONS)
	if changed then
		STATE.PRESET_OPTIONS_SELECTED = value
	end

	imgui.new_line()

	-- Settings
	if imgui.collapsing_header('General') then
		--showSliderForFloatSetting('UPDATE_RATE')
		this.showCheckboxForSetting('HIDE_OVERLAY_IN_VILLAGE')

		-- Show test data
		changed, wantsIt = imgui.checkbox('Show test data while menu is open', CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'))
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

		this.showCheckboxForSetting('SAVE_RESULTS_TO_DISK')

		imgui.new_line()

		this.showCheckboxForSetting('COMBINE_OTOMO_WITH_HUNTER')
		this.showCheckboxForSetting('CONDITION_LIKE_DAMAGE')
		this.showCheckboxForSetting('PDPS_BASED_ON_FIRST_STRIKE')
		this.showCheckboxForSetting('MARIONETTE_IS_PLAYER_DMG')

		imgui.new_line()
	end

	if imgui.collapsing_header('Colors') then
		this.showColorSection()
		imgui.new_line()
	end

	if imgui.collapsing_header('Privacy') then
		this.showCheckboxForSetting('DRAW_BAR_TEXT_YOU')
		this.showCheckboxForSetting('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES')

		local options = {}
		options[1] = 'Hide'
		options[2] = 'Show HR'
		options[3] = 'Show MR'
		changed, value = imgui.combo(CORE.TXT('DRAW_BAR_REVEAL_RANK'), CORE.CFG('DRAW_BAR_REVEAL_RANK'), options)
		if changed then
			CORE.SetCFG('DRAW_BAR_REVEAL_RANK', value)
			STATE.NEEDS_UPDATE = true
		end


		imgui.new_line()
	end

	imgui.new_line()

	if imgui.collapsing_header('Select columns') then
		this.showSelectDataSection()
		imgui.new_line()
	end

	if imgui.collapsing_header('Select filters') then
		this.showFilterSection()
		imgui.new_line()
	end

	imgui.new_line()

	this.showAppearanceSection()

	if imgui.collapsing_header('Text') then
		this.showTextSection()
		imgui.new_line()
	end

	if imgui.collapsing_header('Column width') then
		this.showColumnWidthSection()
		imgui.new_line()
	end

	imgui.new_line()

	if imgui.collapsing_header('Debug') then
		if imgui.button('open debug menu') then
			STATE.DRAW_WINDOW_DEBUG = not STATE.DRAW_WINDOW_DEBUG
		end

		imgui.new_line()
	end

	imgui.new_line()

	imgui.end_window()
end

this.drawHotkeyButton = function(name)
	local hotkey = CORE.HOTKEY(name)
	imgui.text(hotkey.TEXT .. ':')

	imgui.same_line()

	-- make sure you don't have two buttons with the same text
	local text = ENUM.ENUM_KEYBOARD_KEY[hotkey.KEY]
	if STATE.HOTKEY_WAITING_TO_REGISTER == name then
		text = 'Press key...'
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
	changed, wantsIt = imgui.checkbox('Do not use SDK hooks', not STATE.HOOKS_ENABLED)
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
