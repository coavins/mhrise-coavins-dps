local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'
local ENUM  = require 'mhrise-coavins-dps.enum'
local DATA  = require 'mhrise-coavins-dps.data'

local this = {}

this.initializeReport = function()
	local report = {}

	report.items = {}

	report.topDamage = 0.0
	report.totalDamage = 0.0
	report.missingHealth = 0.0 -- total amount of HP missing from all selected monsters
	report.missingDamage = 0.0 -- total amount of damage missing from the table

	report.timeline = {} -- events for timestamps
	report.timestamps = {} -- ordered timestamps
	report.time = 0.0
	report.questTime = 0.0

	return report
end

this.getReportItem = function(report, id)
	for _,item in ipairs(report.items) do
		if item.id == id then
			return item
		end
	end
	return nil
end

this.initializeReportItem = function(id)
	if not id then
		CORE.log_error('initializing report item with no id')
	end

	local item = {}

	item.id = id
	item.playerNumber = nil
	item.otomoNumber = nil
	item.servantNumber = nil
	item.name = ''
	item.carts = nil

	-- Player
	if CORE.attackerIdIsPlayer(item.id) then
		item.playerNumber = item.id + 1
		item.name = STATE.PLAYER_NAMES[item.playerNumber]
		item.rank = STATE.PLAYER_RANKS[item.playerNumber]
		item.rank2 = STATE.PLAYER_MASTERRANKS[item.playerNumber]
		item.carts = STATE.PLAYER_DEATHS[item.playerNumber] or 0
	-- Otomo
	elseif CORE.attackerIdIsOtomo(item.id) then
		item.otomoNumber = CORE.getOtomoIdFromFakeAttackerId(item.id) + 1
		item.name = STATE.OTOMO_NAMES[item.otomoNumber]
	-- Servant
	elseif CORE.attackerIdIsServant(item.id) then
		item.servantNumber = item.id - 3
		-- Try to find servant name
		for _,servant in pairs(STATE.SERVANTS) do
			if servant.id and servant.id == item.id then
				item.name = servant.name
			end
		end
	elseif item.id == STATE.COMBINE_ALL_OTHERS_ATTACKER_ID then
		item.name = 'Others'
	else
		-- Boss
		for _,boss in pairs(STATE.LARGE_MONSTERS) do
			if boss.id and boss.id == item.id then
				item.name = boss.name
			end
		end
	end

	item.counters = {}

	item.total = 0.0

	item.totalPhysical = 0.0
	item.totalElemental = 0.0
	item.totalCondition = 0.0
	item.totalStun      = 0.0
	item.totalPoison    = 0.0
	item.totalBlast     = 0.0
	item.totalOtomo = 0.0

	item.pctPhysical = 0
	item.pctElemental = 0

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
	item.lastHit = 0
	item.numUpCrit = 0
	item.numDnCrit = 0
	item.pctUpCrit = 0
	item.pctDnCrit = 0

	item.firstStrike = STATE.HIGH_NUMBER
	item.lastStrike = 0

	return item
end

this.getOrInsertReportItem = function(report, id)
	-- get report item, creating it if necessary
	local item = this.getReportItem(report, id)
	if not item then
		item = this.initializeReportItem(id)
		table.insert(report.items, item)
	end
	return item
end

this.sumDamageCountersList = function(counters, damageTypeFilter)
	local sum = {}
	sum.total = 0.0
	sum.physical = 0.0
	sum.elemental = 0.0
	sum.condition = 0.0
	sum.stun = 0.0
	sum.poison = 0.0
	sum.blast = 0.0
	sum.otomo = 0.0

	sum.numHit = 0
	sum.maxHit = 0
	sum.lastHit = 0
	sum.numUpCrit = 0
	sum.numDnCrit = 0
	sum.firstStrike = STATE.HIGH_NUMBER
	sum.lastStrike = 0

	-- get totals from counters
	for type,counter in pairs(counters) do
		if not damageTypeFilter or damageTypeFilter[type] then
			local counterTotal = DATA.getTotalDamageForDamageCounter(counter)

			if (type == 'Otomo' or type == 'OtAirouShell014' or type == 'OtAirouShell102')
			and CORE.CFG('COMBINE_OTOMO_WITH_HUNTER') then
				-- count otomo's condition damage here if necessary
				if CORE.CFG('CONDITION_LIKE_DAMAGE') then
					counterTotal = counterTotal + counter.condition
				end

				-- sum together otomo's different types of damage and store it as its own type of damage instead
				sum.otomo = sum.otomo + counterTotal

				sum.total = sum.total + counterTotal
			else
				sum.physical  = sum.physical  + counter.physical
				sum.elemental = sum.elemental + counter.elemental
				sum.condition = sum.condition + counter.condition
				sum.stun      = sum.stun      + counter.stun
				sum.poison    = sum.poison    + counter.ailment[4]
				sum.blast     = sum.blast     + counter.ailment[5]

				sum.total = sum.total + counterTotal
			end

			sum.numHit    = sum.numHit + counter.numHit
			sum.maxHit     = math.max(sum.maxHit, counter.maxHit)
			sum.numUpCrit = sum.numUpCrit + counter.numUpCrit
			sum.numDnCrit = sum.numDnCrit + counter.numDnCrit
			sum.firstStrike = math.min(sum.firstStrike, counter.firstStrike)
			if counter.lastStrike > sum.lastStrike then
				sum.lastStrike = counter.lastStrike
				sum.lastHit = counter.lastHit
			end
		end
	end

	return sum
