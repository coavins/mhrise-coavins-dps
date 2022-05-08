local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'

local this = {}

this.exportData = function()
	local file = {}

	local MONSTERS = {}
	for _,boss in pairs(STATE.LARGE_MONSTERS) do
		table.insert(MONSTERS, boss)
	end
	file['MONSTERS'] = MONSTERS

	local PLAYERINFO = {}
	for index, value in pairs(STATE.PLAYER_NAMES) do
		local player = {}
		player.number = tostring(index)
		player.id = tostring(index-1)
		player.name = value
		table.insert(PLAYERINFO, player)
	end
	file['PLAYERINFO'] = PLAYERINFO

	local OTOMOINFO = {}
	for index, value in pairs(STATE.OTOMO_NAMES) do
		local otomo = {}
		otomo.number = tostring(index)
		otomo.id = tostring(CORE.getFakeAttackerIdForOtomoId(index-1))
		otomo.name = value
		table.insert(OTOMOINFO, otomo)
	end
	file['OTOMOINFO'] = OTOMOINFO

	local filename = ''

	for _,boss in pairs(STATE.LARGE_MONSTERS) do
		if filename ~= '' then filename = filename .. '+' end
		filename = filename .. boss.name
	end

	if filename == '' then filename = 'NoData' end

	filename = filename .. '+' .. tostring(math.random(999999))

	local success = json.dump_file(STATE.DATADIR .. 'logs/' .. filename .. '.json', file)
	if success then
		CORE.log_info('exported combat data to logs/' .. filename .. '.json')
	else
		CORE.log_error('failed to export combat data to logs/' .. filename .. '.json')
	end
end

return this
