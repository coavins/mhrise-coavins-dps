local STATE = require 'mhrise-coavins-dps.state'
local ENUM  = require 'mhrise-coavins-dps.enum'

local this = {}

this.makeTableEmpty = function(table)
	for k,_ in pairs(table) do table[k]=nil end
end

this.log_info = function(text)
	log.info('mhrise-coavins-dps: ' .. text)
end

this.log_error = function(text)
	log.error('mhrise-coavins-dps: ' .. text)
end

this.log_debug = function(text)
	if this.CFG('DEBUG_ENABLED') then
		log.info('mhrise-coavins-dps: ' .. text)
	end
end

this.showFatalError = function(msg)
	this.log_error(msg)
	---@diagnostic disable-next-line: param-type-mismatch
	re.on_draw_ui(function()
		imgui.begin_group()
		imgui.text('coavins dps meter: Could not start')
		imgui.text(msg)
		imgui.end_group()
	end)
end

this.isProperlyInstalled = function()
	local file = this.readDataFile('default.json')
	if not file then
		this.showFatalError('Missing file: reframework/data/mhrise-coavins-dps/default.json')
		return false
	end

	file = this.readDataFile('translations/en-US.json')
	if not file then
		this.showFatalError('Missing file: reframework/data/mhrise-coavins-dps/translations/en-US.json')
		return false
	end

	return true
end

this.readScreenDimensions = function()
	local size = STATE.SCENE_MANAGER_VIEW:call("get_Size")
	if not size then
		this.log_error('could not get screen size')
	end

	STATE.SCREEN_W = size:get_field("w")
	STATE.SCREEN_H = size:get_field("h")
end

this.getScreenXFromX = function(x)
	return STATE.SCREEN_W * x
end

this.getScreenYFromY = function(y)
	return STATE.SCREEN_H * y
end

this.hasNativeResources = function()
	if not STATE.MANAGER.SCENE then
		STATE.MANAGER.SCENE = sdk.get_native_singleton("via.SceneManager")
		if not STATE.MANAGER.SCENE then
			return false
		end
	end

	return true
end

-- return false if any managed resource is not loaded
-- we also return false on the first frame that we load it, to delay its use by one frame
this.hasManagedResources = function()
	if not STATE.MANAGER.PLAYER then
		STATE.MANAGER.PLAYER = sdk.get_managed_singleton("snow.player.PlayerManager")
		return false
	end

	if not STATE.MANAGER.QUEST then
		STATE.MANAGER.QUEST = sdk.get_managed_singleton("snow.QuestManager")
		return false
	end

	if not STATE.MANAGER.ENEMY then
		STATE.MANAGER.ENEMY = sdk.get_managed_singleton("snow.enemy.EnemyManager")
		return false
	end

	if not STATE.MANAGER.MESSAGE then
		STATE.MANAGER.MESSAGE = sdk.get_managed_singleton("snow.gui.MessageManager")
		return false
	end

	if not STATE.MANAGER.LOBBY then
		STATE.MANAGER.LOBBY = sdk.get_managed_singleton("snow.LobbyManager")
		return false
	end

	if not STATE.MANAGER.OTOMO then
		STATE.MANAGER.OTOMO = sdk.get_managed_singleton("snow.otomo.OtomoManager")
		return false
	end

	if not STATE.MANAGER.KEYBOARD then
		local softKeyboard = sdk.get_managed_singleton("snow.GameKeyboard")
		if softKeyboard then
			STATE.MANAGER.KEYBOARD = softKeyboard:get_field("hardKeyboard")
		end
		return false
	end

	if not STATE.MANAGER.PROGRESS then
		STATE.MANAGER.PROGRESS = sdk.get_managed_singleton("snow.progress.ProgressManager")
		return false
	end

	if not STATE.MANAGER.SERVANT then
		STATE.MANAGER.SERVANT = sdk.get_managed_singleton("snow.ai.ServantManager")
		return false
	end

	if not STATE.MANAGER.EQUIP_STATUS_PARAM then
		STATE.MANAGER.EQUIP_STATUS_PARAM = sdk.get_managed_singleton("snow.gui.EquipStatusParamManager")
		return false
	end

	return true
end

this.CFG = function(name)
	return STATE._CFG[name].VALUE
end

this.SetCFG = function(name, value)
	STATE._CFG[name].VALUE = value
end

this.TXT = function(name)
	return STATE._CFG[name].TEXT
end

this.MIN = function(name)
	return STATE._CFG[name].MIN