end

this.sumDamageSourcesList = function(sources)
	local sum = {}
	sum.total = 0.0
	sum.physical = 0.0
	sum.elemental = 0.0
	sum.condition = 0.0
	sum.stun = 0.0
	sum.poison = 0.0
	sum.blast = 0.0
	sum.otomo = 0.0

	sum.numHit = 0
	sum.maxHit = 0
	sum.lastHit = 0
	sum.numUpCrit = 0
	sum.numDnCrit = 0
	sum.firstStrike = STATE.HIGH_NUMBER
	sum.lastStrike = 0

	for _,source in pairs(sources) do
		local other = this.sumDamageCountersList(source.counters)
		sum.total = sum.total + other.total
		sum.physical  = sum.physical  + other.physical
		sum.elemental = sum.elemental + other.elemental
		sum.condition = sum.condition + other.condition
		sum.stun      = sum.stun      + other.stun
		sum.poison    = sum.poison    + other.poison
		sum.blast     = sum.blast     + other.blast
		sum.otomo     = sum.otomo     + other.otomo

		sum.numHit    = sum.numHit + other.numHit
		sum.maxHit     = math.max(sum.maxHit, other.maxHit)
		sum.numUpCrit = sum.numUpCrit + other.numUpCrit
		sum.numDnCrit = sum.numDnCrit + other.numDnCrit
		sum.firstStrike = math.min(sum.firstStrike, other.firstStrike)
		if other.lastStrike > sum.lastStrike then
			sum.lastStrike = other.lastStrike
			sum.lastHit = other.lastHit
		end
	end

	return sum
end

this.mergeReportItemCounters = function(a, b)
	local counters = {}
	for _,type in pairs(ENUM.DAMAGE_TYPES) do
		counters[type] = DATA.mergeDamageCounters(a[type], b[type])
	end
	return counters
end

this.mergeDamageSourceIntoReportItem = function(item, source)
	-- don't allow merging source and item with different IDs
	if item.id ~= source.id then
		-- make an exception for otomo and player to account for the trick we pulled in mergeDamageSourcesIntoReport()
		-- also make an exception for the "combine all others" setting which allows any id to merge
		if not CORE.attackerIdIsOtomo(source.id) and item.id ~= STATE.COMBINE_ALL_OTHERS_ATTACKER_ID then
			CORE.log_error('tried to merge a damage source into a report item with a different id')
			return
		end
	end

	item.counters = this.mergeReportItemCounters(item.counters, source.counters)
end

this.sortReportItems_DESC = function(a, b)
	return a.total > b.total
end

this.sortReportItems_ASC = function(a, b)
	return a.total < b.total
end

this.sortReportItems_Player = function(a, b)
	if     a.playerNumber and not b.playerNumber then return true
	elseif b.playerNumber and not a.playerNumber then return false
	elseif a.playerNumber and     b.playerNumber then return a.playerNumber < b.playerNumber
	elseif a.otomoNumber and not b.otomoNumber then return true
	elseif b.otomoNumber and not a.otomoNumber then return false
	elseif a.otomoNumber and     b.otomoNumber then return a.otomoNumber < b.otomoNumber
	else return a.id < b.id
	end
end

