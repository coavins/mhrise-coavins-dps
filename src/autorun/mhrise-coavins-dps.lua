-- dps meter for monster hunter rise
-- written by github.com/coavins

--#region enums

-- list of available columns for the table
-- the values here will appear in the header, if enabled
-- only add new columns to the end of this table
local TABLE_COLUMNS = {}
TABLE_COLUMNS[1] = 'None'
TABLE_COLUMNS[2] = 'HR'
TABLE_COLUMNS[3] = 'Name'
TABLE_COLUMNS[4] = 'mDPS'
TABLE_COLUMNS[5] = 'Damage'
TABLE_COLUMNS[6] = 'Party%'
TABLE_COLUMNS[7] = 'Best%'
TABLE_COLUMNS[8] = 'Hits'
TABLE_COLUMNS[9] = 'MaxHit'
TABLE_COLUMNS[10] = 'qDPS'

-- list of columns sorted for the combo box
local TABLE_COLUMNS_OPTIONS_ID = {}
TABLE_COLUMNS_OPTIONS_ID[1] = 1
TABLE_COLUMNS_OPTIONS_ID[2] = 2
TABLE_COLUMNS_OPTIONS_ID[3] = 3
TABLE_COLUMNS_OPTIONS_ID[4] = 10
TABLE_COLUMNS_OPTIONS_ID[5] = 4
TABLE_COLUMNS_OPTIONS_ID[6] = 5
TABLE_COLUMNS_OPTIONS_ID[7] = 6
TABLE_COLUMNS_OPTIONS_ID[8] = 7
TABLE_COLUMNS_OPTIONS_ID[9] = 8
TABLE_COLUMNS_OPTIONS_ID[10] = 9

local TABLE_COLUMNS_OPTIONS_READABLE = {}
for i,col in ipairs(TABLE_COLUMNS_OPTIONS_ID) do
	TABLE_COLUMNS_OPTIONS_READABLE[i] = TABLE_COLUMNS[col]
end

-- via.hid.KeyboardKey
local ENUM_KEYBOARD_KEY = {}
ENUM_KEYBOARD_KEY[0] = 'None'
ENUM_KEYBOARD_KEY[1] = 'LButton'
ENUM_KEYBOARD_KEY[2] = 'RButton'
ENUM_KEYBOARD_KEY[3] = 'Cancel'
ENUM_KEYBOARD_KEY[4] = 'MButton'
ENUM_KEYBOARD_KEY[5] = 'XButton1'
ENUM_KEYBOARD_KEY[6] = 'XButton2'
ENUM_KEYBOARD_KEY[8] = 'Back'
ENUM_KEYBOARD_KEY[9] = 'Tab'
ENUM_KEYBOARD_KEY[12] = 'Clear'
ENUM_KEYBOARD_KEY[13] = 'Enter'
--ENUM_KEYBOARD_KEY[16] = 'Shift'
--ENUM_KEYBOARD_KEY[17] = 'Control'
--ENUM_KEYBOARD_KEY[18] = 'Menu'
ENUM_KEYBOARD_KEY[19] = 'Pause'
ENUM_KEYBOARD_KEY[20] = 'Capital'
ENUM_KEYBOARD_KEY[21] = 'Kana'
ENUM_KEYBOARD_KEY[23] = 'Junja'
ENUM_KEYBOARD_KEY[24] = 'Final'
ENUM_KEYBOARD_KEY[25] = 'Hanja'
ENUM_KEYBOARD_KEY[27] = 'Escape'
ENUM_KEYBOARD_KEY[28] = 'Convert'
ENUM_KEYBOARD_KEY[29] = 'NonConvert'
ENUM_KEYBOARD_KEY[30] = 'Accept'
ENUM_KEYBOARD_KEY[31] = 'ModeChange'
ENUM_KEYBOARD_KEY[32] = 'Space'
ENUM_KEYBOARD_KEY[33] = 'Prior'
ENUM_KEYBOARD_KEY[34] = 'Next'
ENUM_KEYBOARD_KEY[35] = 'End'
ENUM_KEYBOARD_KEY[36] = 'Home'
ENUM_KEYBOARD_KEY[37] = 'Left'
ENUM_KEYBOARD_KEY[38] = 'Up'
ENUM_KEYBOARD_KEY[39] = 'Right'
ENUM_KEYBOARD_KEY[40] = 'Down'
ENUM_KEYBOARD_KEY[41] = 'Select'
ENUM_KEYBOARD_KEY[42] = 'Print'
ENUM_KEYBOARD_KEY[43] = 'Execute'
ENUM_KEYBOARD_KEY[44] = 'SnapShot'
ENUM_KEYBOARD_KEY[45] = 'Insert'
ENUM_KEYBOARD_KEY[46] = 'Delete'
ENUM_KEYBOARD_KEY[47] = 'Help'
ENUM_KEYBOARD_KEY[48] = 'Alpha0'
ENUM_KEYBOARD_KEY[49] = 'Alpha1'
ENUM_KEYBOARD_KEY[50] = 'Alpha2'
ENUM_KEYBOARD_KEY[51] = 'Alpha3'
ENUM_KEYBOARD_KEY[52] = 'Alpha4'
ENUM_KEYBOARD_KEY[53] = 'Alpha5'
ENUM_KEYBOARD_KEY[54] = 'Alpha6'
ENUM_KEYBOARD_KEY[55] = 'Alpha7'
ENUM_KEYBOARD_KEY[56] = 'Alpha8'
ENUM_KEYBOARD_KEY[57] = 'Alpha9'
ENUM_KEYBOARD_KEY[65] = 'A'
ENUM_KEYBOARD_KEY[66] = 'B'
ENUM_KEYBOARD_KEY[67] = 'C'
ENUM_KEYBOARD_KEY[68] = 'D'
ENUM_KEYBOARD_KEY[69] = 'E'
ENUM_KEYBOARD_KEY[70] = 'F'
ENUM_KEYBOARD_KEY[71] = 'G'
ENUM_KEYBOARD_KEY[72] = 'H'
ENUM_KEYBOARD_KEY[73] = 'J'
ENUM_KEYBOARD_KEY[75] = 'K'
ENUM_KEYBOARD_KEY[76] = 'L'
ENUM_KEYBOARD_KEY[77] = 'M'
ENUM_KEYBOARD_KEY[78] = 'N'
ENUM_KEYBOARD_KEY[79] = 'O'
ENUM_KEYBOARD_KEY[80] = 'P'
ENUM_KEYBOARD_KEY[81] = 'Q'
ENUM_KEYBOARD_KEY[82] = 'R'
ENUM_KEYBOARD_KEY[83] = 'S'
ENUM_KEYBOARD_KEY[84] = 'T'
ENUM_KEYBOARD_KEY[85] = 'U'
ENUM_KEYBOARD_KEY[86] = 'V'
ENUM_KEYBOARD_KEY[87] = 'W'
ENUM_KEYBOARD_KEY[88] = 'X'
ENUM_KEYBOARD_KEY[89] = 'Y'
ENUM_KEYBOARD_KEY[90] = 'Z'
ENUM_KEYBOARD_KEY[91] = 'LWin'
ENUM_KEYBOARD_KEY[92] = 'RWin'
ENUM_KEYBOARD_KEY[93] = 'Apps'
ENUM_KEYBOARD_KEY[95] = 'Sleep'
ENUM_KEYBOARD_KEY[96] = 'NumPad0'
ENUM_KEYBOARD_KEY[97] = 'NumPad1'
ENUM_KEYBOARD_KEY[98] = 'NumPad2'
ENUM_KEYBOARD_KEY[99] = 'NumPad3'
ENUM_KEYBOARD_KEY[100] = 'NumPad4'
ENUM_KEYBOARD_KEY[101] = 'NumPad5'
ENUM_KEYBOARD_KEY[102] = 'NumPad6'
ENUM_KEYBOARD_KEY[103] = 'NumPad7'
ENUM_KEYBOARD_KEY[104] = 'NumPad8'
ENUM_KEYBOARD_KEY[105] = 'NumPad9'
ENUM_KEYBOARD_KEY[106] = 'Multiply'
ENUM_KEYBOARD_KEY[107] = 'Add'
ENUM_KEYBOARD_KEY[108] = 'Separator'
ENUM_KEYBOARD_KEY[109] = 'Subtract'
ENUM_KEYBOARD_KEY[110] = 'Decimal'
ENUM_KEYBOARD_KEY[111] = 'Divide'
ENUM_KEYBOARD_KEY[112] = 'F1'
ENUM_KEYBOARD_KEY[113] = 'F2'
ENUM_KEYBOARD_KEY[114] = 'F3'
ENUM_KEYBOARD_KEY[115] = 'F4'
ENUM_KEYBOARD_KEY[116] = 'F5'
ENUM_KEYBOARD_KEY[117] = 'F6'
ENUM_KEYBOARD_KEY[118] = 'F7'
ENUM_KEYBOARD_KEY[119] = 'F8'
ENUM_KEYBOARD_KEY[120] = 'F9'
ENUM_KEYBOARD_KEY[121] = 'F10'
ENUM_KEYBOARD_KEY[122] = 'F11'
ENUM_KEYBOARD_KEY[123] = 'F12'
ENUM_KEYBOARD_KEY[124] = 'F13'
ENUM_KEYBOARD_KEY[125] = 'F14'
ENUM_KEYBOARD_KEY[126] = 'F15'
ENUM_KEYBOARD_KEY[127] = 'F16'
ENUM_KEYBOARD_KEY[128] = 'F17'
ENUM_KEYBOARD_KEY[129] = 'F18'
ENUM_KEYBOARD_KEY[130] = 'F19'
ENUM_KEYBOARD_KEY[131] = 'F20'
ENUM_KEYBOARD_KEY[132] = 'F21'
ENUM_KEYBOARD_KEY[133] = 'F22'
ENUM_KEYBOARD_KEY[134] = 'F23'
ENUM_KEYBOARD_KEY[135] = 'F24'
ENUM_KEYBOARD_KEY[144] = 'NumLock'
ENUM_KEYBOARD_KEY[145] = 'Scroll'
ENUM_KEYBOARD_KEY[146] = 'NumPadEnter'
ENUM_KEYBOARD_KEY[160] = 'LShift'
ENUM_KEYBOARD_KEY[161] = 'RShift'
ENUM_KEYBOARD_KEY[162] = 'LControl'
ENUM_KEYBOARD_KEY[163] = 'RControl'
ENUM_KEYBOARD_KEY[164] = 'LMenu'
ENUM_KEYBOARD_KEY[165] = 'RMenu'
ENUM_KEYBOARD_KEY[186] = 'OEM_1'
ENUM_KEYBOARD_KEY[187] = 'OEM_Plus'
ENUM_KEYBOARD_KEY[188] = 'OEM_Comma'
ENUM_KEYBOARD_KEY[189] = 'OEM_Minus'
ENUM_KEYBOARD_KEY[190] = 'OEM_Period'
ENUM_KEYBOARD_KEY[191] = 'Slash'
ENUM_KEYBOARD_KEY[192] = 'OEM_3'
ENUM_KEYBOARD_KEY[219] = 'OEM_4'
ENUM_KEYBOARD_KEY[220] = 'OEM_5'
ENUM_KEYBOARD_KEY[221] = 'OEM_6'
ENUM_KEYBOARD_KEY[222] = 'OEM_7'
ENUM_KEYBOARD_KEY[223] = 'OEM_8'
ENUM_KEYBOARD_KEY[226] = 'OEM_102'
ENUM_KEYBOARD_KEY[220] = 'BackSlash'
ENUM_KEYBOARD_KEY[254] = 'DefinedEnter'
ENUM_KEYBOARD_KEY[255] = 'DefinedCancel'

