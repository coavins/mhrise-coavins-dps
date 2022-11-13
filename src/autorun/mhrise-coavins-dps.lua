-- dps meter for monster hunter rise
-- written by github.com/coavins

local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'
local DATA   = require 'mhrise-coavins-dps.data'
local REPORT = require 'mhrise-coavins-dps.report'
local DRAW   = require 'mhrise-coavins-dps.draw'
local HOTKEY = require 'mhrise-coavins-dps.hotkey'
local UI     = require 'mhrise-coavins-dps.ui'
local HOOK   = require 'mhrise-coavins-dps.hook'
local EXPORT = require 'mhrise-coavins-dps.export'
local LANG   = require 'mhrise-coavins-dps.lang'

local function sanityCheck()
	if not CORE.CFG('UPDATE_RATE') or tonumber(CORE.CFG('UPDATE_RATE')) == nil then
		CORE.SetCFG('UPDATE_RATE', 0.5)
	end
	if CORE.CFG('UPDATE_RATE') < 0.01 then
		CORE.SetCFG('UPDATE_RATE', 0.01)
	end
	if CORE.CFG('UPDATE_RATE') > 3 then
		CORE.SetCFG('UPDATE_RATE', 3)
	end
end

-- main update function
local function dpsUpdate()
	-- update screen dimensions
	CORE.readScreenDimensions()

	-- if we are in an active combat area
	if STATE.IS_IN_QUEST or STATE.IS_IN_TRAININGHALL or STATE.NEEDS_UPDATE then
		-- get player id
		STATE.MY_PLAYER_ID = STATE.MANAGER.PLAYER:call("getMasterPlayerID")

		if STATE.IS_IN_QUEST or STATE.IS_IN_TRAININGHALL then
			-- get info for players
			CORE.updatePlayers()
		end

		-- ensure bosses are initialized
		local bossCount = STATE.MANAGER.ENEMY:call("getBossEnemyCount")
		for i = 0, bossCount-1 do
			local bossEnemy = STATE.MANAGER.ENEMY:call("getBossEnemy", i)

			if not STATE.LARGE_MONSTERS[bossEnemy] then
				-- initialize data for this boss
				DATA.initializeBossMonster(bossEnemy)
			end
		end

		-- ensure servants are initialized
		local servantIdList = STATE.MANAGER.SERVANT:call("getQuestServantIdList")
		if servantIdList then
			local servantCount = servantIdList:call("get_Count")
			for i = 0, servantCount-1 do
				local servantId = servantIdList:call("get_Item", i)
				if not STATE.SERVANTS[servantId] then
					DATA.initializeServant(servantId)
				end
			end
		end

		-- generate report for selected bosses
		REPORT.generateReport(STATE.REPORT_MONSTERS)
	end
end

-- update based on wall clock
local function dpsUpdateOccasionally(realSeconds)
	if realSeconds > STATE.LAST_UPDATE_TIME + CORE.CFG('UPDATE_RATE') then
		dpsUpdate()
		STATE.LAST_UPDATE_TIME = realSeconds
	-- don't delay the update for more than one second
	elseif realSeconds + 1 < STATE.LAST_UPDATE_TIME then
		STATE.LAST_UPDATE_TIME = realSeconds
	end
end

