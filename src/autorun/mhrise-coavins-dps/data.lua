local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'
local ENUM  = require 'mhrise-coavins-dps.enum'

local this = {}

-- damage counter
this.initializeDamageCounter = function()
	local c = {}
	c.physical  = 0.0
	c.elemental = 0.0
	c.condition = 0.0 -- ailment buildup
	c.stun      = 0.0 -- stun buildup

	c.ailment = {} -- ailment damage
	c.ailment[4] = 0.0 -- poison
	c.ailment[5] = 0.0 -- blast
	--[[ snow.enemy.EnemyDef.ConditionDamageType
		0 Paralyze
		1 Sleep
		2 Stun
		3 Flash
		4 Poison
		5 Blast
		6 Stamina
		7 MarionetteStart
		8 Water
		9 Fire
		10 Ice
		11 Thunder
		12 FallTrap
		13 ShockTrap
		14 Capture
		15 Koyashi
		16 SteelFang
	]]

	c.numHit = 0 -- how many hits
	c.maxHit = 0 -- biggest hit
	c.lastHit = 0 -- last hit
	c.numUpCrit = 0 -- how many crits
	c.numDnCrit = 0 -- how many negative crits
	c.firstStrike = STATE.HIGH_NUMBER -- time of first strike
	c.lastStrike = 0 -- time of last strike

	-- table of damage counters by attacker ID
	-- used to track damage dealt via marionette riders
	c.riders = nil

	return c
end

this.initializeDamageCounterWithDummyData = function(multiplier)
	multiplier = multiplier or 1.0

	local c = this.initializeDamageCounter()
	c.physical  = math.random(1,1000) * multiplier
	c.elemental = math.random(1,600) * multiplier
	c.condition = math.random(1,100) * multiplier
	c.ailment[4] = math.random(1,200) * multiplier
	c.ailment[5] = math.random(1,500) * multiplier
	c.numHit = math.floor(math.random(1,200) * multiplier)
	c.maxHit = math.floor(math.random(1,500) * multiplier)
	c.numUpCrit = math.floor(math.random(1,50) * multiplier)
	c.numDnCrit = math.floor(math.random(1,10) * multiplier)
	return c
end

this.getTotalDamageForDamageCounter = function(c)
	return c.physical
		+ c.elemental
		+ c.ailment[4]
		+ c.ailment[5]
end

this.mergeDamageCounters = function(a, b)
	if not a then a = this.initializeDamageCounter() end
	if not b then b = this.initializeDamageCounter() end
	local c = this.initializeDamageCounter()
	c.physical  = a.physical  + b.physical
	c.elemental = a.elemental + b.elemental
	c.condition = a.condition + b.condition
	c.stun      = a.stun      + b.stun
	c.ailment[4] = a.ailment[4] + b.ailment[4]
	c.ailment[5] = a.ailment[5] + b.ailment[5]
	c.numHit = a.numHit + b.numHit
	c.maxHit = math.max(a.maxHit, b.maxHit)
	c.numUpCrit = a.numUpCrit + b.numUpCrit
	c.numDnCrit = a.numDnCrit + b.numDnCrit
	c.firstStrike = math.min(a.firstStrike, b.firstStrike)
	c.lastStrike = math.max(a.lastStrike, b.lastStrike)
	if a.lastStrike > b.lastStrike then
		c.lastHit = a.lastHit
	else
		c.lastHit = b.lastHit
	end

	-- merge rider tables
	if a.riders then
		if not c.riders then
			c.riders = {}
		end
		for key, value in pairs(a.riders) do
			if not c.riders[key] then
				c.riders[key] = this.initializeDamageCounter()
			end
			c.riders[key] = this.mergeDamageCounters(c.riders[key], value)
		end
	end
	if b.riders then
		if not c.riders then
			c.riders = {}
		end
		for key, value in pairs(b.riders) do
			if not c.riders[key] then
				c.riders[key] = this.initializeDamageCounter()
			end
			c.riders[key] = this.mergeDamageCounters(c.riders[key], value)
		end
	end

	return c
end

-- damage source
this.initializeDamageSource = function(attackerId)
	local s = {}
	s.id = attackerId

	s.counters = {}
	for _,type in pairs(ENUM.DAMAGE_TYPES) do
		s.counters[type] = this.initializeDamageCounter()
	end

	return s
end