local ENUM_KEYBOARD_MODIFIERS = {}
--ENUM_KEYBOARD_MODIFIERS[16] = true -- shift
--ENUM_KEYBOARD_MODIFIERS[17] = true -- control
--ENUM_KEYBOARD_MODIFIERS[18] = true -- alt
ENUM_KEYBOARD_MODIFIERS[160] = true -- left shift
ENUM_KEYBOARD_MODIFIERS[161] = true -- right shift
ENUM_KEYBOARD_MODIFIERS[162] = true -- left control
ENUM_KEYBOARD_MODIFIERS[163] = true -- right control
ENUM_KEYBOARD_MODIFIERS[164] = true -- left alt
ENUM_KEYBOARD_MODIFIERS[165] = true -- right alt

local ATTACKER_TYPES = {}
ATTACKER_TYPES[0] = 'weapon'
ATTACKER_TYPES[1] = 'barrelbombl'
ATTACKER_TYPES[2] = 'makimushi'
ATTACKER_TYPES[3] = 'nitro'
ATTACKER_TYPES[4] = 'onibimine'
ATTACKER_TYPES[5] = 'ballistahate'
ATTACKER_TYPES[6] = 'capturesmokebomb'
ATTACKER_TYPES[7] = 'capturebullet'
ATTACKER_TYPES[8] = 'barrelbombs'
ATTACKER_TYPES[9] = 'kunai'
ATTACKER_TYPES[10] = 'waterbeetle'
ATTACKER_TYPES[11] = 'detonationgrenade'
ATTACKER_TYPES[12] = 'hmballista'
ATTACKER_TYPES[13] = 'hmcannon'
ATTACKER_TYPES[14] = 'hmgatling'
ATTACKER_TYPES[15] = 'hmtrap'
ATTACKER_TYPES[16] = 'hmnpc'
ATTACKER_TYPES[17] = 'hmflamethrower'
ATTACKER_TYPES[18] = 'hmdragonator'
ATTACKER_TYPES[19] = 'otomo'
ATTACKER_TYPES[20] = 'fg005'
ATTACKER_TYPES[21] = 'ecbatexplode'
ATTACKER_TYPES[23] = 'monster'

local ATTACKER_TYPE_TEXT = {}
ATTACKER_TYPE_TEXT['weapon']            = 'Weapon'
ATTACKER_TYPE_TEXT['barrelbombl']       = 'Large Barrel Bomb'
ATTACKER_TYPE_TEXT['makimushi']         = 'makimushi'
ATTACKER_TYPE_TEXT['nitro']             = 'nitro'
ATTACKER_TYPE_TEXT['onibimine']         = 'onibimine'
ATTACKER_TYPE_TEXT['ballistahate']      = 'ballistahate'
ATTACKER_TYPE_TEXT['capturesmokebomb']  = 'Tranq Bomb'
ATTACKER_TYPE_TEXT['capturebullet']     = 'Tranq Ammo'
ATTACKER_TYPE_TEXT['barrelbombs']       = 'Barrel Bomb'
ATTACKER_TYPE_TEXT['kunai']             = 'Kunai'
ATTACKER_TYPE_TEXT['waterbeetle']       = 'waterbeetle'
ATTACKER_TYPE_TEXT['detonationgrenade'] = 'detonationgrenade'
ATTACKER_TYPE_TEXT['hmballista']        = 'Ballista'
ATTACKER_TYPE_TEXT['hmcannon']          = 'Cannon'
ATTACKER_TYPE_TEXT['hmgatling']         = 'Machine Cannon'
ATTACKER_TYPE_TEXT['hmtrap']            = 'Bamboo Bomb'
ATTACKER_TYPE_TEXT['hmnpc']             = 'Defenders'
ATTACKER_TYPE_TEXT['hmflamethrower']    = 'Wyvernfire'
ATTACKER_TYPE_TEXT['hmdragonator']      = 'Dragonator'
ATTACKER_TYPE_TEXT['otomo']             = 'Buddy'
ATTACKER_TYPE_TEXT['fg005']             = 'fg005'
ATTACKER_TYPE_TEXT['ecbatexplode']      = 'ecbatexplode'
ATTACKER_TYPE_TEXT['monster']           = 'Monster'

--#endregion

--#region globals

local DPS_ENABLED = true
local DPS_DEBUG = false
local LAST_UPDATE_TIME = 0
local DRAW_OVERLAY = true
local DRAW_WINDOW_SETTINGS = false
local DRAW_WINDOW_REPORT = false
local DRAW_WINDOW_HOTKEYS = false
local WINDOW_FLAGS = 0x10120
local IS_ONLINE = false
local QUEST_DURATION = 0.0
local IS_IN_QUEST = false
local IS_IN_TRAININGHALL = false

local _CFG = {}
local DATADIR = 'mhrise-coavins-dps/'
local _COLORS = {}
--local _HOTKEYS = {} -- todo

local FONT = nil

local _PRESETS = {}
local PRESET_OPTIONS = {}
local PRESET_OPTIONS_SELECTED = 1

local CURRENTLY_HELD_MODIFIERS = {}
local ASSIGNED_HOTKEY_THIS_FRAME = false
local HOTKEY_TOGGLE_OVERLAY = 109 -- 109 is numpad minus
local HOTKEY_TOGGLE_OVERLAY_MODIFIERS = {} -- modifiers that must be held for this hotkey
local HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false -- if true, will register next key press as the new hotkey
local HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER = {} -- table of modifiers for new hotkey

local SCREEN_W = 0
local SCREEN_H = 0
local DEBUG_Y = 0
local FAKE_OTOMO_RANGE_START = 9990 -- it is important that attacker ids near this are never used by the game

local LARGE_MONSTERS = {}
local TEST_MONSTERS = nil -- like LARGE_MONSTERS, but holds dummy/test data
local DAMAGE_REPORTS = {}

local REPORT_MONSTERS = {} -- a subset of LARGE_MONSTERS or TEST_MONSTERS that will appear in reports
local _FILTERS = {}

local MY_PLAYER_ID = nil
local PLAYER_NAMES = {}
local OTOMO_NAMES = {}
local PLAYER_RANKS = {}

-- initialized later when they become available
local MANAGER = {}
MANAGER.PLAYER   = nil
MANAGER.ENEMY    = nil
MANAGER.QUEST    = nil
MANAGER.MESSAGE  = nil
MANAGER.LOBBY    = nil
MANAGER.AREA     = nil
MANAGER.OTOMO    = nil
MANAGER.KEYBOARD = nil
MANAGER.STAGE    = nil
MANAGER.SCENE    = nil
MANAGER.PROGRESS = nil

local SCENE_MANAGER_TYPE = nil
local SCENE_MANAGER_VIEW = nil

local QUEST_MANAGER_TYPE = nil
local QUEST_MANAGER_METHOD_ONCHANGEDGAMESTATUS = nil
local SNOW_ENEMY_ENEMYCHARACTERBASE = nil
local SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE = nil
local SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE = nil

local STAGE_MANAGER_TYPE = nil
local STAGE_MANAGER_METHOD_ENDTRAININGROOM = nil

--#endregion

--#region Helper functions

local function debug_line(text)
	DEBUG_Y = DEBUG_Y + 20
	draw.text(text, 0, DEBUG_Y, 0xFFFFFFFF)
end

local function makeTableEmpty(table)
	for k,_ in pairs(table) do table[k]=nil end
end

local function log_info(text)
	log.info('mhrise-coavins-dps: ' .. text)
end

local function log_error(text)
	log.error('mhrise-coavins-dps: ' .. text)
end

local function readScreenDimensions()
	local size = SCENE_MANAGER_VIEW:call("get_Size")
	if not size then
		log_error('could not get screen size')
	end

	SCREEN_W = size:get_field("w")
	SCREEN_H = size:get_field("h")
end

local function getScreenXFromX(x)
	return SCREEN_W * x
end

local function getScreenYFromY(y)
	return SCREEN_H * y
end

local function hasNativeResources()
	if not MANAGER.SCENE then
		MANAGER.SCENE = sdk.get_native_singleton("via.SceneManager")
		if not MANAGER.SCENE then
			return false
		end
	end

	return true
end

local function hasManagedResources()
	if not MANAGER.PLAYER then
		MANAGER.PLAYER = sdk.get_managed_singleton("snow.player.PlayerManager")
		if not MANAGER.PLAYER then
			return false
		end
	end

	if not MANAGER.QUEST then
		MANAGER.QUEST = sdk.get_managed_singleton("snow.QuestManager")
		if not MANAGER.QUEST then
			return false
		end
	end

	if not MANAGER.ENEMY then
		MANAGER.ENEMY = sdk.get_managed_singleton("snow.enemy.EnemyManager")
		if not MANAGER.ENEMY then
			return false
		end
	end

	if not MANAGER.MESSAGE then
		MANAGER.MESSAGE = sdk.get_managed_singleton("snow.gui.MessageManager")
		if not MANAGER.MESSAGE then
			return false
		end
	end

	if not MANAGER.LOBBY then
		MANAGER.LOBBY = sdk.get_managed_singleton("snow.LobbyManager")
		if not MANAGER.LOBBY then
			return false
		end
	end

	if not MANAGER.OTOMO then
		MANAGER.OTOMO = sdk.get_managed_singleton("snow.otomo.OtomoManager")
		if not MANAGER.OTOMO then
			return false
		end
	end

	if not MANAGER.KEYBOARD then
		local softKeyboard = sdk.get_managed_singleton("snow.GameKeyboard")
		if softKeyboard then
			MANAGER.KEYBOARD = softKeyboard:get_field("hardKeyboard")
			if not MANAGER.KEYBOARD then
				return false
			end
		else
			return false
		end
	end

	if not MANAGER.PROGRESS then
		MANAGER.PROGRESS = sdk.get_managed_singleton("snow.progress.ProgressManager")
		if not MANAGER.PROGRESS then
			return false
		end
	end

	return true