end

this.MAX = function(name)
	return STATE._CFG[name].MAX
end

this.COLOR = function(name)
	return STATE._COLORS[name]
end

this.SetColor = function(name, value)
	STATE._COLORS[name] = value
end

this.HOTKEY = function(name)
	return STATE._HOTKEYS[name]
end

-- returns file json
this.readDataFile = function(filename)
	filename = STATE.DATADIR .. filename
	return json.load_file(filename)
end

-- merges second cfg into first
-- returns true if anything was done
this.mergeCfgIntoLeft = function(cfg1, cfg2, isPreset)
	if cfg2 then
		for name,setting in pairs(cfg2) do
			if name == 'TABLE_COLS' or name == 'TABLE_COLS_WIDTH' then
				local t1 = cfg1[name]
				local t2 = setting
				for i, v in ipairs(t2) do
					t1[i] = v
				end
			else
				-- if the setting exists
				if name and cfg1[name] then
					-- if we are loading a preset and this setting is allowed
					if not isPreset or this.isSettingAllowedForPresets(name) then
						cfg1[name].VALUE = setting.VALUE -- load only the values
					end
				end
			end
		end
	end
end

this.mergeColorsIntoLeft = function(colors1, colors2)
	if colors2 then
		for name,setting in pairs(colors2) do
			colors1[name] = setting
		end
	end
end

this.mergeFiltersIntoLeft = function(filters1, filters2)
	if filters2 then
		for name,setting in pairs(filters2) do
			if name == 'DAMAGE_TYPES' then
				for k,v in pairs(filters2[name]) do
					filters1[name][k] = v
				end
			else
				filters1[name] = setting
			end
		end
	end
end

this.mergeHotkeysIntoLeft = function(hotkeys1, hotkeys2)
	if hotkeys2 then
		for name,setting in pairs(hotkeys2) do
			hotkeys1[name].KEY       = tonumber(setting.KEY)
			for key, value in pairs(setting.MODIFIERS) do
				hotkeys1[name].MODIFIERS[tonumber(key)] = value
			end
		end
	end
end

-- returns true on success
this.loadDefaultConfig = function()
	local file = this.readDataFile('default.json')
	if not file then
		this.log_error('failed to load default.json (did you install the data files?)')
		return
	end

	STATE._CFG = file['CFG']
	STATE._COLORS = file['COLORS']
	STATE._FILTERS = file['FILTERS']
	STATE._HOTKEYS = file['HOTKEYS']

	-- fix hotkeys
	for _, hotkey in pairs(STATE._HOTKEYS) do
		-- convert key to number
		hotkey.KEY = tonumber(hotkey.KEY)
		local modifiers = {}
		for key, value in pairs(hotkey.MODIFIERS) do
			-- convert keys to numbers
			modifiers[tonumber(key)] = value
		end
		hotkey.MODIFIERS = modifiers
	end
end

this.loadDefaultColors = function()
	local file = this.readDataFile('default.json')
	if not file then
		this.log_error('failed to load default.json (did you install the data files?)')
		return
	end

	STATE._COLORS = file['COLORS']
end

this.loadSavedConfigIfExist = function()
	local file = this.readDataFile('saves/save.json') -- file might not exist
	if file then
		-- load save file on top of current config
		this.mergeCfgIntoLeft(STATE._CFG, file.CFG, false)
		this.mergeColorsIntoLeft(STATE._COLORS, file.COLORS)
		this.mergeFiltersIntoLeft(STATE._FILTERS, file.FILTERS)
		this.mergeHotkeysIntoLeft(STATE._HOTKEYS, file.HOTKEYS)

		this.log_info('loaded configuration from saves/save.json')
	end
end

this.saveCurrentConfig = function()
	local file = {}
	file['CFG'] = STATE._CFG
	file['COLORS'] = STATE._COLORS
	file['FILTERS'] = STATE._FILTERS

	-- fix hotkeys
	local fixedHotkeys = {}
	for name, hotkey in pairs(STATE._HOTKEYS) do
		fixedHotkeys[name] = {}
		-- convert key to string
		fixedHotkeys[name].KEY = tostring(hotkey.KEY)
		local modifiers = {}
		for key, value in pairs(hotkey.MODIFIERS) do
			-- convert keys to numbers
			modifiers[tostring(key)] = value
		end
		fixedHotkeys[name].MODIFIERS = modifiers
	end

	file['HOTKEYS'] = fixedHotkeys

	-- save current config to disk, replacing any existing file
	local success = json.dump_file(STATE.DATADIR .. 'saves/save.json', file)
	if success then
		this.log_info('saved configuration to saves/save.json')
	else
		this.log_error('failed to save configuration to saves/save.json')
	end