-- runs every frame
local function dpsFrame()
	-- make sure resources are initialized
	if not CORE.hasManagedResources() then
		return
	end

	if not CORE.hasNativeResources() then
		return
	end

	-- get our function hooks if we don't have them yet
	HOOK.tryHookSdk()

	--do some initialization if needed
	if STATE.SCREEN_W == 0 or STATE.SCREEN_H == 0 then
		CORE.readScreenDimensions()
	end

	local wasInQuest = STATE.IS_IN_QUEST
	local wasPostQuest = STATE.IS_POST_QUEST
	local wasResultScreen = STATE.IS_RESULT_SCREEN
	local wasInVillage = STATE.IS_IN_VILLAGE
	local wasInTraininghall = STATE.IS_IN_TRAININGHALL

	local villageArea = 0
	local questStatus = STATE.MANAGER.QUEST:get_field("_QuestStatus")
	if not questStatus then
		STATE.IS_IN_QUEST = false
		STATE.IS_POST_QUEST = false
	else
		STATE.IS_IN_QUEST = (questStatus == 2)
		STATE.IS_POST_QUEST = (questStatus > 2)
	end

	if STATE.IS_IN_QUEST or STATE.IS_POST_QUEST then
		STATE.IS_IN_VILLAGE = false
	else
		STATE.IS_IN_VILLAGE = true
	end

	local isPreSuccess = STATE.MANAGER.QUEST:get_field("_IsPreSuccess")
	if STATE.IS_POST_QUEST and isPreSuccess == false then
		STATE.IS_RESULT_SCREEN = true
	else
		STATE.IS_RESULT_SCREEN = false
	end

	if STATE.IS_IN_VILLAGE then
		-- VillageAreaManager is unreliable, not always there, stale references
		-- get a new reference
		STATE.MANAGER.AREA = sdk.get_managed_singleton("snow.VillageAreaManager")
		if STATE.MANAGER.AREA then
			villageArea = STATE.MANAGER.AREA:get_field("<_CurrentAreaNo>k__BackingField")
		end
	end

	STATE.IS_IN_TRAININGHALL = (villageArea == 5 and STATE.IS_IN_VILLAGE)

	-- Handle area transitions
	-- Entered training hall
	if STATE.IS_IN_TRAININGHALL and not wasInTraininghall then
		CORE.cleanUpData('entered training hall')

		CORE.changeOverlayVisibility('SHOW_OVERLAY_IN_TRAININGHALL')

	-- Entered quest
	elseif STATE.IS_IN_QUEST and not wasInQuest then
		CORE.cleanUpData('entered a quest')

		CORE.changeOverlayVisibility('SHOW_OVERLAY_IN_QUEST')
		CORE.getQuestNo()
		CORE.getQuestMainMonsterId()

	-- Entered post-quest sequence
	elseif STATE.IS_POST_QUEST and not wasPostQuest then
		CORE.log_info('quest complete')
		CORE.changeOverlayVisibility('SHOW_OVERLAY_POST_QUEST')

		-- export data
		if CORE.CFG('SAVE_RESULTS_TO_DISK') then
			CORE.getWeaponInfo()
			CORE.getWeaponId()
			CORE.getPlayerSkill()
			CORE.getOtomoInfo()
			CORE.getSwitchActionId()

			EXPORT.exportData()
		end

		-- make sure we do one last update
		STATE.NEEDS_UPDATE = true
	end

	-- Entered results screen
	if STATE.IS_RESULT_SCREEN and not wasResultScreen then
		CORE.log_debug('result screen')
		CORE.changeOverlayVisibility('SHOW_OVERLAY_RESULT_SCREEN')

	-- Entered the village
	elseif STATE.IS_IN_VILLAGE and not wasInVillage then
		CORE.changeOverlayVisibility('SHOW_OVERLAY_IN_VILLAGE')

	-- Left the training hall
	elseif STATE.IS_IN_VILLAGE and not STATE.IS_IN_TRAININGHALL and wasInTraininghall then
		CORE.changeOverlayVisibility('SHOW_OVERLAY_IN_VILLAGE')

	end

	if STATE.IS_IN_QUEST or STATE.IS_POST_QUEST then
		CORE.SetQuestDuration(STATE.MANAGER.QUEST:call("getQuestElapsedTimeSec"))
	elseif STATE.IS_IN_TRAININGHALL then
		CORE.SetQuestDuration(STATE.MANAGER.AREA:call("get_TrainingHallStayTime"))
	end

	STATE.IS_ONLINE = (STATE.MANAGER.LOBBY and STATE.MANAGER.LOBBY:call("IsQuestOnline")) or false

	HOTKEY.updateHeldHotkeyModifiers()
	for name,_ in pairs(STATE._HOTKEYS) do
		HOTKEY.checkHotkeyActivated(name)
	end

	-- if the window is open
	if STATE.DRAW_WINDOW_SETTINGS or STATE.NEEDS_UPDATE then
		-- update every frame
		dpsUpdate()
		STATE.NEEDS_UPDATE = false
	-- when a quest is active
	elseif STATE.IS_IN_QUEST then
		dpsUpdateOccasionally(STATE.QUEST_DURATION)
	-- when you are in the training area
	elseif STATE.IS_IN_TRAININGHALL then
		dpsUpdateOccasionally(STATE.QUEST_DURATION)
	end

	-- if d2d is not enabled
	if not STATE.USE_PLUGIN_D2D then
		DRAW.dpsDraw()
	end