end

local function CFG(name)
	return _CFG[name].VALUE
end

local function SetCFG(name, value)
	_CFG[name].VALUE = value
end

local function TXT(name)
	return _CFG[name].TEXT
end

local function MIN(name)
	return _CFG[name].MIN
end

local function MAX(name)
	return _CFG[name].MAX
end

local function COLOR(name)
	return _COLORS[name]
end

--[[
local function SetColor(name, value)
	_COLORS[name] = value
end
]]

-- returns file json
local function readDataFile(filename)
	filename = DATADIR .. filename
	return json.load_file(filename)
end

-- merges second cfg into first
-- returns true if anything was done
local function mergeCfgIntoLeft(cfg1, cfg2)
	if cfg2 then
		for name,setting in pairs(cfg2) do
			if name == 'TABLE_COLS' or name == 'TABLE_COLS_WIDTH' then
				local t1 = cfg1[name]
				local t2 = setting
				for i, v in ipairs(t2) do
					t1[i] = v
				end
			else
				cfg1[name].VALUE = setting.VALUE -- load only the values
			end
		end
	end
end

local function mergeColorsIntoLeft(colors1, colors2)
	if colors2 then
		for name,setting in pairs(colors2) do
			colors1[name] = setting
		end
	end
end

local function mergeFiltersIntoLeft(filters1, filters2)
	if filters2 then
		for name,setting in pairs(filters2) do
			if name == 'ATTACKER_TYPES' then
				for k,v in pairs(filters2[name]) do
					filters1[name][k] = v
				end
			else
				filters1[name] = setting
			end
		end
	end
end

-- returns true on success
local function loadDefaultConfig()
	local file = readDataFile('default.json')
	if not file then
		log_error('failed to load default.json')
		return false
	end

	_CFG = file['CFG']
	_COLORS = file['COLORS']
	_FILTERS = file['FILTERS']

	return true
end

local function loadSavedConfigIfExist()
	local file = readDataFile('saves/save.json') -- file might not exist
	if file then
		-- load save file on top of current config
		mergeCfgIntoLeft(_CFG, file.CFG)
		mergeColorsIntoLeft(_COLORS, file.COLORS)
		mergeFiltersIntoLeft(_FILTERS, file.FILTERS)

		log_info('loaded configuration from saves/save.json')
	end
end

local function saveCurrentConfig()
	local file = {}
	file['CFG'] = _CFG
	file['COLORS'] = _COLORS
	file['FILTERS'] = _FILTERS

	-- save current config to disk, replacing any existing file
	local success = json.dump_file(DATADIR .. 'saves/save.json', file)
	if success then
		log_info('saved configuration to saves/save.json')
	else
		log_error('failed to save configuration to saves/save.json')
	end
end

-- load presets
local function loadPresets()
	local paths = fs.glob([[mhrise-coavins-dps\\presets\\.*json]])

	for _,path in ipairs(paths) do
		local name = string.match(path, '\\([%a%s]+).json')
		log_info(name)
		local file = readDataFile('presets/' .. name .. '.json')
		if file then
			_PRESETS[name] = file
			log_info('loaded preset ' .. name)
		end
	end

	-- build preset options list
	for name,_ in pairs(_PRESETS) do
		table.insert(PRESET_OPTIONS, name)
	end
	table.sort(PRESET_OPTIONS)
	table.insert(PRESET_OPTIONS, 1, 'Select a preset')
end

local function applySelectedPreset()
	local name = PRESET_OPTIONS[PRESET_OPTIONS_SELECTED]
	local preset = _PRESETS[name]
	if preset then
		-- load save file on top of current config
		mergeCfgIntoLeft(_CFG, preset.CFG)
		mergeColorsIntoLeft(_COLORS, preset.COLORS)

		log_info(string.format('loaded preset %s', name))
	end
end

local function SetQuestDuration(value)
	QUEST_DURATION = value
end

local function cleanUpData()
	LAST_UPDATE_TIME = 0
	SetQuestDuration(0.0)
	makeTableEmpty(LARGE_MONSTERS)
	makeTableEmpty(DAMAGE_REPORTS)
	makeTableEmpty(REPORT_MONSTERS)
	log_info('cleared captured data')
end

local function AddMonsterToReport(enemyToAdd, bossInfo)
	REPORT_MONSTERS[enemyToAdd] = bossInfo
end

local function RemoveMonsterFromReport(enemyToRemove)
	for enemy,_ in pairs(REPORT_MONSTERS) do
		if enemy == enemyToRemove then
			REPORT_MONSTERS[enemy] = nil
			return
		end
	end
end

local function AddAttackerTypeToReport(typeToAdd)
	_FILTERS.ATTACKER_TYPES[typeToAdd] = true
	log_info(string.format('damage type %s added to report', typeToAdd))
end

local function RemoveAttackerTypeFromReport(typeToRemove)
	_FILTERS.ATTACKER_TYPES[typeToRemove] = false
	log_info(string.format('damage type %s removed from report', typeToRemove))
end

local function SetReportOtomo(value)
	_FILTERS.INCLUDE_OTOMO = value
end

local function SetReportOther(value)
	_FILTERS.INCLUDE_OTHER = value
end

local function attackerIdIsPlayer(attackerId)
	if attackerId >= 0 and attackerId <= 3 then
		return true
	else
		return false
	end
end

local function attackerIdIsOtomo(attackerId)
	if attackerId >= FAKE_OTOMO_RANGE_START
	and attackerId <= FAKE_OTOMO_RANGE_START + 4
	then
		return true
	else
		return false
	end
end

local function getFakeAttackerIdForOtomoId(otomoId)
	return FAKE_OTOMO_RANGE_START + otomoId
end

local function getOtomoIdFromFakeAttackerId(fakeAttackerId)
	return fakeAttackerId - FAKE_OTOMO_RANGE_START
end

local function updatePlayers()
	-- get offline player name
	local myHunter = MANAGER.LOBBY:get_field("_myHunterInfo")
	if myHunter then
		PLAYER_NAMES[MY_PLAYER_ID + 1] = myHunter:get_field("_name")
	end

	-- get offline player rank
	PLAYER_RANKS[MY_PLAYER_ID + 1] = MANAGER.PROGRESS:call("get_HunterRank")

	-- get online players
	local hunterInfo = MANAGER.LOBBY:get_field("_questHunterInfo")
	if hunterInfo then
		local hunterCount = hunterInfo:call("get_Count")
		if hunterCount then
			for i = 0, hunterCount-1 do
				local hunter = hunterInfo:call("get_Item", i)
				if hunter then
					local playerId = hunter:get_field("_memberIndex")
					local name = hunter:get_field("_name")
					local rank = hunter:get_field("_hunterRank")

					if playerId then
						if name then PLAYER_NAMES[playerId + 1] = name end
						if rank then PLAYER_RANKS[playerId + 1] = rank end
					end
				end
			end
		end
	end

	-- get offline otomo names
	local firstOtomo = MANAGER.OTOMO:call("getMasterOtomoInfo", 0)
	if firstOtomo then
		local name = firstOtomo:get_field("Name")
		--local level = firstOtomo:get_field("Level")
		OTOMO_NAMES[1] = name
	end

	local secondOtomo = MANAGER.OTOMO:call("getMasterOtomoInfo", 1)
	if secondOtomo then
		local name = secondOtomo:get_field("Name")
		--local level = firstOtomo:get_field("Level")
		-- the secondary otomo is actually the fifth one!
		OTOMO_NAMES[5] = name
	end

	-- get online otomo names
	local otomoInfo = MANAGER.LOBBY:get_field("_questOtomoInfo")
	if otomoInfo then
		local otomoCount = otomoInfo:call("get_Count")
		if otomoCount then
			for i=0, otomoCount-1 do
				local otomo = otomoInfo:call("get_Item", i)
				if otomo then
					local otomoId = i
					local name = otomo:get_field("_Name")

					if otomoId and name then
						OTOMO_NAMES[otomoId + 1] = name
					end
				end
			end
		end
	end
end

--#endregion Helper functions

--#region Sanity checking

local function sanityCheck()
	if not CFG('UPDATE_RATE') or tonumber(CFG('UPDATE_RATE')) == nil then
		SetCFG('UPDATE_RATE', 0.5)
	end
	if CFG('UPDATE_RATE') < 0.01 then
		SetCFG('UPDATE_RATE', 0.01)
	end
	if CFG('UPDATE_RATE') > 3 then
		SetCFG('UPDATE_RATE', 3)
	end
end

--#endregion

--#region Damage sources

-- damage counter
local function initializeDamageCounter()
	local c = {}
	c['physical']  = 0.0
	c['elemental'] = 0.0
	c['condition'] = 0.0
	return c
end

local function initializeDamageCounterWithDummyData()
	local c = initializeDamageCounter()
	c['physical']  = math.random(1,1000)
	c['elemental'] = math.random(1,600)
	c['condition'] = math.random(1,100)
	return c
end

local function getTotalDamageForDamageCounter(c)
	return c.physical + c.elemental + c.condition
end

local function mergeDamageCounters(a, b)
	if not a then a = initializeDamageCounter() end
	if not b then b = initializeDamageCounter() end
	local c = initializeDamageCounter()
	c.physical  = a.physical  + b.physical
	c.elemental = a.elemental + b.elemental
	c.condition = a.condition + b.condition
	return c
end

-- damage source
local function initializeDamageSource(attackerId)
	local s = {}
	s.id = attackerId

	s.counters = {}
	for _,type in pairs(ATTACKER_TYPES) do
		s.counters[type] = initializeDamageCounter()
	end

	s.numHit = 0 -- how many hits
	s.maxHit = 0 -- biggest hit

	return s
end

local function initializeDamageSourceWithDummyPlayerData(attackerId)
	local s = initializeDamageSource(attackerId)

	s.counters['weapon'] = initializeDamageCounterWithDummyData()

	s.numHit = math.random(1,380)
	s.maxHit = math.random(1,1000)

	return s
end

local function initializeDamageSourceWithDummyOtomoData(attackerId)
	local s = initializeDamageSource(attackerId)

	s.counters['otomo'] = initializeDamageCounter()
	s.counters['otomo'].physical = math.random(0,400)

	s.numHit = math.random(1,500)
	s.maxHit = math.random(1,100)

	return s
end