end

-- load color schemes
this.loadColorschemes = function()
	local paths = fs.glob([[mhrise-coavins-dps\\colors\\.*json]])

	for _,path in ipairs(paths) do
		local name = string.match(path, '\\([%a%s]+).json')
		local file = this.readDataFile('colors/' .. name .. '.json')
		if file then
			STATE._COLORSCHEMES[name] = file
			this.log_info('loaded color scheme ' .. name)
		end
	end

	-- build colorscheme options list
	for name,_ in pairs(STATE._COLORSCHEMES) do
		table.insert(STATE.COLORSCHEME_OPTIONS, name)
	end
	table.sort(STATE.COLORSCHEME_OPTIONS)
	table.insert(STATE.COLORSCHEME_OPTIONS, 1, 'Select a color scheme')
end

this.applySelectedColorscheme = function()
	local name = STATE.COLORSCHEME_OPTIONS[STATE.COLORSCHEME_OPTIONS_SELECTED]
	local scheme = STATE._COLORSCHEMES[name]
	if scheme then
		this.mergeColorsIntoLeft(STATE._COLORS, scheme.COLORS)

		this.log_info(string.format('applied color scheme %s', name))
	end
end

-- load presets
this.loadPresets = function()
	local paths = fs.glob([[mhrise-coavins-dps\\presets\\.*json]])

	for _,path in ipairs(paths) do
		local name = string.match(path, '\\([%a%s]+).json')
		local file = this.readDataFile('presets/' .. name .. '.json')
		if file then
			STATE._PRESETS[name] = file
			this.log_info('loaded preset ' .. name)
		end
	end

	-- build preset options list
	for name,_ in pairs(STATE._PRESETS) do
		table.insert(STATE.PRESET_OPTIONS, name)
	end
	table.sort(STATE.PRESET_OPTIONS)
	table.insert(STATE.PRESET_OPTIONS, 1, 'Select a preset')
end

this.applySelectedPreset = function()
	local name = STATE.PRESET_OPTIONS[STATE.PRESET_OPTIONS_SELECTED]
	local preset = STATE._PRESETS[name]
	if preset then
		-- load save file on top of current config
		this.mergeCfgIntoLeft(STATE._CFG, preset.CFG, true)
		this.mergeFiltersIntoLeft(STATE._FILTERS, preset.FILTERS)
		this.mergeColorsIntoLeft(STATE._COLORS, preset.COLORS)

		this.log_info(string.format('applied preset %s', name))
	end
end

-- There are some settings that we don't want presets to apply
this.isSettingAllowedForPresets = function(name)
	if name == 'SAVE_RESULTS_TO_DISK'
	or name == 'AUTO_SAVE'
	or name == 'UPDATE_RATE'
	or name == 'DEBUG_SHOW_MISSING_DAMAGE'
	or name == 'DEBUG_SHOW_ATTACKER_ID'
	or name == 'LOCALE'
	or name == 'FONT_FAMILY'
	or name == 'SHOW_OVERLAY_AT_BOOT'
	or name == 'SHOW_OVERLAY_IN_QUEST'
	or name == 'SHOW_OVERLAY_IN_VILLAGE'
	or name == 'SHOW_OVERLAY_POST_QUEST'
	then
		return false
	else
		return true
	end
end

this.SetQuestDuration = function(value)
	STATE.QUEST_DURATION = value
end

this.cleanUpData = function(message)
	STATE.LAST_UPDATE_TIME = 0
	this.SetQuestDuration(0.0)
	this.makeTableEmpty(STATE.LARGE_MONSTERS)
	this.makeTableEmpty(STATE.ORDERED_MONSTERS)
	STATE.ORDERED_MONSTERS_SELECTED = 0
	this.makeTableEmpty(STATE.DAMAGE_REPORTS)
	this.makeTableEmpty(STATE.REPORT_MONSTERS)
	this.makeTableEmpty(STATE.PLAYER_NAMES)
	this.makeTableEmpty(STATE.PLAYER_TIMES)
	this.makeTableEmpty(STATE.PLAYER_DEATHS)
	this.makeTableEmpty(STATE.SERVANTS)
	this.log_debug('cleared data: ' .. message)
end

