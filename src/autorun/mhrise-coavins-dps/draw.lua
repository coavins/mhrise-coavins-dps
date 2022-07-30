local STATE = require 'mhrise-coavins-dps.state'
local CORE  = require 'mhrise-coavins-dps.core'
local DATA  = require 'mhrise-coavins-dps.data'
local LANG  = require 'mhrise-coavins-dps.lang'

local this = {}

this.rgb_to_bgr = function(color)
	local blue  = (color >>  0) & 0xFF
	local green = (color >>  8) & 0xFF
	local red   = (color >> 16) & 0xFF
	local alpha = (color >> 24) & 0xFF
	return (alpha << 24) | (blue << 16) | (green << 8) | (red << 0)
end

this.draw_filled_rect = function(x, y, w, h, color)
	if STATE.USE_PLUGIN_D2D then
		d2d.filled_rect(x, y, w, h, color)
	else
		draw.filled_rect(x, y, w, h, this.rgb_to_bgr(color))
	end
end

this.draw_outline_rect = function(x, y, w, h, thickness, color)
	if STATE.USE_PLUGIN_D2D then
		d2d.outline_rect(x, y, w, h, thickness, color)
	else
		draw.outline_rect(x, y, w, h, this.rgb_to_bgr(color))
	end
end

this.draw_text = function(text, x, y, color)
	if STATE.USE_PLUGIN_D2D then
		d2d.text(STATE.FONT, text, x, y, color)
	else
		draw.text(text, x, y, this.rgb_to_bgr(color))
	end
end

 this.debug_line = function(text)
	STATE.DEBUG_Y = STATE.DEBUG_Y + 20
	this.draw_text(text, 0, STATE.DEBUG_Y, 0xCFAFAFAF)
end

this.drawRichText = function(text, x, y, colorText, colorShadow)
	if CORE.CFG('TEXT_DRAW_SHADOWS') and colorShadow then
		local scale = CORE.CFG('TABLE_SCALE')
		local offsetX = CORE.CFG('TEXT_SHADOW_OFFSET_X') * scale
		local offsetY = CORE.CFG('TEXT_SHADOW_OFFSET_Y') * scale
		this.draw_text(text, x + offsetX, y + offsetY, colorShadow)
	end
	this.draw_text(text, x, y, colorText)
end

this.drawRichDamageBar = function(item, x, y, maxWidth, h, colorPhysical, colorElemental)
	local w

	if CORE.CFG('DRAW_BAR_USE_UNIQUE_COLORS') then
		local colorCondition = CORE.COLOR('BAR_DMG_AILMENT')
		local colorOtomo     = CORE.COLOR('BAR_DMG_OTOMO')
		local colorPoison    = CORE.COLOR('BAR_DMG_POISON')
		local colorBlast     = CORE.COLOR('BAR_DMG_BLAST')
		local colorOther     = CORE.COLOR('BAR_DMG_OTHER')

		local remainder = item.total
			- item.totalPhysical
			- item.totalElemental
			- item.totalPoison
			- item.totalBlast
			- item.totalOtomo

		if CORE.CFG('CONDITION_LIKE_DAMAGE') then
			remainder = remainder - item.totalCondition
		end

		-- draw physical damage
		w = (item.totalPhysical / item.total) * maxWidth
		this.draw_filled_rect(x, y, w, h, colorPhysical)
		x = x + w

		-- draw elemental damage
		w = (item.totalElemental / item.total) * maxWidth
		this.draw_filled_rect(x, y, w, h, colorElemental)
		x = x + w

		if CORE.CFG('CONDITION_LIKE_DAMAGE') then
			-- draw ailment damage
			w = (item.totalCondition / item.total) * maxWidth
			this.draw_filled_rect(x, y, w, h, colorCondition)
			x = x + w
		end

		-- draw poison damage
		w = (item.totalPoison / item.total) * maxWidth
		this.draw_filled_rect(x, y, w, h, colorPoison)
		x = x + w

		-- draw blast damage
		w = (item.totalBlast / item.total) * maxWidth
		this.draw_filled_rect(x, y, w, h, colorBlast)
		x = x + w

		-- draw otomo damage
		w = (item.totalOtomo / item.total) * maxWidth
		this.draw_filled_rect(x, y, w, h, colorOtomo)
		x = x + w

		if remainder > 0 then
			-- draw whatever's left, just in case
			w = (remainder / item.total) * maxWidth
			this.draw_filled_rect(x, y, w, h, colorOther)
		end
	else
		-- draw all damage
		w = maxWidth
		this.draw_filled_rect(x, y, w, h, colorPhysical)
	end
