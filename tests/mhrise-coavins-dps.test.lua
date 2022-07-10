math.randomseed(os.time())

require 'tests.mock'

package.path = package.path .. ';src/autorun/?.lua'

local STATE  = require 'mhrise-coavins-dps.state'
local CORE   = require 'mhrise-coavins-dps.core'
local ENUM   = require 'mhrise-coavins-dps.enum'
local DATA   = require 'mhrise-coavins-dps.data'
local REPORT = require 'mhrise-coavins-dps.report'

local function initializeMockBossMonster()
	-- automatically puts boss into cache
	local enemy = MockEnemy:create()
	DATA.initializeBossMonster(enemy)
	local boss = STATE.LARGE_MONSTERS[enemy]
	return boss
end

describe("mhrise-coavins-dps", function()
	setup(function()
		STATE.MANAGER.MESSAGE = MockMessageManager:create()
		STATE.MANAGER.QUEST = MockQuestManager:create()
	end)

	before_each(function()
		-- load default settings
		if not CORE.isProperlyInstalled() then
			return -- halt script
		end

		CORE.loadDefaultConfig()

		CORE.cleanUpData('before test')

		CORE.SetQuestDuration(0.0)

		-- all damage types enabled
		for _,type in pairs(ENUM.DAMAGE_TYPES) do
			CORE.AddDamageTypeToReport(type)
		end

		CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
		CORE.SetCFG('SHOW_MISSING_DAMAGE', false)
		CORE.SetCFG('ADD_TARGETS_TO_REPORT', false)
	end)

	describe("report", function()

		it("includes condition when it should", function()
			-- config
			CORE.SetCFG('CONDITION_LIKE_DAMAGE', true)

			local r = REPORT.initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = DATA.initializeDamageSource(1)
			s[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s[1].counters['PlayerWeapon'].physical = 100
			s[1].counters['PlayerWeapon'].elemental = 200
			s[1].counters['PlayerWeapon'].condition = 400

			b.damageSources = s

			REPORT.mergeBossIntoReport(r, b)

			local expected = 700
			local actual = r.items[1].total

			assert.is_equal(expected, actual)

		end)

		it("doesn't include condition when it shouldn't", function()
			-- config
			CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)

			local r = REPORT.initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = DATA.initializeDamageSource(1)
			s[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s[1].counters['PlayerWeapon'].physical = 100
			s[1].counters['PlayerWeapon'].elemental = 200
			s[1].counters['PlayerWeapon'].condition = 400

			b.damageSources = s

			REPORT.mergeBossIntoReport(r, b)

			local expected = 300
			local actual = r.items[1].total

			assert.is_equal(expected, actual)

		end)

		it("merges a boss correctly", function()
			local r = REPORT.initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = DATA.initializeDamageSource(1)
			s[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s[1].counters['PlayerWeapon'].physical = 100

			b.damageSources = s

			local actual = 100

			REPORT.mergeBossIntoReport(r, b)

			assert.is_equal(actual, r.totalDamage)

		end)

		it("merges two bosses correctly", function()
			local r = REPORT.initializeReport()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			local s1 = {}
			s1[1] = DATA.initializeDamageSource(1)
			s1[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s1[1].counters['PlayerWeapon'].physical = 100
			s1[1].counters['PlayerWeapon'].elemental = 200
			s1[1].counters['PlayerWeapon'].condition = 400

			boss1.damageSources = s1

			local s2 = {}
			s2[1] = DATA.initializeDamageSource(1)
			s2[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s2[1].counters['PlayerWeapon'].physical = 800
			s2[1].counters['PlayerWeapon'].elemental = 1600
			s2[1].counters['PlayerWeapon'].condition = 3200

			boss2.damageSources = s2

			REPORT.mergeBossIntoReport(r, boss1)
			REPORT.mergeBossIntoReport(r, boss2)

			local expected = 100 + 200 + 800 + 1600
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)

		it("merges three bosses correctly", function()
			local r = REPORT.initializeReport()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()
			local boss3 = initializeMockBossMonster()

			local s1 = {}
			s1[1] = DATA.initializeDamageSource(1)
			s1[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s1[1].counters['PlayerWeapon'].physical = 1
			s1[1].counters['PlayerWeapon'].elemental = 2
			s1[1].counters['PlayerWeapon'].condition = 4

			boss1.damageSources = s1

			local s2 = {}
			s2[1] = DATA.initializeDamageSource(1)
			s2[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s2[1].counters['PlayerWeapon'].physical = 8
			s2[1].counters['PlayerWeapon'].elemental = 16
			s2[1].counters['PlayerWeapon'].condition = 32

			boss2.damageSources = s2

			local s3 = {}
			s3[1] = DATA.initializeDamageSource(1)
			s3[1].counters['PlayerWeapon'] = DATA.initializeDamageCounter()
			s3[1].counters['Otomo'] = DATA.initializeDamageCounter()

			boss3.damageSources = s3

			REPORT.mergeBossIntoReport(r, boss1)
			REPORT.mergeBossIntoReport(r, boss2)
			REPORT.mergeBossIntoReport(r, boss3)

			local expected = 1 + 2 + 8 + 16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)

		it("generates from boss cache correctly", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 100
			info.elementalAmt = 200
			info.conditionAmt = 400
			DATA.addDamageToBoss(boss, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 0
			info.elementalAmt = 800
			info.conditionAmt = 0
			DATA.addDamageToBoss(boss, 2, 0, info)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(r.totalDamage, 1100)
			assert.is_equal(r.topDamage, 800)
		end)

		it("includes otomo when they are merged", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
			CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', true)

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 1
			info.elementalAmt = 2
			info.conditionAmt = 4
			DATA.addDamageToBoss(boss, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 8
			info.elementalAmt = 16
			info.conditionAmt = 32
			DATA.addDamageToBoss(boss, 1, STATE.OTOMO_ATTACKER_TYPE_ID, info)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 1+2+8+16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("includes otomo when they are unmerged", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
			CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
			CORE.SetReportOtomo(true)

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 1
			info.elementalAmt = 2
			info.conditionAmt = 4
			DATA.addDamageToBoss(boss, 0, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 8
			info.elementalAmt = 16
			info.conditionAmt = 32
			DATA.addDamageToBoss(boss, 0, STATE.OTOMO_ATTACKER_TYPE_ID, info)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 1+2+8+16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("excludes otomo when they are filtered out", function()
			-- set config
			CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
			CORE.SetReportOtomo(false)

			local boss = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 1
			info.elementalAmt = 2
			DATA.addDamageToBoss(boss, 0, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 8
			info.elementalAmt = 16
			DATA.addDamageToBoss(boss, 0, STATE.OTOMO_ATTACKER_TYPE_ID, info)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 1+2
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("generates a full party correctly (merged pets)", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
			CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', true)

			local damagesPhysical = {}
			table.insert(damagesPhysical, 100)
			table.insert(damagesPhysical, 105)
			table.insert(damagesPhysical, 110)
			table.insert(damagesPhysical, 115)
			table.insert(damagesPhysical, 120)
			table.insert(damagesPhysical, 125)

			local damagesElemental = {}
			table.insert(damagesElemental, 200)
			table.insert(damagesElemental, 205)
			table.insert(damagesElemental, 210)
			table.insert(damagesElemental, 215)
			table.insert(damagesElemental, 220)
			table.insert(damagesElemental, 225)

			local damagesCondition = {}
			table.insert(damagesCondition, 300)
			table.insert(damagesCondition, 305)
			table.insert(damagesCondition, 310)
			table.insert(damagesCondition, 315)
			table.insert(damagesCondition, 320)
			table.insert(damagesCondition, 325)

			-- per attacker
			-- 1950 damage
			-- 3825 including condition

			for index,_ in ipairs(damagesPhysical) do
				local info = DATA.initializeDamageInfo()
				info.physicalAmt = damagesPhysical[index]
				info.elementalAmt = damagesElemental[index]
				info.conditionAmt = damagesCondition[index]
				DATA.addDamageToBoss(boss, 0, 0, info)
				DATA.addDamageToBoss(boss, 1, 0, info)
				DATA.addDamageToBoss(boss, 2, 0, info)
				DATA.addDamageToBoss(boss, 3, 0, info)
				DATA.addDamageToBoss(boss, 0, STATE.OTOMO_ATTACKER_TYPE_ID, info)
				DATA.addDamageToBoss(boss, 1, STATE.OTOMO_ATTACKER_TYPE_ID, info)
				DATA.addDamageToBoss(boss, 2, STATE.OTOMO_ATTACKER_TYPE_ID, info)
				DATA.addDamageToBoss(boss, 3, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			end

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(1950 * 8, r.totalDamage)
			assert.is_equal(1950 * 2, r.topDamage)

			-- and also with condition included
			CORE.SetCFG('CONDITION_LIKE_DAMAGE', true)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(3825 * 8, r.totalDamage)
			assert.is_equal(3825 * 2, r.topDamage)
		end)

	end)

	it("doesn't retain information from old reports", function()
		local boss = initializeMockBossMonster()

		local info = DATA.initializeDamageInfo()
		info.physicalAmt = 100
		DATA.addDamageToBoss(boss, 1, 0, info)

		REPORT.generateReport(STATE.REPORT_MONSTERS)
		local r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(r.totalDamage, 100)
		assert.is_equal(r.topDamage, 100)

		REPORT.generateReport(STATE.REPORT_MONSTERS)
		r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(r.totalDamage, 100)
		assert.is_equal(r.topDamage, 100)
	end)

	it("generates a full party correctly (unmerged pets)", function()
		local boss = initializeMockBossMonster()

		local damagesPhysical = {}
		table.insert(damagesPhysical, 100)
		table.insert(damagesPhysical, 105)
		table.insert(damagesPhysical, 110)
		table.insert(damagesPhysical, 115)
		table.insert(damagesPhysical, 120)
		table.insert(damagesPhysical, 125)

		local damagesElemental = {}
		table.insert(damagesElemental, 200)
		table.insert(damagesElemental, 205)
		table.insert(damagesElemental, 210)
		table.insert(damagesElemental, 215)
		table.insert(damagesElemental, 220)
		table.insert(damagesElemental, 225)

		local damagesCondition = {}
		table.insert(damagesCondition, 300)
		table.insert(damagesCondition, 305)
		table.insert(damagesCondition, 310)
		table.insert(damagesCondition, 315)
		table.insert(damagesCondition, 320)
		table.insert(damagesCondition, 325)

		-- per attacker
		-- 1950 damage
		-- 3825 including condition

		for index,_ in ipairs(damagesPhysical) do
			local info = DATA.initializeDamageInfo()
			info.physicalAmt = damagesPhysical[index]
			info.elementalAmt = damagesElemental[index]
			info.conditionAmt = damagesCondition[index]
			DATA.addDamageToBoss(boss, 0, 0, info)
			DATA.addDamageToBoss(boss, 1, 0, info)
			DATA.addDamageToBoss(boss, 2, 0, info)
			DATA.addDamageToBoss(boss, 3, 0, info)
			DATA.addDamageToBoss(boss, 0, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 1, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 2, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 3, STATE.OTOMO_ATTACKER_TYPE_ID, info)
		end

		CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
		CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
		CORE.SetReportOtomo(true)

		REPORT.generateReport(STATE.REPORT_MONSTERS)

		local r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(1950 * 8, r.totalDamage)
		assert.is_equal(1950, r.topDamage)

		CORE.SetCFG('CONDITION_LIKE_DAMAGE', true)

		REPORT.generateReport(STATE.REPORT_MONSTERS)

		r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(3825 * 8, r.totalDamage)
		assert.is_equal(3825, r.topDamage)
	end)

	it("counts random data correctly", function()
		local boss = initializeMockBossMonster()

		local damagesPhysical = {}
		local damagesElemental = {}
		local damagesCondition = {}

		local expected = 0.0
		local expectedCondition = 0.0

		for _=1,10,1 do
			local amt = math.random(1,1000)
			table.insert(damagesPhysical, amt)
			expected = expected + amt
			amt = math.random(1,1000)
			table.insert(damagesElemental, amt)
			expected = expected + amt
			amt = math.random(1,1000)
			table.insert(damagesCondition, amt)
			expectedCondition = expectedCondition + amt
		end

		for index,_ in ipairs(damagesPhysical) do
			local info = DATA.initializeDamageInfo()
			info.physicalAmt = damagesPhysical[index]
			info.elementalAmt = damagesElemental[index]
			info.conditionAmt = damagesCondition[index]
			DATA.addDamageToBoss(boss, 0, 0, info)
			DATA.addDamageToBoss(boss, 1, 0, info)
			DATA.addDamageToBoss(boss, 2, 0, info)
			DATA.addDamageToBoss(boss, 3, 0, info)
			DATA.addDamageToBoss(boss, 0, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 1, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 2, STATE.OTOMO_ATTACKER_TYPE_ID, info)
			DATA.addDamageToBoss(boss, 3, STATE.OTOMO_ATTACKER_TYPE_ID, info)
		end

		expected = expected * 8
		expectedCondition = expectedCondition * 8

		CORE.SetCFG('CONDITION_LIKE_DAMAGE', false)
		CORE.SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
		CORE.SetReportOtomo(true)

		REPORT.generateReport(STATE.REPORT_MONSTERS)

		local r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(expected, r.totalDamage)

		CORE.SetCFG('CONDITION_LIKE_DAMAGE', true)

		REPORT.generateReport(STATE.REPORT_MONSTERS)

		r = STATE.DAMAGE_REPORTS[1]

		assert.is_equal(expected + expectedCondition, r.totalDamage)
	end)

	describe("dps", function()

		it("is calculated correctly for one boss", function()
			local boss = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 750
			info.elementalAmt = 250
			DATA.addDamageToBoss(boss, 1, 0, info)

			boss.timeline[0] = true
			boss.timeline[100] = false

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 10.0
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly for two bosses", function()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 750
			info.elementalAmt = 250
			DATA.addDamageToBoss(boss1, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 250
			info.elementalAmt = 250
			DATA.addDamageToBoss(boss2, 1, 0, info)

			boss1.timeline[0] = true
			boss1.timeline[100] = false
			boss2.timeline[50] = true
			boss2.timeline[150] = false

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = (750+250+250+250) / 150.0
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly for three bosses", function()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()
			local boss3 = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 750
			info.elementalAmt = 250
			DATA.addDamageToBoss(boss1, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 250
			info.elementalAmt = 250
			DATA.addDamageToBoss(boss2, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 616
			info.elementalAmt = 19842
			DATA.addDamageToBoss(boss3, 1, 0, info)

			boss1.timeline[0] = true
			boss1.timeline[100] = false
			boss2.timeline[100] = true
			boss2.timeline[110] = false
			boss3.timeline[200] = true
			boss3.timeline[205] = false

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = (750 + 250 + 250 + 250 + 616 + 19842) / (100 + 10 + 5)
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly while still in combat", function()
			-- config
			local currentTime = 70
			local startTime = 50
			CORE.SetQuestDuration(currentTime)

			local boss1 = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 100
			DATA.addDamageToBoss(boss1, 1, 0, info)

			boss1.timeline[startTime] = true

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r= STATE.DAMAGE_REPORTS[1]

			local expected = 100 / (currentTime - startTime)
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly while still in combat but one monster left", function()
			-- config
			CORE.SetQuestDuration(100)

			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			local info = DATA.initializeDamageInfo()
			info.physicalAmt = 100
			DATA.addDamageToBoss(boss1, 1, 0, info)
			info = DATA.initializeDamageInfo()
			info.physicalAmt = 200
			DATA.addDamageToBoss(boss1, 1, 0, info)

			boss1.timeline[60] = true
			boss2.timeline[80] = true
			boss1.timeline[90] = false

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r= STATE.DAMAGE_REPORTS[1]

			local expected = 300 / 40
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

	end)

end)