this.AddMonsterToReport = function(enemyToAdd, bossInfo)
	STATE.REPORT_MONSTERS[enemyToAdd] = bossInfo
end

this.RemoveMonsterFromReport = function(enemyToRemove)
	for enemy,_ in pairs(STATE.REPORT_MONSTERS) do
		if enemy == enemyToRemove then
			STATE.REPORT_MONSTERS[enemy] = nil
			return
		end
	end
end

this.resetReportMonsters = function()
	this.makeTableEmpty(STATE.REPORT_MONSTERS)
	for enemy, boss in pairs(STATE.LARGE_MONSTERS) do
		-- add boss if we don't want targets only, or if it is a target
		if not this.CFG('ADD_TARGETS_TO_REPORT') or boss.isQuestTarget or STATE.IS_IN_TRAININGHALL then
			this.AddMonsterToReport(enemy, boss)
		end
	end
end

this.AddDamageTypeToReport = function(typeToAdd)
	STATE._FILTERS.DAMAGE_TYPES[typeToAdd] = true
	this.log_debug(string.format('damage type %s added to report', typeToAdd))
end

this.RemoveDamageTypeFromReport = function(typeToRemove)
	STATE._FILTERS.DAMAGE_TYPES[typeToRemove] = false
	this.log_debug(string.format('damage type %s removed from report', typeToRemove))
end

this.SetReportPlayer = function(value)
	STATE._FILTERS.INCLUDE_PLAYER = value
end

this.SetReportOtomo = function(value)
	STATE._FILTERS.INCLUDE_OTOMO = value
end

this.SetReportServant = function(value)
	STATE._FILTERS.INCLUDE_SERVANT = value
end

this.SetReportServantOtomo = function(value)
	STATE._FILTERS.INCLUDE_SERVANTOTOMO = value
end

this.SetReportLarge = function(value)
	STATE._FILTERS.INCLUDE_LARGE = value
end

this.SetReportOther = function(value)
	STATE._FILTERS.INCLUDE_OTHER = value
end

this.attackerIdIsPlayer = function(attackerId)
	if attackerId >= 0 and attackerId <= 3 then
		return true
	else
		return false
	end
end

this.attackerIdIsOtomo = function(attackerId)
	if attackerId >= STATE.FAKE_OTOMO_RANGE_START
	and attackerId <= STATE.FAKE_OTOMO_RANGE_START + 8 -- (4 players + SP buddy + 4 servant buddies)
	then
		return true
	else
		return false
	end
end

this.attackerIdIsServant = function(attackerId)
	if attackerId >= 4 and attackerId <= 7
	then
		return true
	else
		return false
	end
end

this.attackerIdIsServantOtomo = function(attackerId)
	if attackerId >= STATE.FAKE_OTOMO_RANGE_START + 5
	and attackerId <= STATE.FAKE_OTOMO_RANGE_START + 8
	then
		return true
	else
		return false
	end
end

this.attackerIdIsBoss = function(attackerId)
	for _,boss in pairs(STATE.LARGE_MONSTERS) do
		if boss.id and boss.id == attackerId then
			return true
		end
	end
	return false
end

this.attackerIdIsOther = function(attackerId)
	if not this.attackerIdIsPlayer(attackerId)
	and not this.attackerIdIsOtomo(attackerId)
	and not this.attackerIdIsServant(attackerId)
	and not this.attackerIdIsBoss(attackerId)
	and attackerId ~= STATE.COMBINE_ALL_OTHERS_ATTACKER_ID
	then return true
	else return false
	end
end

this.getFakeAttackerIdForOtomoId = function(otomoId)
	return STATE.FAKE_OTOMO_RANGE_START + otomoId
end

this.getOtomoIdFromFakeAttackerId = function(fakeAttackerId)
	return fakeAttackerId - STATE.FAKE_OTOMO_RANGE_START
end

-- method copied from https://stackoverflow.com/a/53038524
-- items in the array are passed into fnKeep as its only parameter
-- if the function returns false, the item is removed from the array
-- the order of remaining items should be retained, with empty space compressed
this.arrayRemove = function(t, fnKeep)
	local j, n = 1, #t;

	for i=1,n do
			if (fnKeep(t[i])) then
					-- Move i's kept value to j's position, if it's not already there.
					if (i ~= j) then
							t[j] = t[i];
							t[i] = nil;
					end
					j = j + 1; -- Increment position of where we'll place the next kept value.
			else
					t[i] = nil;
			end
	end

	return t;
end

this.reportItemHasDamage = function(item)
	return item.total > 0