end

--#region Initialization

-- make sure data files exist in the right place
if not CORE.isProperlyInstalled() then
	return -- halt script
end

-- load default settings
CORE.loadDefaultConfig()

-- load presets into cache
CORE.loadPresets()
CORE.loadColorschemes()
LANG.loadLocales()

-- load any saved settings
CORE.loadSavedConfigIfExist()
-- apply saved language
LANG.applySavedLanguage()

-- perform sanity checks
sanityCheck()

-- show or hide overlay as desired
CORE.changeOverlayVisibility('SHOW_OVERLAY_AT_BOOT')

-- initialize an empty report
REPORT.generateReport({})

-- make sure this table has all modifiers in it
for key,_ in pairs(ENUM.ENUM_KEYBOARD_MODIFIERS) do
	STATE.CURRENTLY_HELD_MODIFIERS[key] = false
end

if STATE.USE_PLUGIN_D2D then
	-- register font and draw method with d2d plugin
	d2d.register(function()
		STATE.FONT = d2d.create_font(CORE.CFG('FONT_FAMILY'), 14 * CORE.CFG('TABLE_SCALE'))
	end, DRAW.dpsDraw)
else
	CORE.log_info('reframework-d2d plugin is disabled')
end

STATE.IMGUI_FONT = STATE.CHANGE_IMGUI_FONT
STATE.CHANGE_IMGUI_FONT = nil

--#endregion

--#region REFramework

---@diagnostic disable-next-line: param-type-mismatch
re.on_frame(function()
	if STATE.IMGUI_FONT then
		imgui.push_font(STATE.IMGUI_FONT)
	end

	if STATE.DRAW_WINDOW_SETTINGS then
		UI.DrawWindowSettings()
	end

	if STATE.DRAW_WINDOW_HOTKEYS then
		UI.DrawWindowHotkeys()
	else
		STATE.HOTKEY_WAITING_TO_REGISTER = nil
		STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER = nil
	end

	if STATE.DRAW_WINDOW_DEBUG then
		UI.DrawWindowDebug()
	end

	HOTKEY.registerWaitingHotkeys()

	if STATE.DPS_ENABLED then
		dpsFrame()
	end

	STATE.ASSIGNED_HOTKEY_THIS_FRAME = false

	if STATE.IMGUI_FONT then
		imgui.pop_font()
	end
	if STATE.CHANGE_IMGUI_FONT then
		STATE.IMGUI_FONT = STATE.CHANGE_IMGUI_FONT
		STATE.CHANGE_IMGUI_FONT = nil
	end
end)

---@diagnostic disable-next-line: param-type-mismatch
re.on_draw_ui(function()
	imgui.begin_group()
	imgui.text('coavins dps meter')

	imgui.same_line()

	local buttonText = LANG.MESSAGE('btn_open_settings')
	if STATE.DRAW_WINDOW_SETTINGS then
		buttonText = LANG.MESSAGE('btn_close_settings')
	end
	if imgui.button(buttonText) then
		STATE.DRAW_WINDOW_SETTINGS = not STATE.DRAW_WINDOW_SETTINGS

		if STATE.DRAW_WINDOW_SETTINGS then
			if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
				DATA.initializeTestData()
				STATE.NEEDS_UPDATE = true
			end
		else
			if DATA.isInTestMode() then
				DATA.clearTestData()
				STATE.NEEDS_UPDATE = true
			end
		end
	end

	imgui.end_group()
end)

---@diagnostic disable-next-line: param-type-mismatch
re.on_config_save(function()
	if CORE.CFG('AUTO_SAVE') then
		CORE.saveCurrentConfig()
	end
end)

--#endregion

CORE.log_info('init complete')