local function initializeDamageSourceWithDummyMonsterData(attackerId)
	local s = initializeDamageSource(attackerId)

	s.counters['monster'] = initializeDamageCounter()
	s.counters['monster'].physical = math.random(0,150)

	s.numHit = math.random(1,10)
	s.maxHit = math.random(1,50)

	return s
end

-- boss
local function initializeBossMonster(bossEnemy)
	local boss = {}

	boss.enemy = bossEnemy

	boss.species = bossEnemy:call("get_EnemySpecies")
	boss.genus   = bossEnemy:call("get_BossEnemyGenus")

	-- get name
	local enemyType = bossEnemy:get_field("<EnemyType>k__BackingField")
	boss.name = MANAGER.MESSAGE:call("getEnemyNameMessage", enemyType)

	boss.damageSources = {}

	boss.hp = {}
	boss.hp.current = 0.0
	boss.hp.max     = 0.0
	boss.hp.missing = 0.0
	boss.hp.percent = 0.0

	boss.timeline = {} -- don't ask...
	boss.lastTime = 0
	boss.isInCombat = false

	-- store it in the table
	LARGE_MONSTERS[bossEnemy] = boss

	-- all monsters are in the report by default
	AddMonsterToReport(bossEnemy, boss)

	log_info('initialized new ' .. boss.name)
end

local function initializeBossMonsterWithDummyData(bossKey, fakeName)
	local boss = {}

	boss.enemy = bossKey

	boss.genus = 999
	boss.species = 0

	boss.name = fakeName

	local s = {}
	-- players
	s[0] = initializeDamageSourceWithDummyPlayerData(0)
	s[1] = initializeDamageSourceWithDummyPlayerData(1)
	s[2] = initializeDamageSourceWithDummyPlayerData(2)
	s[3] = initializeDamageSourceWithDummyPlayerData(3)

	-- otomo
	local dummyId = getFakeAttackerIdForOtomoId(0)
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = getFakeAttackerIdForOtomoId(1)
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = getFakeAttackerIdForOtomoId(2)
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = getFakeAttackerIdForOtomoId(3)
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId)

	-- monster
	s[1001] = initializeDamageSourceWithDummyMonsterData(1001)

	boss.damageSources = s

	boss.hp = {}
	boss.hp.current = 0.0
	boss.hp.max     = 0.0
	boss.hp.missing = 0.0
	boss.hp.percent = 0.0

	boss.timeline = {}
	boss.lastTime = 0
	boss.isInCombat = false

	TEST_MONSTERS[bossKey] = boss
	AddMonsterToReport(bossKey, boss)
end

local function addDamageToBoss(boss, attackerId, attackerTypeId, amtPhysical, amtElemental, amtCondition)
	local amt = initializeDamageCounter()
	amt.physical  = amtPhysical  or 0
	amt.elemental = amtElemental or 0
	amt.condition = amtCondition or 0

	local sources = boss.damageSources
	local attackerType = ATTACKER_TYPES[attackerTypeId]

	local isOtomo   = (attackerTypeId == 19)

	--log_info(string.format('damage instance from attacker %d of type %s', attackerId, attackerType))
	if isOtomo then
		-- separate otomo from their master
		attackerId = getFakeAttackerIdForOtomoId(attackerId)
	end

	-- get the damage source for this attacker
	if not sources[attackerId] then
		sources[attackerId] = initializeDamageSource(attackerId)
	end
	local s = sources[attackerId]

	-- get the damage counter for this type
	if not s.counters[attackerType] then
		s.counters[attackerType] = initializeDamageCounter()
	end
	local c = s.counters[attackerType]

	-- add damage facts to counter
	s.counters[attackerType] = mergeDamageCounters(c, amt)

	-- hit count
	s.numHit = s.numHit + 1

	-- biggest hit
	local totalDamage = getTotalDamageForDamageCounter(amt)
	if totalDamage > s.maxHit then
		s.maxHit = totalDamage
	end
end

local function initializeTestData()
	TEST_MONSTERS = {}
	makeTableEmpty(REPORT_MONSTERS)

	initializeBossMonsterWithDummyData(111, 'Rathian')
	initializeBossMonsterWithDummyData(222, 'Tigrex')
	initializeBossMonsterWithDummyData(333, 'Qurupeco')
end

local function isInTestMode()
	return (TEST_MONSTERS ~= nil)
end

local function clearTestData()
	TEST_MONSTERS = nil
	makeTableEmpty(REPORT_MONSTERS)
	for enemy, boss in pairs(LARGE_MONSTERS) do
		AddMonsterToReport(enemy, boss)
	end
	log_info('cleared test data')
end

--#endregion

--#region Reports

local function initializeReport()
	local report = {}

	report.items = {}

	report.topDamage = 0.0
	report.totalDamage = 0.0

	report.timeline = {} -- events for timestamps
	report.timestamps = {} -- ordered timestamps
	report.time = 0.0

	return report
end

local function getReportItem(report, id)
	for _,item in ipairs(report.items) do
		if item.id == id then
			return item
		end
	end
	return nil
end

local function initializeReportItem(id)
	if not id then
		log_error('initializing report item with no id')
	end

	local item = {}

	item.id = id
	item.playerNumber = nil
	item.otomoNumber = nil
	item.name = nil

	-- initialize player number and name if we can
	if item.id >= 0 and item.id <= 3 then
		item.playerNumber = item.id + 1
		item.name = PLAYER_NAMES[item.playerNumber]
		item.rank = PLAYER_RANKS[item.playerNumber]
	elseif attackerIdIsOtomo(item.id) then
		item.otomoNumber = getOtomoIdFromFakeAttackerId(item.id) + 1
		item.name = OTOMO_NAMES[item.otomoNumber]
	end

	item.counters = {}

	item.total = 0.0

	item.totalPhysical = 0.0
	item.totalElemental = 0.0
	item.totalCondition = 0.0
	item.totalOtomo = 0.0

	item.seconds = {}
	item.seconds.quest    = 0.0
	item.seconds.monster  = 0.0
	item.seconds.personal = 0.0

	item.dps = {}
	item.dps.quest    = 0.0
	item.dps.report   = 0.0
	item.dps.personal = 0.0

	item.percentOfTotal = 0.0
	item.percentOfBest = 0.0

	item.numHit = 0
	item.maxHit = 0

	return item
end

local function sumDamageCountersList(counters, attackerTypeFilter)
	local sum = {}
	sum.total = 0.0
	sum.physical = 0.0
	sum.elemental = 0.0
	sum.condition = 0.0
	sum.otomo = 0.0

	-- get totals from counters
	for type,counter in pairs(counters) do
		if not attackerTypeFilter or attackerTypeFilter[type] then
			if type == 'otomo' then
				-- sum together otomo's different types of damage and store it as its own type of damage instead
				local counterTotal = getTotalDamageForDamageCounter(counter)
				sum.otomo = sum.otomo + counterTotal

				sum.total = sum.total + counterTotal
			else
				sum.physical  = sum.physical  + counter.physical
				sum.elemental = sum.elemental + counter.elemental
				sum.condition = sum.condition + counter.condition

				sum.total = sum.total + getTotalDamageForDamageCounter(counter)
			end
		end
	end

	return sum
end

local function sumDamageSourcesList(sources)
	local sum = {}
	sum.total = 0.0
	sum.physical = 0.0
	sum.elemental = 0.0
	sum.condition = 0.0
	sum.otomo = 0.0

	for _,source in pairs(sources) do
		local this = sumDamageCountersList(source.counters)
		sum.total = sum.total + this.total
		sum.physical  = sum.physical  + this.physical
		sum.elemental = sum.elemental + this.elemental
		sum.condition = sum.condition + this.condition
		sum.otomo     = sum.otomo     + this.otomo
	end

	return sum
end

local function mergeReportItemCounters(a, b)
	local counters = {}
	for _,type in pairs(ATTACKER_TYPES) do
		counters[type] = mergeDamageCounters(a[type], b[type])
	end
	return counters
end

local function mergeDamageSourceIntoReportItem(item, source)
	-- don't allow merging source and item with different IDs
	if item.id ~= source.id then
		-- make an exception for otomo and player to account for the trick we pulled in mergeDamageSourcesIntoReport()
		if not attackerIdIsOtomo(source.id) then
			log_error('tried to merge a damage source into a report item with a different id')
			return
		end
	end

	item.counters = mergeReportItemCounters(item.counters, source.counters)

	item.numHit = item.numHit + source.numHit
	item.maxHit = math.max(item.maxHit, source.maxHit)
end

local function sortReportItems_DESC(a, b)
	return a.total > b.total
end

local function sortReportItems_ASC(a, b)
	return a.total < b.total
end

local function sortReportItems_Player(a, b)
	if     a.playerNumber and not b.playerNumber then return true
	elseif b.playerNumber and not a.playerNumber then return false
	elseif a.playerNumber and     b.playerNumber then return a.playerNumber < b.playerNumber
	elseif a.otomoNumber and not b.otomoNumber then return true
	elseif b.otomoNumber and not a.otomoNumber then return false
	elseif a.otomoNumber and     b.otomoNumber then return a.otomoNumber < b.otomoNumber
	else return a.id < b.id
	end
end

local function mergeBossTimelineIntoReport(report, boss)
	for t,e in pairs(boss.timeline) do
		local d
		if e then d =  1
		else      d = -1
		end

		if report.timeline[t] then
			report.timeline[t] = report.timeline[t] + d
		else
			report.timeline[t] = d
			table.insert(report.timestamps, t)
		end
	end

	table.sort(report.timestamps)
end

local function calculateReportTime(report)
	report.time = 0.0
	local tally = 0
	local a = 0.0
	for _,timestamp in ipairs(report.timestamps) do
		local e = report.timeline[timestamp]
		local old = tally
		local new = tally + e
		if old <= 0 and new > 0 then
			a = timestamp
		elseif old > 0 and new <= 0 then
			report.time = report.time + (timestamp - a)
			a = 0.0
		end
		tally = new
	end

	if tally > 0 then
		report.time = report.time + (QUEST_DURATION - a)
	end
end