end

this.drawReportHeaderColumn = function(col, x, y)
	local text = LANG.HEADER(col)

	this.drawRichText(text, x, y, CORE.COLOR('GRAY'), CORE.COLOR('BLACK'))
end

this.drawReportItemColumn = function(item, col, x, y)
	local text = ''

	if     col == 2 then -- hr
		if item.rank then
			text = string.format('%s', item.rank)
		end
	elseif col == 3 then -- name
		if item.playerNumber then
			if CORE.CFG('DRAW_BAR_TEXT_YOU') and item.id == STATE.MY_PLAYER_ID then
				text = 'YOU'
			elseif CORE.CFG('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES') and item.name then
				text = string.format('%s', item.name)
			else
				text = string.format('Player %.0f', item.id + 1)
			end
		elseif item.otomoNumber then
			if CORE.CFG('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES') and item.name then
				if STATE.IS_ONLINE then
					text = string.format('%s (%.0f)', item.name, item.otomoNumber)
				else
					text = string.format('%s', item.name)
				end
			else
				text = string.format('Buddy %.0f', item.otomoNumber)
			end
		elseif item.servantNumber then
			if item.name and item.name ~= '' then
				text = string.format('%s', item.name)
			else
				text = string.format('Follower %.0f', item.servantNumber)
			end
		else
			-- just draw the name
			text = string.format('%s', item.name)
		end
	elseif col == 4 then -- dps
		text = string.format(CORE.CFG('FORMAT_DPS'), item.dps.report)
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
	elseif col == 10 then -- qDPS
		text = string.format(CORE.CFG('FORMAT_DPS'), item.dps.quest)
	elseif col == 11 then -- Buildup
		text = string.format('%.0f', item.totalCondition)
	elseif col == 12 then -- Poison
		text = string.format('%.0f', item.totalPoison)
	elseif col == 13 then -- Blast
		text = string.format('%.0f', item.totalBlast)
	elseif col == 14 then -- Crit%
		text = string.format('%.1f%%', item.pctUpCrit * 100.0)
	elseif col == 15 then -- Weak%
		text = string.format('%.1f%%', item.pctDnCrit * 100.0)
	elseif col == 16 then -- pDPS
		text = string.format(CORE.CFG('FORMAT_DPS'), item.dps.personal)
	elseif col == 17 then -- physical damage
		text = string.format('%.0f', item.totalPhysical)
	elseif col == 18 then -- element damage
		text = string.format('%.0f', item.totalElemental)
	elseif col == 19 and item.carts then -- carts
		text = string.format('%.0f', item.carts)
	elseif col == 20 then -- mr
		if item.rank2 then
			text = string.format('%s', item.rank2)
		end
	elseif col == 21 then --stun
		text = string.format('%.0f', item.totalStun)
	elseif col == 22 then -- lasthit
		text = string.format('%.0f', item.lastHit)
	elseif col == 23 then -- phys%
		text = string.format('%.1f%%', item.pctPhysical * 100.0)
	elseif col == 24 then -- ele%
		text = string.format('%.1f%%', item.pctElemental * 100.0)
	end

	this.drawRichText(text, x, y, CORE.COLOR('WHITE'), CORE.COLOR('BLACK'))
end