end

this.updatePlayers = function()
	local oldNames = {}
	oldNames[1] = STATE.PLAYER_NAMES[1]
	oldNames[2] = STATE.PLAYER_NAMES[2]
	oldNames[3] = STATE.PLAYER_NAMES[3]
	oldNames[4] = STATE.PLAYER_NAMES[4]

	-- clear existing info
	this.makeTableEmpty(STATE.PLAYER_NAMES)
	this.makeTableEmpty(STATE.PLAYER_RANKS)
	this.makeTableEmpty(STATE.PLAYER_MASTERRANKS)
	this.makeTableEmpty(STATE.OTOMO_NAMES)

	-- get offline player name
	local myHunter = STATE.MANAGER.LOBBY:get_field("_myHunterInfo")
	if myHunter then
		STATE.PLAYER_NAMES[STATE.MY_PLAYER_ID + 1] = myHunter:get_field("_name")
	end

	-- get offline player rank
	STATE.PLAYER_RANKS[STATE.MY_PLAYER_ID + 1] = STATE.MANAGER.PROGRESS:call("get_HunterRank")
	STATE.PLAYER_MASTERRANKS[STATE.MY_PLAYER_ID + 1] = STATE.MANAGER.PROGRESS:call("get_MasterRank")

	-- get online players
	local hunterInfo
	if STATE.IS_IN_QUEST then
		hunterInfo = STATE.MANAGER.LOBBY:get_field("_questHunterInfo")
	else
		hunterInfo = STATE.MANAGER.LOBBY:get_field("_hunterInfo")
	end

	if hunterInfo then
		local hunterCount = hunterInfo:call("get_Count")
		if hunterCount then
			for i = 0, hunterCount-1 do
				local hunter = hunterInfo:call("get_Item", i)
				if hunter then
					local playerId = hunter:get_field("_memberIndex")
					local name = hunter:get_field("_name")
					local rank = hunter:get_field("_hunterRank")
					local rank2 = hunter:get_field("_masterRank")

					if playerId then
						if name then STATE.PLAYER_NAMES[playerId + 1] = name end
						if rank then STATE.PLAYER_RANKS[playerId + 1] = rank end
						if rank2 then STATE.PLAYER_MASTERRANKS[playerId + 1] = rank2 end
					end
				end
			end
		end
	end

	for key, value in ipairs(STATE.PLAYER_NAMES) do
		-- update start time for this player when the name changes
		if oldNames[key] ~= value or (STATE.PLAYER_TIMES[key] and STATE.PLAYER_TIMES[key] > STATE.QUEST_DURATION) then
			this.log_debug(string.format('updated quest time for player %d to %.0f', key, STATE.QUEST_DURATION))
			STATE.PLAYER_TIMES[key] = STATE.QUEST_DURATION
			STATE.PLAYER_DEATHS[key] = nil
			-- TODO: clear this player's data
		end
	end

	-- get offline otomo names
	local firstOtomo = STATE.MANAGER.OTOMO:call("getMasterOtomoInfo", 0)
	if firstOtomo then
		local name = firstOtomo:get_field("Name")
		--local level = firstOtomo:get_field("Level")
		STATE.OTOMO_NAMES[1] = name
	end

	local secondOtomo = STATE.MANAGER.OTOMO:call("getMasterOtomoInfo", 1)
	if secondOtomo then
		local name = secondOtomo:get_field("Name")
		--local level = firstOtomo:get_field("Level")
		-- the secondary otomo is actually the fifth one!
		STATE.OTOMO_NAMES[5] = name
	end

	-- get online otomo names
	local otomoInfo
	if STATE.IS_IN_QUEST then
		otomoInfo = STATE.MANAGER.LOBBY:get_field("_questOtomoInfo")
	else
		otomoInfo = STATE.MANAGER.LOBBY:get_field("_OtomoInfo")
	end

	if otomoInfo then
		local otomoCount = otomoInfo:call("get_Count")
		if otomoCount then
			for i=0, otomoCount-1 do
				local otomo = otomoInfo:call("get_Item", i)
				if otomo then
					local otomoId = i
					local name = otomo:get_field("_Name")

					if otomoId and name then
						STATE.OTOMO_NAMES[otomoId + 1] = name
					end
				end
			end
		end
	end
end

this.changeOverlayVisibility = function(setting)
	local showIt = this.CFG(setting)
	if     showIt == 2 then STATE.DRAW_OVERLAY = true
	elseif showIt == 3 then STATE.DRAW_OVERLAY = false
	end
