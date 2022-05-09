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

		-- get info for players
		CORE.updatePlayers()

		-- ensure bosses are initialized
		local bossCount = STATE.MANAGER.ENEMY:call("getBossEnemyCount")
		for i = 0, bossCount-1 do
			local bossEnemy = STATE.MANAGER.ENEMY:call("getBossEnemy", i)

			if not STATE.LARGE_MONSTERS[bossEnemy] then
				-- initialize data for this boss
				DATA.initializeBossMonster(bossEnemy)
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
	local wasInTraininghall = STATE.IS_IN_TRAININGHALL

	local villageArea = 0
	local questStatus = STATE.MANAGER.QUEST:get_field("_QuestStatus")
	STATE.IS_IN_QUEST = (questStatus == 2)
	STATE.IS_POST_QUEST = (questStatus > 2)

	if not STATE.IS_IN_QUEST and not STATE.IS_POST_QUEST then
		-- VillageAreaManager is unreliable, not always there, stale references
		-- get a new reference
		STATE.MANAGER.AREA = sdk.get_managed_singleton("snow.VillageAreaManager")
		if STATE.MANAGER.AREA then
			villageArea = STATE.MANAGER.AREA:get_field("<_CurrentAreaNo>k__BackingField")
		end
	end

	STATE.IS_IN_TRAININGHALL = (villageArea == 5 and not STATE.IS_IN_QUEST and not STATE.IS_POST_QUEST)

	-- if we changed places, clear all data
	if STATE.IS_IN_TRAININGHALL and not wasInTraininghall then
		CORE.cleanUpData('entered training hall')
	elseif STATE.IS_IN_QUEST and not wasInQuest then
		CORE.cleanUpData('entered a quest')
	elseif STATE.IS_POST_QUEST and not wasPostQuest then
		-- quest complete, export combat data to disk
		CORE.log_info('quest complete')
		if CORE.CFG('SAVE_RESULTS_TO_DISK') then
			EXPORT.exportData()
		end
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

--#region REFramework

re.on_frame(function()
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
end)

re.on_draw_ui(function()
	imgui.begin_group()
	imgui.text('coavins dps meter')

	imgui.same_line()

	if imgui.button('open settings') then
		STATE.DRAW_WINDOW_SETTINGS = not STATE.DRAW_WINDOW_SETTINGS

		if STATE.DRAW_WINDOW_SETTINGS then
			if CORE.CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
				DATA.initializeTestData()
			end
		else
			if DATA.isInTestMode() then
				DATA.clearTestData()
				dpsUpdate()
			end
		end
	end

	imgui.end_group()
end)

re.on_config_save(function()
	if CORE.CFG('AUTO_SAVE') then
		CORE.saveCurrentConfig()
	end
end)

--#endregion

-- last minute initialization

-- load default settings
if not CORE.loadDefaultConfig() then
	return -- halt script
end

-- load any saved settings
CORE.loadSavedConfigIfExist()

-- load presets into cache
CORE.loadPresets()
CORE.loadColorschemes()

-- perform sanity checks
sanityCheck()

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

CORE.log_info('init complete')