this.sortReportItems_Player_DESC = function(a, b)
	if     a.playerNumber and not b.playerNumber then return false
	elseif b.playerNumber and not a.playerNumber then return true
	elseif a.playerNumber and     b.playerNumber then return a.playerNumber > b.playerNumber
	elseif a.otomoNumber and not b.otomoNumber then return false
	elseif b.otomoNumber and not a.otomoNumber then return true
	elseif a.otomoNumber and     b.otomoNumber then return a.otomoNumber > b.otomoNumber
	else return a.id > b.id
	end
end

this.mergeBossTimelineIntoReport = function(report, boss)
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

this.calculateReportTime = function(report)
	report.time = 0.0
	report.questTime = STATE.QUEST_DURATION

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
		report.time = report.time + (STATE.QUEST_DURATION - a)
	end
end

this.filterAllowsAttacker = function(attackerId)
	-- Show players
	if STATE._FILTERS.INCLUDE_PLAYER and CORE.attackerIdIsPlayer(attackerId) then
		return true
	-- Show player buddies
	elseif (STATE._FILTERS.INCLUDE_OTOMO and CORE.attackerIdIsOtomo(attackerId)
			and not CORE.attackerIdIsServantOtomo(attackerId)) then
		return true
	-- Show servants
	elseif (STATE._FILTERS.INCLUDE_SERVANT and CORE.attackerIdIsServant(attackerId)) then
		return true
	-- Show servant buddies
	elseif (STATE._FILTERS.INCLUDE_SERVANTOTOMO and CORE.attackerIdIsServantOtomo(attackerId)) then
		return true
	-- Show large monsters
	elseif (STATE._FILTERS.INCLUDE_LARGE and CORE.attackerIdIsBoss(attackerId)) then
		return true
	-- Show other (small monsters, villagers during rampage, etc)
	elseif (STATE._FILTERS.INCLUDE_OTHER and CORE.attackerIdIsOther(attackerId)) then
		return true
	-- Always show this fake attacker
	elseif attackerId == STATE.COMBINE_ALL_OTHERS_ATTACKER_ID then
		return true
	else
		return false
	end
end