this.initializeDamageSourceWithDummyPlayerData = function(attackerId)
	local s = this.initializeDamageSource(attackerId)

	s.counters['PlayerWeapon'] = this.initializeDamageCounterWithDummyData()

	return s
end

this.initializeDamageSourceWithDummyOtomoData = function(attackerId)
	local s = this.initializeDamageSource(attackerId)

	s.counters['Otomo'] = this.initializeDamageCounterWithDummyData(0.25)

	return s
end

this.initializeDamageSourceWithDummyMonsterData = function(attackerId)
	local s = this.initializeDamageSource(attackerId)

	s.counters['monster'] = this.initializeDamageCounterWithDummyData(0.25)

	return s
end

-- boss
-- this entire city must be purged
this.initializeBossMonster = function(bossEnemy)
	local boss = {}

	boss.enemy = bossEnemy
	boss.id = nil

	boss.species = bossEnemy:call("get_EnemySpecies")
	boss.genus   = bossEnemy:call("get_BossEnemyGenus")

	-- get type and name
	boss.enemyType = bossEnemy:get_field("<EnemyType>k__BackingField")
	boss.name = STATE.MANAGER.MESSAGE:call("getEnemyNameMessage", boss.enemyType)
	boss.isQuestTarget = false

	-- figure out if it's a quest target
	local targetTypes = STATE.MANAGER.QUEST:call("getQuestTargetEmTypeList")
	if targetTypes then
		local targetCount = targetTypes:call("get_Count")
		for i = 0, targetCount-1 do
			local targetType = targetTypes:call("get_Item", i)
			if targetType ~= 0 and targetType == boss.enemyType then
				boss.isQuestTarget = true
			end
		end
	end

	boss.damageSources = {}

	boss.ailment = {}

	-- amount that each player has contributed to each ailment
	boss.ailment.buildup = {}
	boss.ailment.buildup[4] = {}
	boss.ailment.buildup[5] = {}

	-- percentage that each player contributed to each ailment
	boss.ailment.share = {}
	boss.ailment.share[4] = {}
	boss.ailment.share[5] = {}

	-- number of times ailment triggered
	boss.ailment.count = {}
	boss.ailment.count[4] = 0
	boss.ailment.count[5] = 0

	-- get counts for poison and blast
	local damageParam = bossEnemy:get_field("<DamageParam>k__BackingField")
	if damageParam then
		local blastParam = damageParam:get_field("_BlastParam")
		if blastParam then
			local getCnt = blastParam:call("get_ActivateCount")
			if getCnt then
				local activateCnt = getCnt:get_element(0):get_field("mValue")
				if activateCnt > boss.ailment.count[5] then
					boss.ailment.count[5] = activateCnt
				end
			end
		end
		local poisonParam = damageParam:get_field("_PoisonParam")
		if poisonParam then
			local getCnt = poisonParam:call("get_ActivateCount")
			if getCnt then
				local activateCnt = getCnt:get_element(0):get_field("mValue")
				if activateCnt > boss.ailment.count[4] then
					boss.ailment.count[4] = activateCnt
				end
			end
		end
	end

	-- index of player who is currently riding
	boss.rider = nil

	boss.hp = {}
	boss.hp.current = 0.0
	boss.hp.max     = 0.0
	boss.hp.missing = 0.0
	boss.hp.percent = 0.0

	boss.timeline = {} -- don't ask...
	boss.lastTime = 0
	boss.isInCombat = false

	-- store it in the table
	STATE.LARGE_MONSTERS[bossEnemy] = boss
	table.insert(STATE.ORDERED_MONSTERS, bossEnemy)

	-- automatically add monster to report if we have all monsters selected
	if STATE.ORDERED_MONSTERS_SELECTED == 0
	-- and we don't want targets only, or it's a target
	and (not CORE.CFG('ADD_TARGETS_TO_REPORT') or boss.isQuestTarget or STATE.IS_IN_TRAININGHALL) then
		CORE.AddMonsterToReport(bossEnemy, boss)
	end

	CORE.log_debug('initialized new ' .. boss.name)
end

