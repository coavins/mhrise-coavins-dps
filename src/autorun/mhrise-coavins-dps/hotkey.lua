local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'
local REPORT = require 'mhrise-coavins-dps.report'

local this = {}

this.updateHeldHotkeyModifiers = function()
	for key,_ in pairs(ENUM.ENUM_KEYBOARD_MODIFIERS) do
		if not STATE.CURRENTLY_HELD_MODIFIERS[key] and STATE.MANAGER.KEYBOARD:call("getTrg", key) then
			STATE.CURRENTLY_HELD_MODIFIERS[key] = true
		elseif STATE.CURRENTLY_HELD_MODIFIERS[key] and STATE.MANAGER.KEYBOARD:call("getRelease", key) then
			STATE.CURRENTLY_HELD_MODIFIERS[key] = false
		end
	end
end

this.checkHotkeyActivated = function(name)
	local hotkey = CORE.HOTKEY(name)
	if not hotkey.KEY then
		return
	end

	-- we pressed our hotkey and did not just assign it
	if not STATE.ASSIGNED_HOTKEY_THIS_FRAME and STATE.MANAGER.KEYBOARD:call("getTrg", hotkey.KEY) then
		-- if correct modifiers are not held, return
		for key,needsHeld in pairs(hotkey.MODIFIERS) do
			if STATE.CURRENTLY_HELD_MODIFIERS[key] ~= needsHeld then
				if STATE.CURRENTLY_HELD_MODIFIERS[key] == true then
					return
				elseif STATE.CURRENTLY_HELD_MODIFIERS[key] == false then
					return
				elseif not STATE.CURRENTLY_HELD_MODIFIERS[key] then
					return
				end
			end
		end

		-- perform hotkey action
		if name == 'TOGGLE_OVERLAY' then
			STATE.DRAW_OVERLAY = not STATE.DRAW_OVERLAY
		elseif name == 'MONSTER_NEXT' then
			STATE.ORDERED_MONSTERS_SELECTED = STATE.ORDERED_MONSTERS_SELECTED + 1
			if STATE.ORDERED_MONSTERS_SELECTED > #STATE.ORDERED_MONSTERS then
				STATE.ORDERED_MONSTERS_SELECTED = 0
			end
			if STATE.ORDERED_MONSTERS_SELECTED == 0 then
				CORE.resetReportMonsters()
			else
				-- put next monster in the report
				CORE.makeTableEmpty(STATE.REPORT_MONSTERS)
				local enemy = STATE.ORDERED_MONSTERS[STATE.ORDERED_MONSTERS_SELECTED]
				local boss = STATE.LARGE_MONSTERS[enemy]
				CORE.AddMonsterToReport(enemy, boss)
			end
			REPORT.generateReport(STATE.REPORT_MONSTERS)
		elseif name == 'MONSTER_PREV' then
			STATE.ORDERED_MONSTERS_SELECTED = STATE.ORDERED_MONSTERS_SELECTED - 1
			if STATE.ORDERED_MONSTERS_SELECTED < 0 then
				STATE.ORDERED_MONSTERS_SELECTED = #STATE.ORDERED_MONSTERS
			end
			if STATE.ORDERED_MONSTERS_SELECTED == 0 then
				CORE.resetReportMonsters()
			else
				-- put next monster in the report
				CORE.makeTableEmpty(STATE.REPORT_MONSTERS)
				local enemy = STATE.ORDERED_MONSTERS[STATE.ORDERED_MONSTERS_SELECTED]
				local boss = STATE.LARGE_MONSTERS[enemy]
				CORE.AddMonsterToReport(enemy, boss)
			end
			REPORT.generateReport(STATE.REPORT_MONSTERS)
		end
	end
end

this.registerWaitingHotkeys = function()
	if STATE.HOTKEY_WAITING_TO_REGISTER then
		local name = STATE.HOTKEY_WAITING_TO_REGISTER

		for key,_ in pairs(ENUM.ENUM_KEYBOARD_KEY) do
			-- key released
			if ENUM.ENUM_KEYBOARD_MODIFIERS[key] and STATE.MANAGER.KEYBOARD:call("getRelease", key) then
				log.info(string.format('unregister modifier %d', key))
				STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER[key] = false
			end
			-- key pressed
			if STATE.MANAGER.KEYBOARD:call("getTrg", key) then
				if ENUM.ENUM_KEYBOARD_MODIFIERS[key] then
					log.info(string.format('register modifier %d', key))
					STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER[key] = true
				else
					-- pressed a valid hotkey
					log.info(string.format('register hotkey %d', key))
					local hotkey = CORE.HOTKEY(name)
					-- register it
					hotkey.KEY = key
					-- register modifiers
					-- first, require NO modifiers be held
					for modifierKey,_ in pairs(ENUM.ENUM_KEYBOARD_MODIFIERS) do
						hotkey.MODIFIERS[modifierKey] = false
					end
					-- then change requirement for any modifiers the user did actually want
					for modifierKey,needsHeld in pairs(STATE.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER) do
						hotkey.MODIFIERS[modifierKey] = needsHeld
					end
					-- clear flags
					STATE.HOTKEY_WAITING_TO_REGISTER = false
					-- remember that we assigned this frame so we don't actually toggle the overlay
					STATE.ASSIGNED_HOTKEY_THIS_FRAME = true
				end
			end
		end
	end
end

return this