-- main function responsible for loading a boss into a report
this.mergeBossIntoReport = function(report, boss)
	local totalDamage = 0.0
	local bestDamage = 0.0

	-- merge damage sources
	for _,source in pairs(boss.damageSources) do
		local effSourceId = source.id

		-- merge otomo with master
		if CORE.CFG('COMBINE_OTOMO_WITH_HUNTER') and CORE.attackerIdIsOtomo(effSourceId) then
			local otomoId = CORE.getOtomoIdFromFakeAttackerId(effSourceId)

			-- handle primary otomo
			if otomoId >= 0 and otomoId <= 3 then
				-- pretend this damage source belongs to this player
				effSourceId = otomoId
			-- handle secondary otomo
			elseif otomoId == 4 then
				-- pretend to be player 1
				effSourceId = 0
			-- handle servant otomos
			elseif otomoId == 5 then
				-- pretend to be player 5 (servant)
				effSourceId = 4
			elseif otomoId == 6 then
				-- pretend to be player 6 (servant)
				effSourceId = 5
			end
		end

		-- merge others together
		if (CORE.CFG('COMBINE_ALL_OTHERS') or CORE.CFG('HIDE_COMBINED_OTHERS'))
		and effSourceId ~= STATE.MY_PLAYER_ID then
			effSourceId = STATE.COMBINE_ALL_OTHERS_ATTACKER_ID
		end

		-- if we aren't excluding this type of source
		if this.filterAllowsAttacker(effSourceId) then
			local item = this.getOrInsertReportItem(report, effSourceId)

			this.mergeDamageSourceIntoReportItem(item, source)
		end

		-- if this source is a monster, find marionette rider damage
		-- add this damage to the appropriate report items
		if CORE.attackerIdIsBoss(source.id) then
			local c = source.counters['marionette']
			if c.riders then
				for riderId,riderCounter in pairs(c.riders) do
					if CORE.CFG('MARIONETTE_IS_PLAYER_DMG') then
						-- merge into rider's report item
						local item = this.getOrInsertReportItem(report, riderId)
						if item then
							item.counters['marionette'] = DATA.mergeDamageCounters(item.counters['marionette'], riderCounter)
						end
					elseif this.filterAllowsAttacker(effSourceId) then
						-- merge into monster's report item
						local item = this.getOrInsertReportItem(report, effSourceId)
						if item then
							item.counters['marionette'] = DATA.mergeDamageCounters(item.counters['marionette'], riderCounter)
						end
					end
				end
			end
		end
	end

	-- merge boss into report timeline
	this.mergeBossTimelineIntoReport(report, boss)
	this.calculateReportTime(report)

	-- now loop all report items and update the totals after adding this boss
	for _,item in ipairs(report.items) do
		-- skip the fake "missing damage" item
		if item.id ~= STATE.MISSING_ATTACKER_ID then
			-- calculate the item's own total damage
			local sum = this.sumDamageCountersList(item.counters, STATE._FILTERS.DAMAGE_TYPES)
			item.totalPhysical  = sum.physical
			item.totalElemental = sum.elemental
			item.totalCondition = sum.condition
			item.totalStun      = sum.stun
			item.totalPoison    = sum.poison
			item.totalBlast     = sum.blast
			item.totalOtomo     = sum.otomo

			item.numHit = sum.numHit
			item.maxHit = sum.maxHit
			item.lastHit = sum.lastHit
			item.numUpCrit = sum.numUpCrit
			item.numDnCrit = sum.numDnCrit
			item.firstStrike = sum.firstStrike
			item.lastStrike = sum.lastStrike

			if item.numHit > 0 then
				item.pctUpCrit = item.numUpCrit / item.numHit
				item.pctDnCrit = item.numDnCrit / item.numHit
			else
				item.pctUpCrit = 0
				item.pctDnCrit = 0
			end

			if CORE.CFG('CONDITION_LIKE_DAMAGE') then
				item.total = sum.total + sum.condition
			else
				item.total = sum.total
			end

			if item.total > 0 then
				item.pctPhysical = item.totalPhysical / item.total
				item.pctElemental = item.totalElemental / item.total
			end

			-- calculate dps
			if report.time > 0 then
				item.dps.report = item.total / report.time
			end

			if report.questTime > 0 then
				item.dps.quest = item.total / report.questTime
				local playerTime = nil
				if item.playerNumber then
					playerTime = STATE.PLAYER_TIMES[item.playerNumber]
				elseif item.otomoNumber then
					local number = item.otomoNumber
					if number == 5 then
						number = 1
					end
					playerTime = STATE.PLAYER_TIMES[number]
				end
				if CORE.CFG('PDPS_BASED_ON_FIRST_STRIKE') and item.firstStrike < STATE.HIGH_NUMBER then
					playerTime = item.firstStrike
				end
				if playerTime then
					item.dps.personal = item.total / (report.questTime - playerTime)
					item.dps.time = (report.questTime - playerTime)
				else
					item.dps.personal = 0.0
					item.dps.time = 0.0
				end
			end

			-- remember which combatant has the most damage
			if item.total > bestDamage then
				bestDamage = item.total
			end

			-- accumulate total overall damage
			totalDamage = totalDamage + item.total
		end
	end

	report.missingHealth = report.missingHealth + boss.hp.missing

	-- show missing damage as a fake report item
	local missingDamage = report.missingHealth - totalDamage
	if CORE.CFG('SHOW_MISSING_DAMAGE') and missingDamage > 0 then
		local item = this.getOrInsertReportItem(report, STATE.MISSING_ATTACKER_ID)
		item.name = 'Not shown'

		item.totalPhysical = missingDamage
		item.total = missingDamage

		if item.total > bestDamage then
			bestDamage = item.total
		end
		totalDamage = totalDamage + item.total
	end

	report.missingDamage = missingDamage
	report.totalDamage = totalDamage
	report.topDamage = bestDamage

	-- remove report items that have no damage
	CORE.arrayRemove(report.items, CORE.reportItemHasDamage)

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
	if CORE.CFG('TABLE_SORT_IN_ORDER') then
		if CORE.CFG('TABLE_SORT_ASC') then
			table.sort(report.items, this.sortReportItems_Player_DESC)
		else
			table.sort(report.items, this.sortReportItems_Player)
		end
	elseif CORE.CFG('TABLE_SORT_ASC') then
		table.sort(report.items, this.sortReportItems_ASC)
	else
		table.sort(report.items, this.sortReportItems_DESC)
	end
end

this.generateReport = function(filterBosses)
	CORE.makeTableEmpty(STATE.DAMAGE_REPORTS)

	local report = this.initializeReport()

	for _,boss in pairs(filterBosses) do
		this.mergeBossIntoReport(report, boss)
	end

	table.insert(STATE.DAMAGE_REPORTS, report)
end

return this