this.initializeBossMonsterWithDummyData = function(bossKey, fakeName)
	local boss = {}

	boss.enemy = bossKey

	boss.genus = 999
	boss.species = 0

	boss.name = fakeName

	local s = {}
	-- players
	s[0] = this.initializeDamageSourceWithDummyPlayerData(0)
	s[1] = this.initializeDamageSourceWithDummyPlayerData(1)
	s[2] = this.initializeDamageSourceWithDummyPlayerData(2)
	s[3] = this.initializeDamageSourceWithDummyPlayerData(3)

	-- otomo
	local dummyId = CORE.getFakeAttackerIdForOtomoId(0)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = CORE.getFakeAttackerIdForOtomoId(1)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = CORE.getFakeAttackerIdForOtomoId(2)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)
	dummyId = CORE.getFakeAttackerIdForOtomoId(3)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)

	-- servants
	s[4] = this.initializeDamageSourceWithDummyPlayerData(4)
	dummyId = CORE.getFakeAttackerIdForOtomoId(5)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)
	s[5] = this.initializeDamageSourceWithDummyPlayerData(5)
	dummyId = CORE.getFakeAttackerIdForOtomoId(6)
	s[dummyId] = this.initializeDamageSourceWithDummyOtomoData(dummyId)

	-- monster
	s[1001] = this.initializeDamageSourceWithDummyMonsterData(1001)

	boss.damageSources = s

	boss.ailment = {}
	boss.ailment.buildup = {}
	boss.ailment.buildup[4] = {}
	boss.ailment.buildup[5] = {}

	boss.ailment.share = {}
	boss.ailment.share[4] = {}
	boss.ailment.share[5] = {}

	boss.hp = {}
	boss.hp.current = 0.0
	boss.hp.max     = 0.0
	boss.hp.missing = math.random(5000,12000)
	boss.hp.percent = 0.0

	boss.timeline = {}
	boss.timeline[math.random(100,150)] = true
	boss.timeline[math.random(200,300)] = false
	boss.lastTime = 0
	boss.isInCombat = false

	STATE.TEST_MONSTERS[bossKey] = boss
	CORE.AddMonsterToReport(bossKey, boss)
end

-- used for addDamageToBoss
this.initializeDamageInfo = function()
	local info = {}
	info.physicalAmt = 0
	info.elementalAmt = 0
	info.conditionAmt = 0
	info.conditionType = 0
	info.stunAmt = 0
	info.ailmentAmt = 0
	info.ailmentType = nil
	info.criticalType = 0
	info.riderId = nil

	return info
end

this.addDamageToBoss = function(boss, attackerId, damageTypeId, info)
	local amtPhysical   = info.physicalAmt
	local amtElemental  = info.elementalAmt
	local amtCondition  = info.conditionAmt
	local typeCondition = info.conditionType
	local amtStun       = info.stunAmt
	local criticalType  = info.criticalType
	local amtAilment    = info.ailmentAmt
	local typeAilment   = info.ailmentType
	local riderId       = info.riderId

	if amtPhysical ~= amtPhysical
	or amtElemental ~= amtElemental
	or amtCondition ~= amtCondition
	or typeCondition ~= typeCondition
	or amtStun ~= amtStun
	or criticalType ~= criticalType
	or amtAilment ~= amtAilment
	then
		CORE.log_error('Failed to add damage due to NaN: ' ..
		string.format('%.0f/%.0f %.0f:%.0f:%.0f:%.0f'
		, attackerId, damageTypeId, amtPhysical, amtElemental, amtCondition, amtAilment) )
	end

	local amt = this.initializeDamageCounter()
	amt.physical  = amtPhysical
	amt.elemental = amtElemental
	amt.stun = amtStun
	amt.condition = amtCondition
	if typeAilment then
		amt.ailment[typeAilment] = amtAilment
	end
	if criticalType == 1 then
		amt.numUpCrit = 1
	elseif criticalType == 2 then
		amt.numDnCrit = 1
	end
	-- don't track this for ailment damage
	if not typeAilment or typeAilment == 0 then
		amt.numHit = 1
		amt.maxHit = this.getTotalDamageForDamageCounter(amt)
	end

	amt.firstStrike = STATE.QUEST_DURATION
	amt.lastStrike = STATE.QUEST_DURATION
	amt.lastHit = this.getTotalDamageForDamageCounter(amt)

	--CORE.log_debug(string.format('%.0f/%.0f %.0f:%.0f:%.0f:%.0f'
	--, attackerId, damageTypeId, amtPhysical, amtElemental, amtCondition, amtAilment))

	local sources = boss.damageSources
	local buildup = boss.ailment.buildup
	local damageType = ENUM.DAMAGE_TYPES[damageTypeId]
	if not damageType then
		CORE.log_error('Could not find damage type for id ' .. damageTypeId)
		return
	end

	local isOtomo   = (damageTypeId >= 21 and damageTypeId <= 23)

	if isOtomo then
		-- separate otomo from their master
		attackerId = CORE.getFakeAttackerIdForOtomoId(attackerId)
	end

	-- get the damage source for this attacker
	if not sources[attackerId] then
		sources[attackerId] = this.initializeDamageSource(attackerId)
	end
	local s = sources[attackerId]

	-- get the damage counter for this type
	if not s.counters[damageType] then
		s.counters[damageType] = this.initializeDamageCounter()
	end
	local c = s.counters[damageType]

	-- handle marionette attacks
	if riderId then
		if not c.riders then
			c.riders = {}
		end
		if not c.riders[riderId] then
			c.riders[riderId] = this.initializeDamageCounter()
		end

		-- put this damage on the rider counter instead
		c.riders[riderId] = this.mergeDamageCounters(c.riders[riderId], amt)
	else
		-- add damage facts to counter
		s.counters[damageType] = this.mergeDamageCounters(c, amt)
	end

	-- accumulate buildup for certain ailment types
	if typeCondition == 4 or typeCondition == 5 then
		-- get the buildup accumulator for this type
		if not buildup[typeCondition] then
			buildup[typeCondition] = {}
		end
		local b = buildup[typeCondition]
		-- accumulate this buildup for this attacker
		b[attackerId] = (b[attackerId] or 0.0) + amtCondition
		CORE.log_debug(string.format('set buildup for id %.0f to %.0f', attackerId, b[attackerId]))
	end