this.drawReportItem = function(item, x, y, width, height)
	--if item.total == 0 then
		-- skip items with no damage
		--return
	--end

	-- get some values
	local scalingFactor = CORE.CFG('TABLE_SCALE')
	local text_offset_x = CORE.CFG('TABLE_ROW_TEXT_OFFSET_X') * scalingFactor
	local text_offset_y = CORE.CFG('TABLE_ROW_TEXT_OFFSET_Y') * scalingFactor
	local colorBlockWidth = 30 * scalingFactor
	if not CORE.CFG('DRAW_BAR_COLORBLOCK') then
		colorBlockWidth = 0
	end

	local damageBarWidthMultiplier = item.percentOfBest
	if CORE.CFG('DRAW_BAR_RELATIVE_TO_PARTY') then
		damageBarWidthMultiplier = item.percentOfTotal
	end

	-- get some colors
	local physicalColor = CORE.COLOR('BAR_DMG_PHYSICAL_UNIQUE')[item.playerNumber]
	if not physicalColor or not CORE.CFG('DRAW_BAR_USE_PLAYER_COLORS') then
		physicalColor = CORE.COLOR('BAR_DMG_PHYSICAL')
	end

	local elementalColor = CORE.COLOR('BAR_DMG_ELEMENT_UNIQUE')[item.playerNumber]
	if not elementalColor then
		elementalColor = CORE.COLOR('BAR_DMG_ELEMENT')
	end

	local combatantColor = CORE.COLOR('GRAY')
	if item.playerNumber then
		combatantColor = CORE.COLOR('PLAYER')[item.playerNumber]
	elseif item.otomoNumber then
		combatantColor = CORE.COLOR('OTOMO')
		physicalColor = CORE.COLOR('OTOMO')
		elementalColor = CORE.COLOR('OTOMO')
	elseif item.servantNumber then
		combatantColor = CORE.COLOR('SERVANT')
		physicalColor = CORE.COLOR('SERVANT')
		elementalColor = CORE.COLOR('SERVANT')
	end

	-- draw the actual bar
	if CORE.CFG('USE_MINIMAL_BARS') then
		-- only proceed if we actually have a color block to use here
		if CORE.CFG('DRAW_BAR_COLORBLOCK') then
			-- bar is overlaid on top of the color block
			-- color block
			this.draw_filled_rect(x, y, colorBlockWidth, height, elementalColor)

			-- damage bar
			local damageBarWidth = colorBlockWidth * damageBarWidthMultiplier
			this.draw_filled_rect(x, y, damageBarWidth, height, combatantColor)

			-- hr
			local revealRank = CORE.CFG('DRAW_BAR_REVEAL_RANK')
			if (revealRank == 2 and item.rank)
			or (revealRank == 3 and item.rank2)
			or (CORE.CFG('DEBUG_SHOW_ATTACKER_ID') and item.id) then
				local text
				if CORE.CFG('DEBUG_SHOW_ATTACKER_ID') then
					text = string.format('%s', item.id)
				else
					if revealRank == 2 then
						text = string.format('%s', item.rank)
					elseif revealRank == 3 then
						text = string.format('%s', item.rank2)
					end
				end
				this.drawRichText(text, x + (3 * CORE.CFG('TABLE_SCALE')), y, CORE.COLOR('WHITE'), CORE.COLOR('BLACK'))
			end
		end
	else
		-- bar takes up the entire width of the table
		if CORE.CFG('DRAW_TABLE_BACKGROUND') then
			-- draw background
			this.draw_filled_rect(x, y, width, height, CORE.COLOR('BAR_BG'))
		end

		if CORE.CFG('DRAW_BAR_COLORBLOCK') then
			-- color block
			this.draw_filled_rect(x, y, colorBlockWidth, height, combatantColor)

			-- hr
			local revealRank = CORE.CFG('DRAW_BAR_REVEAL_RANK')
			if (revealRank == 2 and item.rank)
			or (revealRank == 3 and item.rank2)
			or (CORE.CFG('DEBUG_SHOW_ATTACKER_ID') and item.id) then
				local text
				if CORE.CFG('DEBUG_SHOW_ATTACKER_ID') then
					text = string.format('%s', item.id)
				else
					if revealRank == 2 then
						text = string.format('%s', item.rank)
					elseif revealRank == 3 then
						text = string.format('%s', item.rank2)
					end
				end
				this.drawRichText(text, x + (3 * CORE.CFG('TABLE_SCALE')), y, CORE.COLOR('WHITE'), CORE.COLOR('BLACK'))
			end
		end

		-- damage bar
		local damageBarWidth = (width - colorBlockWidth) * damageBarWidthMultiplier
		--draw.filled_rect(origin_x + colorBlockWidth, y, damageBarWidth, rowHeight, physicalColor)
		this.drawRichDamageBar(item, x + colorBlockWidth, y, damageBarWidth, height, physicalColor, elementalColor)
	end

	-- draw columns
	local text_x = x + colorBlockWidth + text_offset_x
	local text_y = y + text_offset_y

	-- now loop through defined columns
	for _,col in ipairs(STATE._CFG['TABLE_COLS']) do
		if col > 1 then
			local status, retval = pcall(this.drawReportItemColumn, item, col, text_x, text_y)
			if not status then
				this.drawRichText('ERR', text_x, text_y, CORE.COLOR('WHITE'), CORE.COLOR('BLACK'))
				CORE.log_debug(retval)
			end

			local colWidth = STATE._CFG['TABLE_COLS_WIDTH'][col] * CORE.CFG('TABLE_SCALE')

			text_x = text_x + colWidth
		end
	end

	if CORE.CFG('DRAW_BAR_OUTLINES') then
		-- draw outline
		this.draw_outline_rect(x, y, width, height, 2, CORE.COLOR('BAR_OUTLINE'))
	end
end