-- main function responsible for loading a boss into a report
local function mergeBossIntoReport(report, boss)
	local totalDamage = 0.0
	local bestDamage = 0.0

	-- merge damage sources
	for _,source in pairs(boss.damageSources) do
		local effSourceId = source.id

		-- merge otomo with master
		if CFG('COMBINE_OTOMO_WITH_HUNTER') and attackerIdIsOtomo(effSourceId) then
			local otomoId = getOtomoIdFromFakeAttackerId(effSourceId)

			-- handle primary otomo
			if otomoId >= 0 and otomoId <= 3 then
				-- pretend this damage source belongs to this player
				effSourceId = otomoId
			end
			-- handle secondary otomo
			if otomoId == 4 then
				-- pretend to be player 1
				effSourceId = 0
			end
		end

		-- if we aren't excluding this type of source
		if attackerIdIsPlayer(effSourceId)
		or (attackerIdIsOtomo(effSourceId) and _FILTERS.INCLUDE_OTOMO)
		or (not attackerIdIsOtomo(effSourceId) and _FILTERS.INCLUDE_OTHER)
		then
			-- get report item, creating it if necessary
			local item = getReportItem(report, effSourceId)
			if not item then
				item = initializeReportItem(effSourceId)
				table.insert(report.items, item)
			end

			mergeDamageSourceIntoReportItem(item, source)
		end
	end

	-- merge boss into report timeline
	mergeBossTimelineIntoReport(report, boss)
	calculateReportTime(report)

	-- now loop all report items and update the totals after adding this boss
	for _,item in ipairs(report.items) do
		-- calculate the item's own total damage
		local sum = sumDamageCountersList(item.counters, _FILTERS.ATTACKER_TYPES)
		item.total = sum.total
		item.totalPhysical  = sum.physical
		item.totalElemental = sum.elemental
		item.totalCondition = sum.condition
		item.totalOtomo     = sum.otomo

		-- calculate dps
		if report.time > 0 then
			item.dps.report = item.total / report.time
		end

		-- remember which combatant has the most damage
		if item.total > bestDamage then
			bestDamage = item.total
		end

		-- accumulate total overall damage
		totalDamage = totalDamage + item.total
	end

	report.totalDamage = totalDamage
	report.topDamage = bestDamage

	-- loop again to calculate percents using the totals we got before
	for _,item in ipairs(report.items) do
		if report.totalDamage ~= 0 then
			item.percentOfTotal = tonumber(string.format("%.3f", item.total / report.totalDamage))
		end
		if report.topDamage ~= 0 then
			item.percentOfBest  = tonumber(string.format("%.3f", item.total / report.topDamage))
		end
	end

	-- sort report items
	if CFG('TABLE_SORT_IN_ORDER') then
		table.sort(report.items, sortReportItems_Player)
	elseif CFG('TABLE_SORT_ASC') then
		table.sort(report.items, sortReportItems_ASC)
	else
		table.sort(report.items, sortReportItems_DESC)
	end
end

local function generateReport(filterBosses)
	makeTableEmpty(DAMAGE_REPORTS)

	local report = initializeReport()

	for _,boss in pairs(filterBosses) do
		mergeBossIntoReport(report, boss)
	end

	table.insert(DAMAGE_REPORTS, report)
end

--#endregion

--#region Drawing

local function drawRichDamageBar(item, x, y, maxWidth, h, colorPhysical, colorElemental)
	local w
	local colorAilment = COLOR('BAR_DMG_AILMENT')
	local colorOtomo = COLOR('BAR_DMG_OTOMO')
	local colorOther = COLOR('BAR_DMG_OTHER')

	if not CFG('DRAW_BAR_USE_UNIQUE_COLORS') then
		colorElemental = colorPhysical
		colorAilment = colorPhysical
		colorOtomo = colorPhysical
		colorOther = colorPhysical
	end

	-- draw physical damage
	--debug_line(string.format('damagePhysical: %d', source.damagePhysical))
	w = (item.totalPhysical / item.total) * maxWidth
	d2d.fill_rect(x, y, w, h, colorPhysical)
	x = x + w
	-- draw elemental damage
	--debug_line(string.format('damageElemental: %d', source.damageElemental))
	w = (item.totalElemental / item.total) * maxWidth
	d2d.fill_rect(x, y, w, h, colorElemental)
	x = x + w
	-- draw ailment damage
	--debug_line(string.format('damageAilment: %f', source.damageAilment))
	w = (item.totalCondition / item.total) * maxWidth
	d2d.fill_rect(x, y, w, h, colorAilment)
	x = x + w
	-- draw otomo damage
	--debug_line(string.format('damageOtomo: %d', source.damageOtomo))
	w = (item.totalOtomo / item.total) * maxWidth
	d2d.fill_rect(x, y, w, h, colorOtomo)
	x = x + w
	-- draw whatever's left, just in case
	local remainder = item.total - item.totalPhysical - item.totalElemental - item.totalCondition - item.totalOtomo
	--debug_line(string.format('remainder: %d', remainder))
	w = (remainder / item.total) * maxWidth
	d2d.fill_rect(x, y, w, h, colorOther)
	--debug_line(string.format('total: %d', source.damageTotal))
end

local function drawReportHeaderColumn(col, x, y)
	local text = TABLE_COLUMNS[col]

	d2d.text(FONT, text, x, y, COLOR('GRAY'))
end

local function drawReportItemColumn(item, col, x, y)
	local text = ''

	if     col == 2 then -- hr
		if item.rank then
			text = string.format('%s', item.rank)
		end
	elseif col == 3 then -- name
		if item.playerNumber then
			if CFG('DRAW_BAR_TEXT_YOU') and item.id == MY_PLAYER_ID then
				text = 'YOU'
			elseif CFG('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES') and item.name then
				text = string.format('%s', item.name)
			else
				text = string.format('Player %.0f', item.id + 1)
			end
		elseif item.otomoNumber then
			if CFG('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES') and item.name then
				if IS_ONLINE then
					text = string.format('%s (%.0f)', item.name, item.otomoNumber)
				else
					text = string.format('%s', item.name)
				end
			else
				text = string.format('Buddy %.0f', item.otomoNumber)
			end
		else
			-- just draw the name
			text = string.format('%s', item.name or '')
		end
	elseif col == 4 then -- dps
		text = string.format('%.1f', item.dps.report)
	elseif col == 5 then -- damage
		text = string.format('%.0f', item.total)
	elseif col == 6 then -- % party
		text = string.format('%.0f%%', item.percentOfTotal * 100.0)
	elseif col == 7 then -- % best
		text = string.format('%.0f%%', item.percentOfBest * 100.0)
	elseif col == 8 then -- hits
		text = string.format('%d', item.numHit)
	elseif col == 9 then -- maxhit
		text = string.format('%.0f', item.maxHit)
	end

	d2d.text(FONT, text, x, y, COLOR('WHITE'))
end

local function drawReportItem(item, x, y, width, height)
	--if item.total == 0 then
		-- skip items with no damage
		--return
	--end

	-- get some values
	local scalingFactor = CFG('TABLE_SCALE')
	local text_offset_x = CFG('TABLE_ROW_TEXT_OFFSET_X') * scalingFactor
	local text_offset_y = CFG('TABLE_ROW_TEXT_OFFSET_Y') * scalingFactor
	local colorBlockWidth = 30 * scalingFactor
	if not CFG('DRAW_BAR_COLORBLOCK') then
		colorBlockWidth = 0
	end

	local damageBarWidthMultiplier = item.percentOfBest
	if CFG('DRAW_BAR_RELATIVE_TO_PARTY') then
		damageBarWidthMultiplier = item.percentOfTotal
	end

	-- get some colors
	local combatantColor = COLOR('GRAY')
	if item.playerNumber then
		combatantColor = COLOR('PLAYER')[item.playerNumber]
	elseif item.otomoNumber then
		combatantColor = COLOR('OTOMO')
	end

	local physicalColor = COLOR('BAR_DMG_PHYSICAL_UNIQUE')[item.playerNumber]
	if not physicalColor or not CFG('DRAW_BAR_USE_PLAYER_COLORS') then
		physicalColor = COLOR('BAR_DMG_PHYSICAL')
	end

	local elementalColor = COLOR('BAR_DMG_ELEMENT_UNIQUE')[item.playerNumber]
	if not elementalColor then
		elementalColor = COLOR('BAR_DMG_ELEMENT')
	end

	-- draw the actual bar
	if CFG('USE_MINIMAL_BARS') then
		-- bar is overlaid on top of the color block
		-- color block
		d2d.fill_rect(x, y, colorBlockWidth, height, elementalColor)

		-- damage bar
		local damageBarWidth = colorBlockWidth * damageBarWidthMultiplier
		d2d.fill_rect(x, y, damageBarWidth, height, combatantColor)

		-- hr
		if item.playerNumber and item.rank and CFG('DRAW_BAR_REVEAL_HR') then
			d2d.text(FONT, string.format('%s',item.rank), x + (3 * CFG('TABLE_SCALE')), y, COLOR('WHITE'))
		end
	else
		-- bar takes up the entire width of the table
		if CFG('DRAW_TABLE_BACKGROUND') then
			-- draw background
			d2d.fill_rect(x, y, width, height, COLOR('BAR_BG'))
		end

		if CFG('DRAW_BAR_COLORBLOCK') then
			-- color block
			d2d.fill_rect(x, y, colorBlockWidth, height, combatantColor)

			-- hr
			if item.playerNumber and item.rank and CFG('DRAW_BAR_REVEAL_HR') then
				d2d.text(FONT, string.format('%s',item.rank), x + (3 * CFG('TABLE_SCALE')), y, COLOR('WHITE'))
			end
		end

		-- damage bar
		local damageBarWidth = (width - colorBlockWidth) * damageBarWidthMultiplier
		--draw.filled_rect(origin_x + colorBlockWidth, y, damageBarWidth, rowHeight, physicalColor)
		drawRichDamageBar(item, x + colorBlockWidth, y, damageBarWidth, height, physicalColor, elementalColor)
	end

	-- draw columns
	local text_x = x + colorBlockWidth + text_offset_x
	local text_y = y + text_offset_y

	-- now loop through defined columns
	for _,col in ipairs(_CFG['TABLE_COLS']) do
		if col > 1 then
			drawReportItemColumn(item, col, text_x, text_y)

			local colWidth = _CFG['TABLE_COLS_WIDTH'][col] * CFG('TABLE_SCALE')

			text_x = text_x + colWidth
		end
	end

	if CFG('DRAW_BAR_OUTLINES') then
		-- draw outline
		d2d.outline_rect(x, y, width, height, 2, COLOR('BAR_OUTLINE'))
	end
end