end

this.addAilmentDamageToBoss = function(boss, ailmentType, ailmentDamage)
	CORE.log_debug('addAilmentDamageToBoss')
	-- we only track poison and blast for now
	if not ailmentType or (ailmentType ~= 4 and ailmentType ~= 5) then
		return
	end

	local damage = ailmentDamage or 0.0

	-- split up damage according to ratio of buildup on boss for this type
	local shares = boss.ailment.share[ailmentType]
	for attackerId, pct in pairs(shares) do
		--CORE.log_debug('reward share for id ' .. attackerId)
		local portion = damage * pct
		CORE.log_debug(string.format('reward %.0f for %.0f damage of type %.0f', attackerId, portion, ailmentType))
		local info = this.initializeDamageInfo()
		info.ailmentAmt = portion
		info.ailmentType = ailmentType
		this.addDamageToBoss(boss, attackerId, 0, info)
	end
end

-- take accumulated ailment buildup and calculate ratios for each attacker
this.calculateAilmentContrib = function(boss, type)
	local b = boss.ailment.buildup[type]
	local s = boss.ailment.share[type]

	-- get total
	local total = 0.0
	for _,value in pairs(b) do
		total = total + value
	end

	for key, value in pairs(b) do
		-- update ratio for this attacker
		s[key] = value / total

		CORE.log_debug(string.format('%.0f earned %.0f for %.0f buildup', key, s[key], b[key]))

		-- clear accumulated buildup for this attacker
		-- they have to start over to earn a share of next ailment trigger
		b[key] = 0.0
	end
end

this.initializeTestData = function()
	STATE.TEST_MONSTERS = {}
	CORE.makeTableEmpty(STATE.REPORT_MONSTERS)

	this.initializeBossMonsterWithDummyData(111, 'Monster A')
	this.initializeBossMonsterWithDummyData(222, 'Monster B')
	this.initializeBossMonsterWithDummyData(333, 'Monster C')
end

this.isInTestMode = function()
	return (STATE.TEST_MONSTERS ~= nil)
end

this.clearTestData = function()
	STATE.TEST_MONSTERS = nil
	CORE.resetReportMonsters()
end

this.initializeServant = function(servantId)
	local servant = {}

	servant.servantId = servantId
	--servant.name = STATE.MANAGER.SERVANT:call("getServantName", servantId)

	local aiControl = STATE.MANAGER.SERVANT:call("getAIControlByServantID", servantId) -- snow.player.PlayerAIControl
	local servantInfo = aiControl:call("get_ServantInfo") -- snow.ai.ServantInfo
	servant.name = servantInfo:call("get_ServantName")
	servant.id = servantInfo:call("get_ServantPlayerIndex")

	-- store it in the table
	STATE.SERVANTS[servantId] = servant
	CORE.log_debug('initialized new servant ' .. servant.name)
end

return this