end

this.getWeaponInfo = function()
	local weaponInfo = STATE.MANAGER.PLAYER:get_field("PlayerList")
	if weaponInfo then
		-- キャンプにて武器変更等した場合にPrevObjectもarrayに入っている為、4固定にクエストクリア時のみ集計している
		-- ※クリア時に武器変更している場合は集計不可
		-- Since "PrevObject" is also included in the array when changing weapons etc. at the camp,
		-- it is totaled only when clearing the quest at 4 fixed
		-- *Cannot be counted if you have changed weapons when clearing
		for idx = 0, ENUM.WEAPON_INFO_COUNT-1 do
			local weapon = weaponInfo:call("get_Item", idx)
			if weapon then
				local info = {}
				info.id = idx
				local type = weapon:get_type_definition()

				if type:is_a("snow.player.GreatSword") then
					info.name = "GreatSword"
					info.nameJP = "大剣"
					info.type = 0
				elseif type:is_a("snow.player.LongSword") then
					info.name = "LongSword"
					info.nameJP = "太刀"
					info.type = 2
				elseif type:is_a("snow.player.ShortSword") then
					info.name = "ShortSword"
					info.nameJP = "片手剣"
					info.type = 8
				elseif type:is_a("snow.player.DualBlades") then
					info.name = "DualBlades"
					info.nameJP = "双剣"
					info.type = 9
				elseif type:is_a("snow.player.Lance") then
					info.name = "Lance"
					info.nameJP = "ランス"
					info.type = 7
				elseif type:is_a("snow.player.GunLance") then
					info.name = "GunLance"
					info.nameJP = "ガンランス"
					info.type = 6
				elseif type:is_a("snow.player.Hammer") then
					info.name = "Hammer"
					info.nameJP = "ハンマー"
					info.type = 5
				elseif type:is_a("snow.player.Horn") then
					info.name = "Horn"
					info.nameJP = "狩猟笛"
					info.type = 10
				elseif type:is_a("snow.player.SlashAxe") then
					info.name = "SlashAxe"
					info.nameJP = "スラッシュアックス"
					info.type = 1
				elseif type:is_a("snow.player.ChargeAxe") then
					info.name = "ChargeAxe"
					info.nameJP = "チャージアックス"
					info.type = 11
				elseif type:is_a("snow.player.InsectGlaive") then
					info.name = "InsectGlaive"
					info.nameJP = "操虫棍"
					info.type = 12
				elseif type:is_a("snow.player.LightBowgun") then
					info.name = "LightBowgun"
					info.nameJP = "ライトボウガン"
					info.type = 3
				elseif type:is_a("snow.player.HeavyBowgun") then
					info.name = "HeavyBowgun"
					info.nameJP = "ヘビィボウガン"
					info.type = 4
				elseif type:is_a("snow.player.Bow") then
					info.name = "Bow"
					info.nameJP = "弓"
					info.type = 13
				else
					info.name = "Failed"
					info.nameJP = "Failed"
					info.type = -1
				end
				STATE.WEAPON_INFO[idx + 1] = info
			else
				STATE.WEAPON_INFO[idx + 1] = "FAILED Get Member"
			end
		end
	end
end

this.getWeaponId = function()
	local equipInfo = STATE.MANAGER.EQUIP_STATUS_PARAM:get_field("_questParam")
	if equipInfo then
		local equipCount = equipInfo:call("get_Count")
		if equipCount then
			for idx=0, equipCount-1 do
				local questParam = equipInfo:call("get_Item", idx)
				if questParam then
					local weaponId = questParam:get_field("_weaponParam"):get_field("WeaponId")

					if weaponId then
						STATE.WEAPON_ID[idx + 1] = weaponId
					else
---@diagnostic disable-next-line: assign-type-mismatch
						STATE.WEAPON_ID[idx + 1] = "FAILED GET weaponId"
					end
				end
			end
		end
	else
		STATE.WEAPON_ID = {-1, -1, -1, -1}
	end
end