local function drawReport(index)
	local report = DAMAGE_REPORTS[index]
	if not report then
		return
	end

	local origin_x = getScreenXFromX(CFG('TABLE_X'))
	local origin_y = getScreenYFromY(CFG('TABLE_Y'))
	local tableWidth = CFG('TABLE_WIDTH') * CFG('TABLE_SCALE')
	local rowHeight = CFG('TABLE_ROWH') * CFG('TABLE_SCALE')
	local growDistance = rowHeight + CFG('TABLE_ROW_PADDING')

	if CFG('TABLE_GROWS_UPWARD') then
		origin_y = origin_y - rowHeight
	end

	-- title bar
	if CFG('DRAW_TITLE_BACKGROUND') then
		-- title background
		d2d.fill_rect(origin_x, origin_y, tableWidth, rowHeight, COLOR('TITLE_BG'))
	end

	if CFG('DRAW_TITLE_TEXT') then
		-- generate the title text

		-- get quest duration
		local timeMinutes = MANAGER.QUEST:call("getQuestElapsedTimeMin")
		local timeSeconds = MANAGER.QUEST:call("getQuestElapsedTimeSec")
		timeSeconds = timeSeconds - (timeMinutes * 60)

		-- use a fake duration in test mode
		if isInTestMode() then
			timeMinutes = 5
			timeSeconds = 37
		end

		local timeText = string.format("%d:%02.0f", timeMinutes, timeSeconds)
		local monsterText = ''

		if CFG('DRAW_TITLE_MONSTER') then
			monsterText = ' - '
			-- add monster names
			local monsterCount = 0
			for _,boss in pairs(REPORT_MONSTERS) do
				if monsterCount < 3 then
					if monsterCount > 0 then monsterText = monsterText .. ', ' end
					monsterText = monsterText .. string.format('%s', boss.name)
				end
				monsterCount = monsterCount + 1
			end

			if monsterCount > 3 then
				monsterText = monsterText .. ', etc...'
			elseif monsterCount == 0 then
				monsterText = monsterText .. 'No monsters selected'
			end
		end

		local titleText = timeText .. monsterText
		local offsetX = CFG('TABLE_HEADER_TEXT_OFFSET_X')
		d2d.text(FONT, titleText, origin_x + offsetX, origin_y, COLOR('TITLE_FG'))
	end

	if CFG('DRAW_HEADER') then
		-- find grow without row padding
		local grow = rowHeight
		if CFG('TABLE_GROWS_UPWARD') then
			grow = rowHeight * -1
		end

		-- draw header row
		local x = origin_x + (4 * CFG('TABLE_SCALE'))
		local y = origin_y + grow

		if CFG('DRAW_TITLE_BACKGROUND') then
			-- background
			d2d.fill_rect(origin_x, y, tableWidth, rowHeight, COLOR('TITLE_BG'))
		end

		if CFG('DRAW_BAR_COLORBLOCK') and CFG('DRAW_BAR_REVEAL_HR') then
			d2d.text(FONT, 'HR', x, y, COLOR('GRAY'))
		end

		local colorBlockWidth = 30 * CFG('TABLE_SCALE')
		if not CFG('DRAW_BAR_COLORBLOCK') then
			colorBlockWidth = 0
		end
		x = x + colorBlockWidth

		for _, value in ipairs(_CFG['TABLE_COLS']) do
			if value > 1 then
				drawReportHeaderColumn(value, x, y)

				local colWidth = _CFG['TABLE_COLS_WIDTH'][value] * CFG('TABLE_SCALE')
				x = x + colWidth
			end
		end
	end

	if CFG('TABLE_GROWS_UPWARD') then
		growDistance = (rowHeight + CFG('TABLE_ROW_PADDING')) * -1
	end

	if #report.items == 0 then
		local colorBlockWidth = 20
		if not CFG('DRAW_BAR_COLORBLOCK') then
			colorBlockWidth = 0
		end
		local text_offset_x = CFG('TABLE_ROW_TEXT_OFFSET_X')
		local text_offset_y = CFG('TABLE_ROW_TEXT_OFFSET_Y')
		local x = origin_x + colorBlockWidth + 2 + text_offset_x
		local y = origin_y + growDistance + text_offset_y
		if CFG('DRAW_HEADER') then
			-- skip header row
			y = y + growDistance
		end

		d2d.text(FONT, 'No data', x, y, COLOR('GRAY'))
	end

	-- draw report items
	for i,item in ipairs(report.items) do
		local y = origin_y + growDistance * i
		if CFG('DRAW_HEADER') then
			-- skip header row
			y = y + growDistance
		end

		drawReportItem(item, origin_x, y, tableWidth, rowHeight)
	end
end

-- debug info stuff
local function drawDebugStats()
	--local kpiData         = MANAGER.QUEST:call("get_KpiData")
	--local playerPhysical  = kpiData:call("get_PlayerTotalAttackDamage")
	--local playerElemental = kpiData:call("get_PlayerTotalElementalAttackDamage")
	--local playerAilment   = kpiData:call("get_PlayerTotalStatusAilmentsDamage")
	--local playerDamage    = playerPhysical + playerElemental + playerAilment

	-- get player
	--local myPlayerId = MANAGER.PLAYER:call("getMasterPlayerID")
	--local myPlayer = MANAGER.PLAYER:call("getPlayer", myPlayerId)

	-- get enemy
	local bossCount = MANAGER.ENEMY:call("getBossEnemyCount")

	for i = 0, bossCount-1 do
		local bossEnemy = MANAGER.ENEMY:call("getBossEnemy", i)

		-- get this boss from the table
		local boss = LARGE_MONSTERS[bossEnemy]
		if not boss then
			return
		end

		local isInCombat = bossEnemy:call("get_IsCombatMode")
		local notInCombat = bossEnemy:call("get_IsNonCombatMode")
		local isCapture = bossEnemy:call("isCapture")

		local is_combat_str
		if isInCombat then is_combat_str = " (In Combat)"
		              else is_combat_str = ""
		end

		local non_combat_str
		if notInCombat then non_combat_str = " (Not Combat)"
		               else non_combat_str = ""
		end

		local hpStr = string.format('%.0f / %.0f (%.1f%%) -%.0f'
			, boss.hp.current
			, boss.hp.max
			, boss.hp.percent * 100
			, boss.hp.missing)

		local text = string.format("%s %s %s %s", boss.name, hpStr, is_combat_str, non_combat_str)
		if isCapture then
			text = text .. ' captured'
		end

		debug_line(text)

	end

	--debug_line('')
	--debug_line(string.format('Total damage (KPI): %d', playerDamage))

	debug_line('')
	local report = DAMAGE_REPORTS[1]
	if report then
		for _,item in ipairs(report.items) do
			debug_line(item.name or 'no name')
			for type,counter in pairs(item.counters) do
				if counter.total > 0 then
					debug_line(string.format('%s\t\t%f',type, counter.total))
				end
			end
		end
	end

	-- monster state
	-- isEnableFastTravelCondition

	--[[
		snow.enemy.EnemyCombatSystemData
		snow.enemy.EnemyCombatSystemData.CombatTimeInfo

		EnemyManager.get_CombatMonsterSystem()
			returns:
		snow.enemy.EnemyCombatMonsterManager
			getGroupInfo(EnemyCharacterBase)
			returns:
		snow.enemy.EnemyCombatMonsterManager.GroupInfo
			get_CombatTime()
			getSelfCombatMonsterResult(EnemyCharacterBase)
	]]
end

-- main draw function
local function dpsDraw()
	if DRAW_WINDOW_SETTINGS -- always draw overlay if settings window is open
	or (DRAW_OVERLAY and -- draw in one of the following circumstances if overlay is enabled
	   (isInTestMode() or IS_IN_QUEST or IS_IN_TRAININGHALL)) then
		-- draw the first report
		drawReport(1)

		if DPS_DEBUG then
			DEBUG_Y = 0
			drawDebugStats()
		end
	end
end

--#endregion

--#region Updating

-- main update function
local function dpsUpdate()
	-- update screen dimensions
	readScreenDimensions()

	-- get player id
	MY_PLAYER_ID = MANAGER.PLAYER:call("getMasterPlayerID")

	-- get info for players
	updatePlayers()

	-- ensure bosses are initialized
	local bossCount = MANAGER.ENEMY:call("getBossEnemyCount")
	for i = 0, bossCount-1 do
		local bossEnemy = MANAGER.ENEMY:call("getBossEnemy", i)

		if not LARGE_MONSTERS[bossEnemy] then
			-- initialize data for this boss
			initializeBossMonster(bossEnemy)
		end
	end

	-- generate report for selected bosses
	generateReport(REPORT_MONSTERS)
end

-- update based on wall clock
local function dpsUpdateOccasionally(realSeconds)
	if realSeconds > LAST_UPDATE_TIME + CFG('UPDATE_RATE') then
		dpsUpdate()
		LAST_UPDATE_TIME = realSeconds
	end
end

local function updateHeldHotkeyModifiers()
	for key,_ in pairs(ENUM_KEYBOARD_MODIFIERS) do
		if not CURRENTLY_HELD_MODIFIERS[key] and MANAGER.KEYBOARD:call("getTrg", key) then
			CURRENTLY_HELD_MODIFIERS[key] = true
		elseif CURRENTLY_HELD_MODIFIERS[key] and MANAGER.KEYBOARD:call("getRelease", key) then
			CURRENTLY_HELD_MODIFIERS[key] = false
		end
	end
end

-- TODO: enhance to accept whatever hotkey as param
local function checkHotkeyActivated()
	-- we pressed our hotkey and did not just assign it
	if not ASSIGNED_HOTKEY_THIS_FRAME and MANAGER.KEYBOARD:call("getTrg", HOTKEY_TOGGLE_OVERLAY) then
		-- if correct modifiers are not held, return
		for key,needsHeld in pairs(HOTKEY_TOGGLE_OVERLAY_MODIFIERS) do
			if CURRENTLY_HELD_MODIFIERS[key] ~= needsHeld then
				return
			end
		end
		-- perform hotkey action
		DRAW_OVERLAY = not DRAW_OVERLAY
	end
end

--#endregion

--#region imgui interface

local function showCheckboxForSetting(setting)
	local changed, value = imgui.checkbox(TXT(setting), CFG(setting))
	if changed then
		SetCFG(setting, value)
	end
end

local function showSliderForFloatSetting(setting)
	local changed, value = imgui.slider_float(TXT(setting), CFG(setting), MIN(setting), MAX(setting), '%.2f')
	if changed then
		SetCFG(setting, value)
	end
end

local function showSliderForIntSetting(setting)
	local changed, value = imgui.slider_int(TXT(setting), CFG(setting), MIN(setting), MAX(setting), '%d')
	if changed then
		SetCFG(setting, value)
	end
end

local function showInputsForTableColumns()
	-- draw combo and slider for each column
	imgui.text('Column order')
	for i,currentCol in ipairs(_CFG['TABLE_COLS']) do
		local selected = 1
		-- find option id for selected column
		for idxId,key in ipairs(TABLE_COLUMNS_OPTIONS_ID) do
			if key == currentCol then
				selected = idxId
			end
		end
		-- show combo for choice
		local changedCol, newCol = imgui.combo('Column ' .. i, selected, TABLE_COLUMNS_OPTIONS_READABLE)
		if changedCol then
			_CFG['TABLE_COLS'][i] = TABLE_COLUMNS_OPTIONS_ID[newCol]
		end
	end
	imgui.new_line()
	imgui.text('Column width')
	for i,currentWidth in ipairs(_CFG['TABLE_COLS_WIDTH']) do
		-- skip 'None'
		if i > 1 then
			-- show slider for width
			local changedWidth, newWidth = imgui.slider_int('Width: ' .. TABLE_COLUMNS[i], currentWidth, 0, 250)
			if changedWidth then
				_CFG['TABLE_COLS_WIDTH'][i] = newWidth
			end
		end
	end
	imgui.new_line()
