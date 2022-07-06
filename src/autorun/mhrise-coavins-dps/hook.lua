local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local DATA   = require 'mhrise-coavins-dps.data'

local this = {}

-- keep track of some things on monsters
this.updateBossEnemy = function(args)
	if not STATE.HOOKS_ENABLED then
		return
	end

	local enemy = sdk.to_managed_object(args[2])

	-- get this boss from the table
	local boss = STATE.LARGE_MONSTERS[enemy]
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

	if not boss.id then
		local setInfo = enemy:call("get_SetInfo")
		if setInfo then
			local id = setInfo:call("get_UniqueId")
			if id then
				CORE.log_debug('found id ' .. id .. ' for ' .. boss.name)
				if id == 0 then
					id = STATE.FAKE_ATTACKER_ID
					CORE.log_debug('override id to ' .. id)
				end

				boss.id = id
			end
		end
	end

	local isCapture = enemy:call("isCapture")
	local isCombatMode = enemy:call("get_IsCombatMode")
	local isInCombat = isCombatMode and boss.hp.current > 0 and not isCapture
	local wasInCombat = boss.isInCombat

	if STATE.QUEST_DURATION > 0 and wasInCombat ~= isInCombat then
		boss.timeline[STATE.QUEST_DURATION] = isInCombat
		boss.lastTime = STATE.QUEST_DURATION
		boss.isInCombat = isInCombat
		if isInCombat then
			CORE.log_debug(string.format('%s entered combat at %.4f', boss.name, STATE.QUEST_DURATION))
		else
			CORE.log_debug(string.format('%s exited combat at %.4f', boss.name, STATE.QUEST_DURATION))
		end
	end

	-- get poison and blast damage
	local damageParam = enemy:get_field("<DamageParam>k__BackingField")
	if damageParam then
		local blastParam = damageParam:get_field("_BlastParam")
		if blastParam then
			-- if applied, then calculate share for blast and apply damage
			local activateCnt = blastParam:call("get_ActivateCount"):get_element(0):get_field("mValue")
			if activateCnt > boss.ailment.count[5] then
				boss.ailment.count[5] = activateCnt
				DATA.calculateAilmentContrib(boss, 5)

				local blastDamage = blastParam:call("get_BlastDamage")
				DATA.addAilmentDamageToBoss(boss, 5, blastDamage)
			end
		end

		local poisonParam = damageParam:get_field("_PoisonParam")
		if poisonParam then
			-- if applied, then calculate share for poison
			local activateCnt = poisonParam:call("get_ActivateCount"):get_element(0):get_field("mValue")
			if activateCnt > boss.ailment.count[4] then
				boss.ailment.count[4] = activateCnt
				DATA.calculateAilmentContrib(boss, 4)
			end

			-- if poison tick, apply damage
			local poisonDamage = poisonParam:get_field("<Damage>k__BackingField")
			local isDamage = poisonParam:call("get_IsDamage")
			if isDamage then
				DATA.addAilmentDamageToBoss(boss, 4, poisonDamage)
			end
		end
	end

	-- get marionette rider
	local marioParam = enemy:get_field("<MarioParam>k__BackingField")
	if marioParam then
		local isMarionette = marioParam:call("get_IsMarionette")
		if isMarionette then
			local playerIndex = marioParam:call("get_MarioPlayerIndex")
			if boss.rider ~= playerIndex then
				boss.rider = playerIndex
				CORE.log_debug('player ' .. playerIndex .. ' is earning marionette damage for ' .. boss.name)
			end
		end
	end
end

-- track damage taken by monsters
this.read_AfterCalcInfo_DamageSide = function(args)
	if not STATE.HOOKS_ENABLED then
		return
	end

	local enemy = sdk.to_managed_object(args[2])
	if not enemy then
		return
	end

	local boss = STATE.LARGE_MONSTERS[enemy]
	if not boss then
		return
	end

	if boss.hp.current == 0 then
		return
	end

	local info = sdk.to_managed_object(args[3]) -- snow.hit.EnemyCalcDamageInfo.AfterCalcInfo_DamageSide

	local attackerId     = info:call("get_AttackerID")
	local damageTypeId = info:call("get_DamageAttackerType")
	local riderId = nil

	local physicalDamage  = tonumber(info:call("get_PhysicalDamage"))
	local elementDamage   = tonumber(info:call("get_ElementDamage"))
	local conditionDamage = tonumber(info:call("get_ConditionDamage"))
	local conditionType   = tonumber(info:call("get_ConditionDamageType")) -- snow.enemy.EnemyDef.ConditionDamageType

	local criticalType = tonumber(info:call("get_CriticalResult")) -- snow.hit.CriticalType (0: not, 1: crit, 2: bad crit)

	local isMarionetteAttack = info:call("get_IsMarionetteAttack")

	CORE.log_debug(string.format('%.0f:%.0f = %.0f:%.0f:%.0f:%.0f'
	, attackerId, damageTypeId, physicalDamage, elementDamage, conditionDamage, conditionType))

	-- override attacker id for monster attacks when monster has id=0
	if attackerId == 0 and damageTypeId == STATE.MONSTER_DAMAGE_TYPE_ID then
		attackerId = STATE.FAKE_ATTACKER_ID
	end

	-- override damage type for marionette attackers
	if isMarionetteAttack then
		damageTypeId = 125
		for _,b in pairs(STATE.LARGE_MONSTERS) do
			if b.id == attackerId then
				riderId = b.rider
				break
			end
		end
		CORE.log_debug('riderID is ' .. (riderId or 'nil'))
	end

	if attackerId == nil then
		CORE.log_error('Attacker ID is nil: '.. string.format('%.0f:%.0f = %.0f:%.0f:%.0f:%.0f'
		, attackerId, damageTypeId, physicalDamage, elementDamage, conditionDamage, conditionType))
		return

	elseif damageTypeId == nil then
		CORE.log_error('Damage Type ID is nil: '.. string.format('%.0f:%.0f = %.0f:%.0f:%.0f:%.0f'
		, attackerId, damageTypeId, physicalDamage, elementDamage, conditionDamage, conditionType))
		return

	end

	DATA.addDamageToBoss(boss, attackerId, damageTypeId
	, physicalDamage, elementDamage, conditionDamage, conditionType, 0, 0, criticalType, riderId)