this.getPlayerSkill = function()
	local equipInfos = STATE.MANAGER.LOBBY:get_field("_questEquipInfo")
	if equipInfos then
		local equipCount = equipInfos:call("get_Count")
		for idx=0, equipCount-1 do
			local equipInfo = equipInfos:call("get_Item", idx)
			if equipInfo then
				-- playerSkill --
				-- get skill id
				local skill = {}
				for idxSkill=0, ENUM.PLAYER_SKILL_COUNT - 1 do
					local skillId = equipInfo:get_field("_ArmorSkill"..string.format("%02d", idxSkill))
					if skillId and skillId ~= 0 then
						skill[idxSkill + 1] = string.format("%03d", skillId)
					end
				end
				-- get skill Lv
				for idxLv=0, ENUM.PLAYER_SKILL_LV_COUNT - 1 do
					local skillLvNum = equipInfo:get_field("_ArmorSkillLv"
															..string.format("%02d", idxLv * 2)
															.."_"
															..string.format("%02d", idxLv * 2 + 1))
					if skillLvNum and skillLvNum ~= 0 then
						local i = idxLv * 2 + 1
						-- skill one case
						if skillLvNum < ENUM.SKILL_LV_THRESHOLD then
							skill[i] = skill[i]..string.format("%02d", skillLvNum)
						else
							-- skill two case
							skill[i] = skill[i]..string.format("%02d", skillLvNum % ENUM.SKILL_LV_THRESHOLD)
							skill[i + 1] = skill[i + 1]
											..string.format("%02d", math.floor(skillLvNum / ENUM.SKILL_LV_THRESHOLD))
						end
					end
				end
				-- set skill data ex)"001(Id)07(Lv),00206,..."
				STATE.PLAYER_SKILL[idx + 1] = table.concat(skill,",")

				-- kitchenSkill --
				-- get skill id
				local kSkill = {}
				for idxSkill=0, ENUM.KITCHEN_SKILL_COUNT - 1 do
					local skillId = equipInfo:get_field("_KitchenSkill"..idxSkill)
					if skillId and skillId ~= 0 then
						kSkill[idxSkill + 1] = string.format( "%03d", skillId)
					end
				end
				-- get skill Lv
				for idxLv=0, ENUM.KITCHEN_SKILL_LV_COUNT - 1 do
					local skillLvNum = equipInfo:get_field("_KitchenSkillLv"
															..string.format( "%02d", idxLv * 2)
															.."_"
															..string.format( "%02d", idxLv * 2 + 1))
					if skillLvNum and skillLvNum ~= 0 then
						local i = idxLv * 2 + 1
						-- skill one case
						if skillLvNum < ENUM.SKILL_LV_THRESHOLD then
							kSkill[i] = kSkill[i]..string.format( "%02d", skillLvNum)
						else
							-- skill two case
							kSkill[i] = kSkill[i]
										..string.format("%02d", skillLvNum % ENUM.SKILL_LV_THRESHOLD)
							kSkill[i + 1] = kSkill[i + 1]
											..string.format("%02d", math.floor(skillLvNum / ENUM.SKILL_LV_THRESHOLD))
						end
					end
				end
				-- set skill data ex)"001(Id)07(Lv),00206,..."
				STATE.KITCHEN_SKILL[idx + 1] = table.concat(kSkill,",")
			else
				STATE.PLAYER_SKILL[idx + 1] = "FAILED GET playerSkill"
				STATE.KITCHEN_SKILL[idx + 1] = "FAILED GET kichenSkill"
			end
		end
	else
		STATE.PLAYER_SKILL = {
			"FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
		}
		STATE.KITCHEN_SKILL = {
			"FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
			, "FAILED GET questEquipInfo"
		}
	end
end