end

local function DrawWindowSettings()
	local changed, wantsIt, value

	wantsIt = imgui.begin_window('coavins dps meter - settings', DRAW_WINDOW_SETTINGS, WINDOW_FLAGS)
	if DRAW_WINDOW_SETTINGS and not wantsIt then
		DRAW_WINDOW_SETTINGS = false

		if isInTestMode() then
			clearTestData()
		end
	end

	-- Enabled
	changed, wantsIt = imgui.checkbox('Enabled', DPS_ENABLED)
	if changed then
		DPS_ENABLED = wantsIt
	end


	if imgui.button('Save settings') then
		saveCurrentConfig()
	end
	imgui.same_line()
	if imgui.button('Load settings') then
		loadSavedConfigIfExist()
		if CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			initializeTestData()
		else
			clearTestData()
		end
	end

	if imgui.button('Reset to default') then
		loadDefaultConfig()
		if CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
			initializeTestData()
		else
			clearTestData()
		end
	end

	-- Show test data
	changed, wantsIt = imgui.checkbox('Show test data while menu is open', CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'))
	if changed then
		SetCFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN', wantsIt)
		if wantsIt then
			initializeTestData()
		else
			clearTestData()
		end
	end

	-- Presets
	imgui.new_line()
	imgui.text('Presets')

	changed, value = imgui.combo('', PRESET_OPTIONS_SELECTED, PRESET_OPTIONS)
	if changed then
		PRESET_OPTIONS_SELECTED = value
	end
	imgui.same_line()
	if imgui.button('Apply') then
		applySelectedPreset()
	end

	-- Settings
	imgui.new_line()
	imgui.text('Settings')

	imgui.same_line()
	if imgui.button('Clear data') then
		if isInTestMode() then
			-- reinitialize test data
			initializeTestData()
		else
			cleanUpData()
		end

		dpsUpdate()
	end

	--showSliderForFloatSetting('UPDATE_RATE')
	showCheckboxForSetting('COMBINE_OTOMO_WITH_HUNTER')
	showCheckboxForSetting('DRAW_BAR_RELATIVE_TO_PARTY')

	imgui.new_line()

	showCheckboxForSetting('DRAW_TITLE_TEXT')
	showCheckboxForSetting('DRAW_TITLE_MONSTER')
	showCheckboxForSetting('DRAW_HEADER')
	showCheckboxForSetting('DRAW_TITLE_BACKGROUND')
	showCheckboxForSetting('DRAW_TABLE_BACKGROUND')
	showCheckboxForSetting('DRAW_BAR_OUTLINES')
	showCheckboxForSetting('DRAW_BAR_COLORBLOCK')
	showCheckboxForSetting('DRAW_BAR_USE_PLAYER_COLORS')
	showCheckboxForSetting('DRAW_BAR_USE_UNIQUE_COLORS')

	imgui.new_line()

	showCheckboxForSetting('DRAW_BAR_TEXT_YOU')
	showCheckboxForSetting('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES')
	showCheckboxForSetting('DRAW_BAR_REVEAL_HR')

	imgui.new_line()

	showInputsForTableColumns()

	imgui.new_line()

	showCheckboxForSetting('USE_MINIMAL_BARS')
	showCheckboxForSetting('TABLE_GROWS_UPWARD')
	showCheckboxForSetting('TABLE_SORT_ASC')
	showCheckboxForSetting('TABLE_SORT_IN_ORDER')

	imgui.new_line()

	showSliderForFloatSetting('TABLE_X')
	showSliderForFloatSetting('TABLE_Y')

	imgui.text('Save and reset scripts to apply scaling to text')
	showSliderForFloatSetting('TABLE_SCALE')
	showSliderForIntSetting('TABLE_HEADER_TEXT_OFFSET_X')
	showSliderForIntSetting('TABLE_WIDTH')

	imgui.new_line()

	showSliderForIntSetting('TABLE_ROWH')
	showSliderForIntSetting('TABLE_ROW_PADDING')
	showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_X')
	showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_Y')

	imgui.new_line()

	imgui.end_window()
end

local function showCheckboxForAttackerType(type)
	local typeIsInReport = _FILTERS.ATTACKER_TYPES[type]
	local changed, wantsIt = imgui.checkbox(ATTACKER_TYPE_TEXT[type], typeIsInReport)
	if changed then
		if wantsIt then
			AddAttackerTypeToReport(type)
		else
			RemoveAttackerTypeFromReport(type)
		end
		generateReport(REPORT_MONSTERS)
	end
end

local function DrawWindowReport()
	local changed, wantsIt

	wantsIt = imgui.begin_window('coavins dps meter - filters', DRAW_WINDOW_REPORT, WINDOW_FLAGS)
	if DRAW_WINDOW_REPORT and not wantsIt then
		DRAW_WINDOW_REPORT = false
	end

	changed, wantsIt = imgui.checkbox('Include buddies', _FILTERS.INCLUDE_OTOMO)
	if changed then
		_FILTERS.INCLUDE_OTOMO = wantsIt
		generateReport(REPORT_MONSTERS)
	end

	changed, wantsIt = imgui.checkbox('Include monsters, etc', _FILTERS.INCLUDE_OTHER)
	if changed then
		_FILTERS.INCLUDE_OTHER = wantsIt
		generateReport(REPORT_MONSTERS)
	end

	imgui.new_line()

	-- draw buttons for each boss monster in the cache
	imgui.text('Monsters')

	local monsterCollection = TEST_MONSTERS or LARGE_MONSTERS
	local foundMonster = false
	for enemy,boss in pairs(monsterCollection) do
		foundMonster = true
		local monsterIsInReport = REPORT_MONSTERS[enemy]
		changed, wantsIt = imgui.checkbox(boss.name, monsterIsInReport)
		if changed then
			if wantsIt then
				AddMonsterToReport(enemy, boss)
			else
				RemoveMonsterFromReport(enemy)
			end
			generateReport(REPORT_MONSTERS)
		end
	end
	if not foundMonster then
		imgui.text('(n/a)')
	end

	imgui.new_line()

	-- draw buttons for attacker types
	imgui.text('Attack type')

	showCheckboxForAttackerType('weapon')
	showCheckboxForAttackerType('otomo')
	showCheckboxForAttackerType('monster')

	imgui.new_line()

	showCheckboxForAttackerType('barrelbombs')
	showCheckboxForAttackerType('barrelbombl')
	showCheckboxForAttackerType('nitro')
	showCheckboxForAttackerType('capturesmokebomb')
	showCheckboxForAttackerType('capturebullet')
	showCheckboxForAttackerType('kunai')

	imgui.new_line()

	showCheckboxForAttackerType('hmballista')
	showCheckboxForAttackerType('hmcannon')
	showCheckboxForAttackerType('hmgatling')
	showCheckboxForAttackerType('hmtrap')
	showCheckboxForAttackerType('hmnpc')
	showCheckboxForAttackerType('hmflamethrower')
	showCheckboxForAttackerType('hmdragonator')

	imgui.new_line()

	showCheckboxForAttackerType('makimushi')
	showCheckboxForAttackerType('onibimine')
	showCheckboxForAttackerType('ballistahate')
	showCheckboxForAttackerType('waterbeetle')
	showCheckboxForAttackerType('detonationgrenade')
	showCheckboxForAttackerType('fg005')
	showCheckboxForAttackerType('ecbatexplode')

	imgui.end_window()
end

local function DrawWindowHotkeys()
	local wantsIt

	wantsIt = imgui.begin_window('coavins dps meter - hotkeys', DRAW_WINDOW_HOTKEYS, WINDOW_FLAGS)
	if DRAW_WINDOW_HOTKEYS and not wantsIt then
		DRAW_WINDOW_HOTKEYS = false
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER = false
	end

	imgui.text('Supports modifiers (Shift,Ctrl,Alt)')

	imgui.new_line()

	imgui.text('Toggle overlay:')
	imgui.same_line()
	local text = 'Set key'
	if HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER then
		text = 'Press key...'
	end
	if imgui.button(text) then
		if HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER then
			-- cancel registration
			HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false
		else
			-- begin registration
			HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = true
			HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER = {}
		end
	end
	imgui.same_line()
	text = string.format('%s (%d)', ENUM_KEYBOARD_KEY[HOTKEY_TOGGLE_OVERLAY], HOTKEY_TOGGLE_OVERLAY)
	imgui.text(text)

	imgui.end_window()
end

--#endregion

--#region sdk hooks

-- know when we left the training room
local function read_endTrainingRoom()
	cleanUpData()
end

-- know when we return from a quest
local function read_onChangedGameStatus(args)
	local status = sdk.to_int64(args[3])
	if status == 1 then
		-- entered the village
		cleanUpData()
	end
end

-- keep track of some things on monsters
local function updateBossEnemy(args)
	local enemy = sdk.to_managed_object(args[2])

	-- get this boss from the table
	local boss = LARGE_MONSTERS[enemy]
	if not boss then
		return
	end

	-- get health
	local physicalParam = enemy:get_field("<PhysicalParam>k__BackingField")
	if physicalParam then
		local vitalParam = physicalParam:call("getVital", 0, 0)
		if vitalParam then
			boss.hp.current = vitalParam:call("get_Current")
			boss.hp.max = vitalParam:call("get_Max")
			boss.hp.missing = boss.hp.max - boss.hp.current
			if boss.hp.max ~= 0 then
				boss.hp.percent = boss.hp.current / boss.hp.max
			else
				boss.hp.percent = 0
			end
		end
	end

	local isCapture = enemy:call("isCapture")
	local isCombatMode = enemy:call("get_IsCombatMode")
	local isInCombat = isCombatMode and boss.hp.current > 0 and not isCapture
	local wasInCombat = boss.isInCombat

	if QUEST_DURATION > 0 and wasInCombat ~= isInCombat then
		boss.timeline[QUEST_DURATION] = isInCombat
		boss.lastTime = QUEST_DURATION
		boss.isInCombat = isInCombat
		if isInCombat then
			log_info(string.format('%s entered combat at %.4f', boss.name, QUEST_DURATION))
		else
			log_info(string.format('%s exited combat at %.4f', boss.name, QUEST_DURATION))
		end
	end
end

-- track damage taken by monsters
local function read_AfterCalcInfo_DamageSide(args)
	local enemy = sdk.to_managed_object(args[2])
	if not enemy then
		return
	end

	local boss = LARGE_MONSTERS[enemy]
	if not boss then
		return
	end

	if enemy:call('getHpVital') == 0 then
		return
	end

	local info = sdk.to_managed_object(args[3]) -- snow.hit.EnemyCalcDamageInfo.AfterCalcInfo_DamageSide

	local attackerId     = info:call("get_AttackerID")
	local attackerTypeId = info:call("get_DamageAttackerType")

	local physicalDamage  = tonumber(info:call("get_PhysicalDamage"))
	local elementDamage   = tonumber(info:call("get_ElementDamage"))
	local conditionDamage = tonumber(info:call("get_ConditionDamage"))

	addDamageToBoss(boss, attackerId, attackerTypeId
	, physicalDamage, elementDamage, conditionDamage)
end

local function tryLoadTypeDefinitions()
	if not SCENE_MANAGER_TYPE then
		SCENE_MANAGER_TYPE = sdk.find_type_definition("via.SceneManager")
		if MANAGER.SCENE and SCENE_MANAGER_TYPE then
			SCENE_MANAGER_VIEW = sdk.call_native_func(MANAGER.SCENE, SCENE_MANAGER_TYPE, "get_MainView")
		else
			log_error('Failed to find via.SceneManager')
		end
	end

	if not QUEST_MANAGER_TYPE then
		QUEST_MANAGER_TYPE = sdk.find_type_definition("snow.QuestManager")
		if QUEST_MANAGER_TYPE then
			QUEST_MANAGER_METHOD_ONCHANGEDGAMESTATUS = QUEST_MANAGER_TYPE:get_method("onChangedGameStatus")
			-- register function hook
			sdk.hook(QUEST_MANAGER_METHOD_ONCHANGEDGAMESTATUS,
				function(args) read_onChangedGameStatus(args) end,
				function(retval) return retval end)
			log_info('Hooked snow.QuestManager:onGameChangeStatus()')
		else
			log_error('Failed to find snow.QuestManager')
		end
	end

	if not SNOW_ENEMY_ENEMYCHARACTERBASE then
		--local QUEST_MANAGER_METHOD_ADDKPIATTACKDAMAGE = QUEST_MANAGER_TYPE:get_method("addKpiAttackDamage")
		SNOW_ENEMY_ENEMYCHARACTERBASE = sdk.find_type_definition("snow.enemy.EnemyCharacterBase")
		if SNOW_ENEMY_ENEMYCHARACTERBASE then
			SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE = SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("update")
			-- register function hook
			sdk.hook(SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE,
				function(args) updateBossEnemy(args) end,
				function(retval) return retval end)
				log_info('Hooked snow.enemy.EnemyCharacterBase:update()')

			-- stockDamage function also works, for host only
			SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE =
				SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("afterCalcDamage_DamageSide")
			-- register function hook
			sdk.hook(SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE,
				function(args) read_AfterCalcInfo_DamageSide(args) end,
				function(retval) return retval end)
				log_info('Hooked snow.enemy.EnemyCharacterBase:afterCalcDamage_DamageSide()')
		else
			log_error('Failed to find snow.enemy.EnemyCharacterBase')
		end
	end

	if not STAGE_MANAGER_TYPE then
		STAGE_MANAGER_TYPE = sdk.find_type_definition("snow.stage.StageManager")
		if STAGE_MANAGER_TYPE then
			STAGE_MANAGER_METHOD_ENDTRAININGROOM = STAGE_MANAGER_TYPE:get_method("endTrainingRoom")
			-- register function hook
			sdk.hook(STAGE_MANAGER_METHOD_ENDTRAININGROOM,
				function() read_endTrainingRoom() end,
				function(retval) return retval end)
		else
			log_error('Failed to find snow.stage.StageManager')
		end
	end
end

--#endregion

--#region REFramework

local function registerWaitingHotkeys()
	if HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER then
		for key,_ in pairs(ENUM_KEYBOARD_KEY) do
			-- key released
			if ENUM_KEYBOARD_MODIFIERS[key] and MANAGER.KEYBOARD:call("getRelease", key) then
				log.info(string.format('unregister modifier %d', key))
				HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER[key] = nil
			end
			-- key pressed
			if MANAGER.KEYBOARD:call("getTrg", key) then
				if ENUM_KEYBOARD_MODIFIERS[key] then
					log.info(string.format('register modifier %d', key))
					HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER[key] = true
				else
					-- pressed a valid hotkey
					log.info(string.format('register hotkey %d', key))
					-- register it
					HOTKEY_TOGGLE_OVERLAY = key
					-- register modifiers
					-- first, require NO modifiers be held
					for modifierKey,_ in pairs(ENUM_KEYBOARD_MODIFIERS) do
						HOTKEY_TOGGLE_OVERLAY_MODIFIERS[modifierKey] = false
					end
					-- then change requirement for any modifiers the user did actually want
					for modifierKey,needsHeld in pairs(HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER_WITH_MODIFIER) do
						HOTKEY_TOGGLE_OVERLAY_MODIFIERS[modifierKey] = needsHeld
					end
					-- clear flags
					HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false
					-- remember that we assigned this frame so we don't actually toggle the overlay
					ASSIGNED_HOTKEY_THIS_FRAME = true
				end
			end
		end
	end
end

-- runs every frame
local function dpsFrame()
	-- make sure resources are initialized
	if not hasManagedResources() then
		return
	end

	if not hasNativeResources() then
		return
	end

	-- get our function hooks if we don't have them yet
	tryLoadTypeDefinitions()

	local villageArea = 0
	local questStatus = MANAGER.QUEST:get_field("_QuestStatus")
	IS_IN_QUEST = (questStatus >= 2)

	if IS_IN_QUEST then
		SetQuestDuration(MANAGER.QUEST:call("getQuestElapsedTimeSec"))
	else
		-- VillageAreaManager is unreliable, not always there, stale references
		-- get a new reference
		MANAGER.AREA = sdk.get_managed_singleton("snow.VillageAreaManager")
		if MANAGER.AREA then
			villageArea = MANAGER.AREA:get_field("<_CurrentAreaNo>k__BackingField")
		end
	end

	IS_IN_TRAININGHALL = (villageArea == 5)
	if IS_IN_TRAININGHALL then
		SetQuestDuration(MANAGER.AREA:call("get_TrainingHallStayTime"))
	end

	IS_ONLINE = (MANAGER.LOBBY and MANAGER.LOBBY:call("IsQuestOnline")) or false

	updateHeldHotkeyModifiers()
	checkHotkeyActivated()

	-- if the window is open
	if DRAW_WINDOW_SETTINGS then
		-- update every frame
		dpsUpdate()
	-- when a quest is active
	elseif IS_IN_QUEST then
		dpsUpdateOccasionally(QUEST_DURATION)
	-- when you are in the training area
	elseif IS_IN_TRAININGHALL then
		dpsUpdateOccasionally(QUEST_DURATION)
	else
		-- clean up some things in between quests
		if LAST_UPDATE_TIME ~= 0 then
			cleanUpData()
		end
	end
end

re.on_frame(function()
	if DRAW_WINDOW_SETTINGS then
		DrawWindowSettings()
	end

	if DRAW_WINDOW_REPORT then
		DrawWindowReport()
	end

	if DRAW_WINDOW_HOTKEYS then
		DrawWindowHotkeys()
	else
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false
	end

	registerWaitingHotkeys()

	if DPS_ENABLED then
		dpsFrame()
	end

	ASSIGNED_HOTKEY_THIS_FRAME = false
end)

re.on_draw_ui(function()
	imgui.begin_group()
	imgui.text('coavins dps meter')

	if imgui.button('settings') then
		DRAW_WINDOW_SETTINGS = not DRAW_WINDOW_SETTINGS

		if DRAW_WINDOW_SETTINGS then
			if CFG('SHOW_TEST_DATA_WHILE_MENU_IS_OPEN') then
				initializeTestData()
			end
		else
			if isInTestMode() then
				clearTestData()
			end
		end
	end

	imgui.same_line()

	if imgui.button('filters') then
		DRAW_WINDOW_REPORT = not DRAW_WINDOW_REPORT
	end

	imgui.same_line()

	if imgui.button('hotkeys') then
		DRAW_WINDOW_HOTKEYS = not DRAW_WINDOW_HOTKEYS
	end

	imgui.end_group()
end)

--#endregion

-- last minute initialization

-- load default settings
if not loadDefaultConfig() then
	return -- halt script
end

-- load any saved settings
loadSavedConfigIfExist()

-- load presets into cache
loadPresets()

-- perform sanity checks
sanityCheck()

-- make sure this table has all modifiers in it
for key,_ in pairs(ENUM_KEYBOARD_MODIFIERS) do
	CURRENTLY_HELD_MODIFIERS[key] = false
end

-- register with d2d plugin
d2d.register(function()
	FONT = d2d.create_font("Tahoma", 14 * CFG('TABLE_SCALE'))
end, dpsDraw)

log_info('init complete')

-- export locals for testing
if _G._UNIT_TESTING then
	_G._CFG = _CFG
	_G.ATTACKER_TYPES  = ATTACKER_TYPES
	_G.REPORT_ATTACKER_TYPES  = _FILTERS.ATTACKER_TYPES
	_G.LARGE_MONSTERS  = LARGE_MONSTERS
	_G.DAMAGE_REPORTS  = DAMAGE_REPORTS
	_G.REPORT_MONSTERS = REPORT_MONSTERS
	_G.MANAGER = MANAGER
	_G.SetCFG = SetCFG
	_G.SetQuestDuration = SetQuestDuration
	_G.cleanUpData      = cleanUpData
	_G.SetReportOtomo   = SetReportOtomo
	_G.SetReportOther   = SetReportOther
	_G.AddAttackerTypeToReport = AddAttackerTypeToReport
	_G.initializeDamageCounter = initializeDamageCounter
	_G.getTotalDamageForDamageCounter = getTotalDamageForDamageCounter
	_G.sumDamageCountersList   = sumDamageCountersList
	_G.mergeDamageCounters     = mergeDamageCounters
	_G.initializeDamageSource  = initializeDamageSource
	_G.initializeBossMonster   = initializeBossMonster
	_G.addDamageToBoss         = addDamageToBoss
	_G.initializeReport        = initializeReport
	_G.mergeBossIntoReport     = mergeBossIntoReport
	_G.sumDamageSourcesList    = sumDamageSourcesList
	_G.generateReport          = generateReport
end