end

this.tryHookSdk = function()
	if not STATE.SCENE_MANAGER_TYPE then
		STATE.SCENE_MANAGER_TYPE = sdk.find_type_definition("via.SceneManager")
		if STATE.MANAGER.SCENE and STATE.SCENE_MANAGER_TYPE then
			STATE.SCENE_MANAGER_VIEW = sdk.call_native_func(STATE.MANAGER.SCENE, STATE.SCENE_MANAGER_TYPE, "get_MainView")
		else
			CORE.log_error('Failed to find via.SceneManager')
		end
	end

	if not STATE.SNOW_ENEMY_ENEMYCHARACTERBASE then
		--local QUEST_MANAGER_METHOD_ADDKPIATTACKDAMAGE = QUEST_MANAGER_TYPE:get_method("addKpiAttackDamage")
		STATE.SNOW_ENEMY_ENEMYCHARACTERBASE = sdk.find_type_definition("snow.enemy.EnemyCharacterBase")
		if STATE.SNOW_ENEMY_ENEMYCHARACTERBASE then
			STATE.SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE = STATE.SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("update")
			-- register function hook
			sdk.hook(STATE.SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE,
				function(args) this.updateBossEnemy(args) end,
				function(retval) return retval end)
			CORE.log_debug('Hooked snow.enemy.EnemyCharacterBase:update()')

			-- stockDamage function also works, for host only
			STATE.SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE =
			STATE.SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("afterCalcDamage_DamageSide")
			-- register function hook
			sdk.hook(STATE.SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE,
				function(args) this.read_AfterCalcInfo_DamageSide(args) end,
				function(retval) return retval end)
			CORE.log_debug('Hooked snow.enemy.EnemyCharacterBase:afterCalcDamage_DamageSide()')
		else
			CORE.log_error('Failed to find snow.enemy.EnemyCharacterBase')
		end
	end

	if not STATE.QUEST_MANAGER_TYPE then
		STATE.QUEST_MANAGER_TYPE = sdk.find_type_definition("snow.QuestManager")
		if STATE.QUEST_MANAGER_TYPE then
			STATE.QUEST_MANAGER_TYPE_RECV_FORFEIT = STATE.QUEST_MANAGER_TYPE:get_method("netRecvForfeit")
			STATE.QUEST_MANAGER_TYPE_SEND_FORFEIT = STATE.QUEST_MANAGER_TYPE:get_method("netSendForfeit")
			STATE.QUEST_MANAGER_TYPE_NOTIFY_DEATH = STATE.QUEST_MANAGER_TYPE:get_method("notifyDeath")

			sdk.hook(STATE.QUEST_MANAGER_TYPE_RECV_FORFEIT, --For NOT host
				function(args) this.deaths(args, "recv") end,
				function(retval) return retval end)

			sdk.hook(STATE.QUEST_MANAGER_TYPE_SEND_FORFEIT, --For host
				function(args) this.deaths(args, "send") end,
				function(retval) return retval end)

			sdk.hook(STATE.QUEST_MANAGER_TYPE_NOTIFY_DEATH, -- For Offline
				function(args) this.deaths(args, "noti") end,
				function(retval) return retval end)

		else
			CORE.log_error('Failed to find snow.QuestManager')
		end
	end
end

this.deaths = function(args, t)
	if not STATE.HOOKS_ENABLED then
		return
	end

	if not STATE.IS_ONLINE then --We reach here with notifyDeath when player is offline
		if STATE.PLAYER_DEATHS[1] == nil then
			STATE.PLAYER_DEATHS[1] = 1
		else
			STATE.PLAYER_DEATHS[1] = STATE.PLAYER_DEATHS[1] + 1
		end
		return
	end

	if STATE.MY_PLAYER_ID == 0 then -- If player is host, netSendForfeit is always correct
		if t == "send" then
			local player_index = sdk.to_int64(args[3]) + 1
			if STATE.PLAYER_DEATHS[player_index] == nil then
				STATE.PLAYER_DEATHS[player_index] = 1
			else
				STATE.PLAYER_DEATHS[player_index] = STATE.PLAYER_DEATHS[player_index] + 1
			end
		end
	else
		if t == "recv" then
			local o = sdk.to_managed_object(args[3])
			local player_index = o:get_field("_DeadPlIndex") + 1
			local isFromHost = o:get_field("_IsFromQuestHostPacket")
			if isFromHost then -- Data is sent twice, 1 from host and 1 from dead player. Check if from host to only add 1
				if STATE.PLAYER_DEATHS[player_index] == nil then
					STATE.PLAYER_DEATHS[player_index] = 1
				else
					STATE.PLAYER_DEATHS[player_index] = STATE.PLAYER_DEATHS[player_index] + 1
				end
			end
		end
	end

end

return this