this.getOtomoInfo = function()
	local otomoInfos = STATE.MANAGER.LOBBY:get_field("_questOtomoInfo")
	if otomoInfos then
		local otomoCount = otomoInfos:call("get_Count")
		for idx=0, otomoCount-1 do
			local otomoInfo = otomoInfos:call("get_Item", idx)
			if otomoInfo then
				local info = {}
				info.skill = ""
				info.equipDogToolType = ""
				info.isAirou = true
				-- name --
				local name = otomoInfo:get_field("_Name")
				if name then
					info.name = name
				end
				-- supportAction --
				local supportActionIds = {}
				for idxSupportAction=0, ENUM.OTOMO_SUPPORT_ACTION_COUNT-1 do
					local supportAction = otomoInfo:get_field("_EquipAirouSupportAction"..idxSupportAction)
					if supportAction and supportAction ~= 0 then
						supportActionIds[idxSupportAction + 1] = string.format( "%03d", supportAction)
					end
				end
				if supportActionIds then
					-- set supportActionId ex)"001,002,..."
					info.supportAction = table.concat(supportActionIds,",")
				end
				-- skill --
				local skillIds = {}
				for idxSkill=0, ENUM.OTOMO_SKILL_COUNT-1 do
					local skill = otomoInfo:get_field("_EquipOtSkill"..idxSkill)
					if skill and skill ~= 0 then
						skillIds[idxSkill + 1] = string.format( "%03d", skill)
					end
				end
				if skillIds then
					-- set skillId ex)"001,002,..."
					info.skill = table.concat(skillIds,",")
				end
				-- dogTool --
				local equipDogToolType = {}
				for idxTool=0, ENUM.DOG_TOOL_TYPE_COUNT-1 do
					local dogToolType = otomoInfo:get_field("_EquipDogToolType"..idxTool)
					if dogToolType and dogToolType ~= 0 then
						equipDogToolType[idxTool + 1] = string.format( "%03d", dogToolType)
						info.isAirou = false
					end
				end
				-- set dogTool ex)"001,002,..."
				if equipDogToolType then
					info.equipDogToolType = table.concat(equipDogToolType,",")
				end
				-- get supporttype --
				local supportType = otomoInfo:get_field("_SupportType")
				if supportType then
					info.supportType = supportType
				end
				-- get targettype --
				local targetType = otomoInfo:get_field("_AirouTargetType")
				if targetType then
					info.airouTargetType = targetType
				end
				-- get posType --
				local posType = otomoInfo:get_field("_DogPosType")
				if posType then
					info.dogPosType = posType
				end
				STATE.OTOMO_INFO[idx + 1] = info
			else
---@diagnostic disable-next-line: assign-type-mismatch
				STATE.OTOMO_INFO[idx + 1] = "FAILED GET otomoInfo"
			end
		end
	else
		STATE.OTOMO_INFO = {{}, {}, {}, {}}
	end
end

this.getQuestNo = function()
	-- get QusetNo
	STATE.QUEST_NO = STATE.MANAGER.QUEST:get_field("_QuestIdentifier"):get_field("_QuestNo") or -1
end

this.getQuestMainMonsterId = function()
	-- get MainMonsterId
	local targetDatas = STATE.MANAGER.QUEST:get_field("_QuestTargetData")
	if targetDatas then
		local targetCount = targetDatas:call("get_Count")
		for idx=0, targetCount-1 do
			local targetData = targetDatas:call("get_Item", idx)
			if targetData then
				local id = targetData:get_field("ID")
				if id > 0 then
					STATE.QUEST_TARGET_ID[idx + 1] = id
				end
			end
		end
	else
		STATE.QUEST_TARGET_ID = {-1}
	end
end

this.getSwitchActionId = function()
	local questParams = STATE.MANAGER.EQUIP_STATUS_PARAM:get_field("_questParam")
	if questParams then
		local questParamsCount = questParams:call("get_Count")
		for idx=0, questParamsCount-1 do
			STATE.SWITCH_ACTION_ID[idx+1] = {}
			STATE.SWITCH_ACTION_ID[idx+1].set1 = "FAILED GET switchActionId"
			STATE.SWITCH_ACTION_ID[idx+1].set2 = "FAILED GET switchActionId"
			local questParam = questParams:call("get_Item", idx)
			if questParam then
				-- ActionSet1
				local switchActionSet1 = {}
				local switchAction1 = questParam:get_field("_equipStatusParam"):get_field("switchActionId_MR_1")
				if switchAction1 then
					local switchActionCount = switchAction1:call("get_Count")
					if switchActionCount then
						for idxAction=0, switchActionCount-1 do
							local actionId = switchAction1:call("get_Item", idxAction)
							if actionId then
								switchActionSet1[idxAction+1] = string.format( "%03d", actionId)
							end
						end
					end
					if switchActionSet1 then
						STATE.SWITCH_ACTION_ID[idx+1].set1 = table.concat(switchActionSet1,",")
					end
				end

				-- ActionSet2
				local switchActionSet2 = {}
				local switchAction2 = questParam:get_field("_equipStatusParam"):get_field("switchActionId_MR_2")
				if switchAction2 then
					local switchActionCount = switchAction2:call("get_Count")
					if switchActionCount then
						for idxAction=0, switchActionCount-1 do
							local actionId = switchAction2:call("get_Item", idxAction)
							if actionId then
								switchActionSet2[idxAction+1] = string.format( "%03d", actionId)
							end
						end
					end
					if switchActionSet2 then
						STATE.SWITCH_ACTION_ID[idx+1].set2 = table.concat(switchActionSet2,",")
					end
				end
			end
		end
	end
end

return this