this.drawReport = function(index)
	if STATE.SCREEN_W == 0 or STATE.SCREEN_H == 0 then
		return
	end

	local report = STATE.DAMAGE_REPORTS[index]
	if not report then
		return
	end

	local dir = 1
	if CORE.CFG('TABLE_GROWS_UPWARD') then
		dir = -1
	end
	local scale = CORE.CFG('TABLE_SCALE') or 1.0
	local origin_x = CORE.getScreenXFromX(CORE.CFG('TABLE_X'))
	local origin_y = CORE.getScreenYFromY(CORE.CFG('TABLE_Y'))
	local tableWidth = CORE.CFG('TABLE_WIDTH') * scale
	local titleHeight = CORE.CFG('DRAW_TITLE_HEIGHT') * scale
	local headerHeight = CORE.CFG('DRAW_HEADER_HEIGHT') * scale
	local rowHeight = CORE.CFG('TABLE_ROWH') * scale
	local growDistance = (rowHeight + CORE.CFG('TABLE_ROW_PADDING')) * dir

	if CORE.CFG('TABLE_GROWS_UPWARD') then
		origin_y = origin_y - rowHeight
	end

	if CORE.CFG('DRAW_TITLE') then
		-- title bar
		if CORE.CFG('DRAW_TITLE_BACKGROUND') then
			-- title background
			this.draw_filled_rect(origin_x, origin_y, tableWidth, titleHeight, CORE.COLOR('TITLE_BG'))
		end

		if CORE.CFG('DRAW_TITLE_TEXT') then
			-- generate the title text

			-- get quest duration
			local totalSeconds = STATE.QUEST_DURATION
			local timeMinutes = math.floor(totalSeconds / 60.0)
			local timeSeconds = math.floor(totalSeconds % 60.0)

			-- use a fake duration in test mode
			if DATA.isInTestMode() then
				timeMinutes = 5
				timeSeconds = 37
			end

			local timeText = string.format("%d:%02.0f", timeMinutes, timeSeconds)
			local monsterText = ''

			if CORE.CFG('DRAW_TITLE_MONSTER') then
				monsterText = ' - '
				-- add monster names
				local monsterCount = 0
				for _,boss in pairs(STATE.REPORT_MONSTERS) do
					if monsterCount < 3 then
						if monsterCount > 0 then monsterText = monsterText .. ', ' end
						monsterText = monsterText .. string.format('%s', boss.name)
						if CORE.CFG('CHEAT_SHOW_MONSTER_HP') then
							local fmt = '%.0f'
							local pct = boss.hp.percent * 100
							if pct > 0 and pct < 1 then fmt = '%.1f' end
							monsterText = monsterText .. string.format(' (' .. fmt .. '%%)', pct)
						end
					end
					monsterCount = monsterCount + 1
				end

				if monsterCount > 3 then
					monsterText = monsterText .. ', etc...'
				elseif monsterCount == 0 then
					monsterText = monsterText .. 'No monsters selected'
				end
			end

			if CORE.CFG('DEBUG_SHOW_MISSING_DAMAGE') then
				monsterText = monsterText .. string.format(' (%.0f?)', report.missingDamage)
			end

			local titleText = timeText .. monsterText
			local offsetX = CORE.CFG('TABLE_HEADER_TEXT_OFFSET_X')
			this.drawRichText(titleText, origin_x + offsetX, origin_y, CORE.COLOR('TITLE_FG'), CORE.COLOR('BLACK'))
		end
	end

	if CORE.CFG('DRAW_HEADER') then
		-- find grow without row padding
		local grow = 0
		if CORE.CFG('DRAW_TITLE') then
			grow = titleHeight
			if CORE.CFG('TABLE_GROWS_UPWARD') then
				grow = grow * -1
			end
		end

		-- draw header row
		local x = origin_x + (4 * scale)
		local y = origin_y + grow

		if CORE.CFG('DRAW_HEADER_BACKGROUND') then
			-- background
			this.draw_filled_rect(origin_x, y, tableWidth, headerHeight, CORE.COLOR('TITLE_BG'))
		end

		if CORE.CFG('DRAW_BAR_COLORBLOCK') and CORE.CFG('DRAW_BAR_REVEAL_RANK') > 1 then
			local text
			if CORE.CFG('DEBUG_SHOW_ATTACKER_ID') then
				text = 'ID'
			elseif CORE.CFG('DRAW_BAR_REVEAL_RANK') == 2 then
				text = 'HR'
			else
				text = 'MR'
			end
			this.drawRichText(text, x, y, CORE.COLOR('GRAY'), CORE.COLOR('BLACK'))
		end

		local colorBlockWidth = 30 * scale
		if not CORE.CFG('DRAW_BAR_COLORBLOCK') then
			colorBlockWidth = 0
		end
		x = x + colorBlockWidth

		for _, value in ipairs(STATE._CFG['TABLE_COLS']) do
			if value > 1 then
				this.drawReportHeaderColumn(value, x, y)

				local colWidth = STATE._CFG['TABLE_COLS_WIDTH'][value] * scale
				x = x + colWidth
			end
		end
	end

	if #report.items == 0 then
		local colorBlockWidth = 20
		if not CORE.CFG('DRAW_BAR_COLORBLOCK') then
			colorBlockWidth = 0
		end
		local text_offset_x = CORE.CFG('TABLE_ROW_TEXT_OFFSET_X')
		local text_offset_y = CORE.CFG('TABLE_ROW_TEXT_OFFSET_Y')
		local x = origin_x + colorBlockWidth + 2 + text_offset_x
		local y = origin_y + text_offset_y
		if CORE.CFG('DRAW_TITLE') then
			y = y + titleHeight * dir -- skip title row
		end
		if CORE.CFG('DRAW_HEADER') then
			y = y + headerHeight * dir -- skip header row
		end

		this.draw_text('No data', x, y, CORE.COLOR('GRAY'))
	else
		-- draw report items
		local item_y = origin_y
		if CORE.CFG('DRAW_TITLE') then
			item_y = item_y + (titleHeight * dir) -- skip title row
		end
		if CORE.CFG('DRAW_HEADER') then
			item_y = item_y + (headerHeight * dir) -- skip header row
		end

		for _,item in ipairs(report.items) do
			-- Draw this report item if it's not hidden by this setting
			if not (CORE.CFG('HIDE_COMBINED_OTHERS') and item.id == STATE.COMBINE_ALL_OTHERS_ATTACKER_ID) then
				this.drawReportItem(item, origin_x, item_y, tableWidth, rowHeight)
				item_y = item_y + growDistance
			end
		end

		-- draw total
		if CORE.CFG('DRAW_TOTAL') then
			-- background
			if CORE.CFG('DRAW_TOTAL_BACKGROUND') then
				this.draw_filled_rect(origin_x, item_y, tableWidth, rowHeight, CORE.COLOR('TITLE_BG'))
			end

			local totalText = 'Total damage: ' .. report.totalDamage
			local offsetX = CORE.CFG('TABLE_TOTAL_TEXT_OFFSET_X')
			this.drawRichText(totalText, origin_x + offsetX, item_y, CORE.COLOR('TITLE_FG'), CORE.COLOR('BLACK'))
		end
	end
