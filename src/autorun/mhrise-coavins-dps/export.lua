local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'
local ENUM  = require 'mhrise-coavins-dps.enum'

local this = {}

this.round = function(x)
    -- simple 2 decimal places
	if x == 0 then
		return 0
	end

	local num = math.floor(x * 100)
	return num / 100
end

this.exportFormatTargetId = function(arrayTargetId)
	local temp = {}
	for idx=1, #arrayTargetId do
		temp[idx] = string.format("%05d", arrayTargetId[idx])
	end
	return table.concat(temp, ",")
end

this.exportData = function()
	local DPS_INFO = {}
	DPS_INFO.datetime = tostring(os.date("%Y%m%d%H%M%S"))
	DPS_INFO.questNo = STATE.QUEST_NO
	DPS_INFO.gameVer = ENUM.VERSION[#ENUM.VERSION]
	DPS_INFO.toolVer = ENUM.TOOL_VERSION[#ENUM.TOOL_VERSION]
	DPS_INFO.targetId = this.exportFormatTargetId(STATE.QUEST_TARGET_ID)
	DPS_INFO.multiTarget = #STATE.QUEST_TARGET_ID > 1
	DPS_INFO.questTime = math.floor(STATE.QUEST_DURATION)
	DPS_INFO.playerCount = #STATE.PLAYER_NAMES
	DPS_INFO.Individual = false		-- TODO: Individual flag
	-- set playerInfo
	local players = {{}, {}, {}, {}, {}}
	for idx, value in pairs(STATE.DAMAGE_REPORTS[1].items) do
		local arrayIdx = value.id + 1	-- lua array index
		local player = {}
		player.switchAction = {}

		-- Not shown(計測対象不明なダメージ)
		if value.name == "Not shown" then
			goto notShown
		end
		-- player only
		if value.carts == nil then
			-- Because the cart is "nil" except for "player"
			goto continue
		end
		player.idx = tostring(idx)
		player.id = value.id
		player.DH = value.id == STATE.MY_PLAYER_ID
		player.name = value.name
		player.HR = value.rank
		player.MR = value.rank2
		player.time = this.round(value.dps.time)
		player.totalDamage = this.round(value.total)
		player.blast = this.round(value.totalBlast)
		player.condition = this.round(value.totalCondition)
		player.physical = this.round(value.totalPhysical)
		player.poison = this.round(value.totalPoison)
		player.stun = this.round(value.totalStun)
		player.element = this.round(value.totalElemental)
		player.pDps = this.round(value.dps.personal)
		player.perCrit = this.round(value.pctUpCrit, 2)
		player.carts = value.carts
		player.maxhit = this.round(value.maxHit)
		player.numHit = value.numHit
		player.weaponType = STATE.WEAPON_INFO[arrayIdx].type
		player.weaponName = STATE.WEAPON_INFO[arrayIdx].nameJP
		player.weaponId = STATE.WEAPON_ID[arrayIdx]
		player.skill = STATE.PLAYER_SKILL[arrayIdx]
		player.kitchenSkill = STATE.KITCHEN_SKILL[arrayIdx]
		if STATE.SWITCH_ACTION_ID[arrayIdx] then
			player.switchAction.set1 = STATE.SWITCH_ACTION_ID[arrayIdx].set1
			player.switchAction.set2 = STATE.SWITCH_ACTION_ID[arrayIdx].set2
		end
		player.otomo = {}
		players[arrayIdx] = player
		goto continue

		::notShown::
		local unknown = {}
		unknown.id = value.id
		unknown.name = value.name
		unknown.totalDamage = this.round(value.total)
		unknown.physical = this.round(value.totalPhysical)
		unknown.poison = this.round(value.totalPoison)
		unknown.stun = this.round(value.totalStun)
		unknown.element = this.round(value.totalElemental)
		players[5] = unknown

		::continue::
	end
	DPS_INFO.player = players

	-- otomoInfo
	for idx, value in pairs(STATE.DAMAGE_REPORTS[1].items) do
		-- otomo Only
		if value.id < 9990 or value.id >= 9994 then
			-- otomoId is 9990~9993
			goto continue
		end

		local otomo = {}
		local playerId = value.id - 9990
		otomo.id = value.id
		otomo.name = value.name
		otomo.totalDamage = this.round(value.total)
		otomo.blast = this.round(value.totalBlast)
		otomo.condition = this.round(value.totalCondition)
		otomo.physical = this.round(value.totalPhysical)
		otomo.poison = this.round(value.totalPoison)
		otomo.stun = this.round(value.totalStun)
		otomo.element = this.round(value.totalElemental)
		otomo.pDps = this.round(value.dps.personal)
		for idxInfo, info in pairs(STATE.OTOMO_INFO) do
			-- If the name is covered, the first information will be acquired...low priority!!!
			if value.name == info.name then
				CORE.log_debug('exported otomo:' .. idx .. ', info: ' .. idxInfo)
				otomo.isAirou = info.isAirou
				otomo.supportAction = info.supportAction
				otomo.skill = info.skill
				otomo.equipDogToolType = info.equipDogToolType
				otomo.supportType = info.supportType
				otomo.airouTargetType = info.airouTargetType
				otomo.dogPosType = info.dogPosType
			end
		end
		DPS_INFO.player[playerId + 1].otomo = otomo
		::continue::
	end

	-- file name
	-- local filename = ''
	-- boss name
	-- for _,boss in pairs(STATE.LARGE_MONSTERS) do
	-- 	if filename ~= '' then filename = filename .. '+' end
	-- 	filename = filename .. boss.name
	-- end
	-- filename = 'DpsExportData_' .. filename .. '+' .. tostring(os.date("%Y%m%d%H%M%S"))
	local filename = 'DpsExportData_' .. STATE.QUEST_NO .. '_' .. tostring(os.date("%Y%m%d%H%M%S"))
	-- jsonExport
	local success = json.dump_file(STATE.DATADIR .. 'logs/' .. filename .. '.json', DPS_INFO)
	if success then
		CORE.log_info('exported combat data to logs/' .. filename .. '.json')
	else
		CORE.log_error('failed to export combat data to dpsLogs/' .. filename .. '.json')
	end
	-- debug file for overwriting
	json.dump_file(STATE.DATADIR .. 'logs/00_latest_dps.json', DPS_INFO)
end

return this