end

-- debug info stuff
this.drawDebugStats = function()
	--local kpiData         = MANAGER.QUEST:call("get_KpiData")
	--local playerPhysical  = kpiData:call("get_PlayerTotalAttackDamage")
	--local playerElemental = kpiData:call("get_PlayerTotalElementalAttackDamage")
	--local playerAilment   = kpiData:call("get_PlayerTotalStatusAilmentsDamage")
	--local playerDamage    = playerPhysical + playerElemental + playerAilment

	-- get player
	--local myPlayerId = MANAGER.PLAYER:call("getMasterPlayerID")
	--local myPlayer = MANAGER.PLAYER:call("getPlayer", myPlayerId)

	-- get enemy
	local bossCount = STATE.MANAGER.ENEMY:call("getBossEnemyCount")

	for i = 0, bossCount-1 do
		local bossEnemy = STATE.MANAGER.ENEMY:call("getBossEnemy", i)

		-- get this boss from the table
		local boss = STATE.LARGE_MONSTERS[bossEnemy]
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

		local isConditionDamageActive = bossEnemy:call("isConditionDamageActive", 4)
		if isConditionDamageActive then text = text .. ' conditioned'
		end

		this.debug_line(text)

	end

	--debug_line('')
	--debug_line(string.format('Total damage (KPI): %d', playerDamage))

	this.debug_line('')
	local report = STATE.DAMAGE_REPORTS[1]
	if report then
		for _,item in ipairs(report.items) do
			this.debug_line(item.name or 'no name')
			for type,counter in pairs(item.counters) do
				local total = DATA.getTotalDamageForDamageCounter(counter)
				if total > 0 then
					this.debug_line(string.format('%s\t\t%f',type, total))
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
this.dpsDraw = function()
	if STATE.DRAW_OVERLAY or STATE.DRAW_WINDOW_SETTINGS then
		-- draw the first report
		this.drawReport(1)

		if CORE.CFG('DEBUG_ENABLED') then
			STATE.DEBUG_Y = 0
			this.drawDebugStats()
		end
	end
end

return this
