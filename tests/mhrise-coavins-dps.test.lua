---@diagnostic disable: undefined-global
_G._UNIT_TESTING = true
math.randomseed(os.time())

require 'tests/mock'
require 'tests/mock_json'
require 'tests/mock_fs'
require 'tests/mock_d2d'
require 'src/autorun/mhrise-coavins-dps'

local function initializeMockBossMonster()
	-- automatically puts boss into cache
	local enemy = MockEnemy:create()
	initializeBossMonster(enemy)
	local boss = LARGE_MONSTERS[enemy]
	return boss
end

describe("mhrise-coavins-dps", function()
	setup(function()
		MANAGER.MESSAGE = MockMessageManager:create()
	end)

	before_each(function()
		cleanUpData()

		SetQuestDuration(0.0)

		-- all attacker types enabled
		for _,type in pairs(ATTACKER_TYPES) do
			AddAttackerTypeToReport(type)
		end

		SetCFG('CONDITION_LIKE_DAMAGE', false)
	end)

	describe("boss", function()

		it("works through damage hook with one attacker", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 200, 400)

			local sum = sumDamageSourcesList(boss.damageSources)
			assert.is_equal(100, sum.physical)
			assert.is_equal(200, sum.elemental)
			assert.is_equal(400, sum.condition)
			assert.is_equal(300, sum.total)
		end)

		it("works through damage hook with a full party of four", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 0, 0, 101, 202, 403)
			addDamageToBoss(boss, 1, 0, 201, 402, 803)
			addDamageToBoss(boss, 2, 0, 401, 802, 103)
			addDamageToBoss(boss, 3, 0, 801, 102, 203)

			local sum = sumDamageSourcesList(boss.damageSources)

			assert.is_equal(101 + 201 + 401 + 801, sum.physical)
			assert.is_equal(202 + 402 + 802 + 102, sum.elemental)
			assert.is_equal(403 + 803 + 103 + 203, sum.condition)
			assert.is_equal(1504 + 1508, sum.total)
		end)

	end)

	describe("biggest hit", function()

		it("counts correctly", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 500)
			addDamageToBoss(boss, 1, 0, 400)
			addDamageToBoss(boss, 1, 0, 300)
			addDamageToBoss(boss, 1, 0, 200)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = 500
			local actual = r.items[1].maxHit

			assert.is_equal(expected, actual)
		end)

	end)

	describe("buildup", function()

		it("gets set on boss", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 50, 5)

			local expected = 50
			local actual = boss.ailment.buildup[5][1]

			assert.is_equal(expected, actual)
		end)

		it("accumulates on boss", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 1, 5)
			addDamageToBoss(boss, 1, 0, 100, 0, 2, 5)
			addDamageToBoss(boss, 1, 0, 100, 0, 4, 5)

			local expected = 7
			local actual = boss.ailment.buildup[5][1]

			assert.is_equal(expected, actual)
		end)

		it("accumulates on boss for multiple attackers", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 1, 5)
			addDamageToBoss(boss, 2, 0, 100, 0, 2, 5)
			addDamageToBoss(boss, 654, 0, 100, 0, 4, 5)

			assert.is_equal(1, boss.ailment.buildup[5][1])
			assert.is_equal(2, boss.ailment.buildup[5][2])
			assert.is_equal(4, boss.ailment.buildup[5][654])
		end)

	end)

	describe("ailment damage", function()

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			addDamageToBoss(boss, 2, 0, 100, 0, 100, 5)

			calculateAilmentContrib(boss, 5)

			assert.is_equal(0.5, boss.ailment.share[5][1])
			assert.is_equal(0.5, boss.ailment.share[5][2])
		end)

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			addDamageToBoss(boss, 2, 0, 100, 0, 100, 5)
			addDamageToBoss(boss, 3, 0, 100, 0, 200, 5)

			calculateAilmentContrib(boss, 5)

			assert.is_equal(0.25, boss.ailment.share[5][1])
			assert.is_equal(0.25, boss.ailment.share[5][2])
			assert.is_equal(0.5, boss.ailment.share[5][3])
		end)

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			addDamageToBoss(boss, 2, 0, 100, 0, 100, 5)
			addDamageToBoss(boss, 3, 0, 100, 0, 200, 5)
			addDamageToBoss(boss, 4, 0, 100, 0, 400, 5)

			calculateAilmentContrib(boss, 5)

			assert.is_equal(0.125, boss.ailment.share[5][1])
			assert.is_equal(0.125, boss.ailment.share[5][2])
			assert.is_equal(0.25, boss.ailment.share[5][3])
			assert.is_equal(0.5, boss.ailment.share[5][4])
		end)

	end)

	describe("damage counter", function()

		it("is empty when initialized", function()
			local c = initializeDamageCounter()

			assert.is_equal(c.physical, 0)
			assert.is_equal(c.elemental, 0)
			assert.is_equal(c.condition, 0)

			local total = getTotalDamageForDamageCounter(c)

			assert.is_equal(0, total)
		end)

		it("merges correctly", function ()
			local a = initializeDamageCounter()
			local b = initializeDamageCounter()
			local result = initializeDamageCounter()

			a.physical = 100
			b.physical = 100
			result.physical = 200

			a.elemental = 405
			b.elemental = 5
			result.elemental = 410

			a.condition = 999
			b.condition = 3
			result.condition = 1002

			local actual = mergeDamageCounters(a,b)

			assert.are_same(result, actual)
		end)

		it("shows the right total", function()
			local c = initializeDamageCounter()

			c.physical = 100
			c.elemental = 212
			c.condition = 323

			local actual = getTotalDamageForDamageCounter(c)

			assert.is_equal(100 + 212, actual)
		end)

	end)

	describe("damage source", function()

		it("is empty when initialized", function()
			local s = initializeDamageSource()

			assert.is_nil(s.id)
		end)

	end)

	describe("report", function()

		it("includes condition when it should", function()
			-- config
			SetCFG('CONDITION_LIKE_DAMAGE', true)

			local r = initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = initializeDamageSource(1)
			s[1].counters['weapon'] = initializeDamageCounter()
			s[1].counters['weapon'].physical = 100
			s[1].counters['weapon'].elemental = 200
			s[1].counters['weapon'].condition = 400

			b.damageSources = s

			mergeBossIntoReport(r, b)

			local expected = 700
			local actual = r.items[1].total

			assert.is_equal(expected, actual)

		end)

		it("doesn't include condition when it shouldn't", function()
			-- config
			SetCFG('CONDITION_LIKE_DAMAGE', false)

			local r = initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = initializeDamageSource(1)
			s[1].counters['weapon'] = initializeDamageCounter()
			s[1].counters['weapon'].physical = 100
			s[1].counters['weapon'].elemental = 200
			s[1].counters['weapon'].condition = 400

			b.damageSources = s

			mergeBossIntoReport(r, b)

			local expected = 300
			local actual = r.items[1].total

			assert.is_equal(expected, actual)

		end)

		it("merges a boss correctly", function()
			local r = initializeReport()
			local b = initializeMockBossMonster()

			local s = {}
			s[1] = initializeDamageSource(1)
			s[1].counters['weapon'] = initializeDamageCounter()
			s[1].counters['weapon'].physical = 100

			b.damageSources = s

			local actual = 100

			mergeBossIntoReport(r, b)

			assert.is_equal(actual, r.totalDamage)

		end)

		it("merges two bosses correctly", function()
			local r = initializeReport()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			local s1 = {}
			s1[1] = initializeDamageSource(1)
			s1[1].counters['weapon'] = initializeDamageCounter()
			s1[1].counters['weapon'].physical = 100
			s1[1].counters['weapon'].elemental = 200
			s1[1].counters['weapon'].condition = 400

			boss1.damageSources = s1

			local s2 = {}
			s2[1] = initializeDamageSource(1)
			s2[1].counters['weapon'] = initializeDamageCounter()
			s2[1].counters['weapon'].physical = 800
			s2[1].counters['weapon'].elemental = 1600
			s2[1].counters['weapon'].condition = 3200

			boss2.damageSources = s2

			mergeBossIntoReport(r, boss1)
			mergeBossIntoReport(r, boss2)

			local expected = 100 + 200 + 800 + 1600
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)

		it("merges three bosses correctly", function()
			local r = initializeReport()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()
			local boss3 = initializeMockBossMonster()

			local s1 = {}
			s1[1] = initializeDamageSource(1)
			s1[1].counters['weapon'] = initializeDamageCounter()
			s1[1].counters['weapon'].physical = 1
			s1[1].counters['weapon'].elemental = 2
			s1[1].counters['weapon'].condition = 4

			boss1.damageSources = s1

			local s2 = {}
			s2[1] = initializeDamageSource(1)
			s2[1].counters['weapon'] = initializeDamageCounter()
			s2[1].counters['weapon'].physical = 8
			s2[1].counters['weapon'].elemental = 16
			s2[1].counters['weapon'].condition = 32

			boss2.damageSources = s2

			local s3 = {}
			s3[1] = initializeDamageSource(1)
			s3[1].counters['weapon'] = initializeDamageCounter()
			s3[1].counters['otomo'] = initializeDamageCounter()

			boss3.damageSources = s3

			mergeBossIntoReport(r, boss1)
			mergeBossIntoReport(r, boss2)
			mergeBossIntoReport(r, boss3)

			local expected = 1 + 2 + 8 + 16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)

		it("generates from boss cache correctly", function()
			local boss = initializeMockBossMonster()

			SetCFG('CONDITION_LIKE_DAMAGE', false)

			addDamageToBoss(boss, 1, 0, 100, 200, 400)
			addDamageToBoss(boss, 2, 0, 0, 800, 0)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			assert.is_equal(r.totalDamage, 1100)
			assert.is_equal(r.topDamage, 800)
		end)

		it("includes otomo when they are merged", function()
			local boss = initializeMockBossMonster()

			SetCFG('CONDITION_LIKE_DAMAGE', false)
			SetCFG('COMBINE_OTOMO_WITH_HUNTER', true)

			addDamageToBoss(boss, 1, 0, 1, 2, 4)
			addDamageToBoss(boss, 1, 19, 8, 16, 32)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = 1+2+8+16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("includes otomo when they are unmerged", function()
			local boss = initializeMockBossMonster()

			SetCFG('CONDITION_LIKE_DAMAGE', false)
			SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
			SetReportOtomo(true)

			addDamageToBoss(boss, 0, 0, 1, 2, 4)
			addDamageToBoss(boss, 0, 19, 8, 16, 32)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = 1+2+8+16
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("excludes otomo when they are filtered out", function()
			-- set config
			SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
			SetReportOtomo(false)

			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 0, 0, 1, 2)
			addDamageToBoss(boss, 0, 19, 8, 16)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = 1+2
			local actual = r.totalDamage

			assert.is_equal(expected, actual)
		end)

		it("generates a full party correctly (merged pets)", function()
			local boss = initializeMockBossMonster()

			SetCFG('CONDITION_LIKE_DAMAGE', false)
			SetCFG('COMBINE_OTOMO_WITH_HUNTER', true)

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
				addDamageToBoss(boss, 0, 0,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 1, 0,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 2, 0,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 3, 0,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 0, 19,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 1, 19,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 2, 19,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
				addDamageToBoss(boss, 3, 19,
				damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			end

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			assert.is_equal(1950 * 8, r.totalDamage)
			assert.is_equal(1950 * 2, r.topDamage)

			-- and also with condition included
			SetCFG('CONDITION_LIKE_DAMAGE', true)

			generateReport(REPORT_MONSTERS)

			r = DAMAGE_REPORTS[1]

			assert.is_equal(3825 * 8, r.totalDamage)
			assert.is_equal(3825 * 2, r.topDamage)
		end)

	end)

	it("doesn't retain information from old reports", function()
		local boss = initializeMockBossMonster()

		addDamageToBoss(boss, 1, 0, 100)

		generateReport(REPORT_MONSTERS)
		local r = DAMAGE_REPORTS[1]

		assert.is_equal(r.totalDamage, 100)
		assert.is_equal(r.topDamage, 100)

		generateReport(REPORT_MONSTERS)
		r = DAMAGE_REPORTS[1]

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
			addDamageToBoss(boss, 0, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 1, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 2, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 3, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 0, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 1, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 2, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 3, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
		end

		SetCFG('CONDITION_LIKE_DAMAGE', false)
		SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
		SetReportOtomo(true)

		generateReport(REPORT_MONSTERS)

		local r = DAMAGE_REPORTS[1]

		assert.is_equal(1950 * 8, r.totalDamage)
		assert.is_equal(1950, r.topDamage)

		SetCFG('CONDITION_LIKE_DAMAGE', true)

		generateReport(REPORT_MONSTERS)

		r = DAMAGE_REPORTS[1]

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
			addDamageToBoss(boss, 0, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 1, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 2, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 3, 0,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 0, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 1, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 2, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
			addDamageToBoss(boss, 3, 19,
			damagesPhysical[index], damagesElemental[index], damagesCondition[index])
		end

		expected = expected * 8
		expectedCondition = expectedCondition * 8

		SetCFG('CONDITION_LIKE_DAMAGE', false)
		SetCFG('COMBINE_OTOMO_WITH_HUNTER', false)
		SetReportOtomo(true)

		generateReport(REPORT_MONSTERS)

		local r = DAMAGE_REPORTS[1]

		assert.is_equal(expected, r.totalDamage)

		SetCFG('CONDITION_LIKE_DAMAGE', true)

		generateReport(REPORT_MONSTERS)

		r = DAMAGE_REPORTS[1]

		assert.is_equal(expected + expectedCondition, r.totalDamage)
	end)

	describe("dps", function()

		it("is calculated correctly for one boss", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 750, 250, 0)

			boss.timeline[0] = true
			boss.timeline[100] = false

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = 10.0
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly for two bosses", function()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			addDamageToBoss(boss1, 1, 0, 750, 250, 0)
			addDamageToBoss(boss2, 1, 0, 250, 250, 0)

			boss1.timeline[0] = true
			boss1.timeline[100] = false
			boss2.timeline[50] = true
			boss2.timeline[150] = false

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = (750+250+250+250) / 150.0
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly for three bosses", function()
			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()
			local boss3 = initializeMockBossMonster()

			addDamageToBoss(boss1, 1, 0, 750, 250, 0)
			addDamageToBoss(boss2, 1, 0, 250, 250, 0)
			addDamageToBoss(boss3, 1, 0, 616, 19842, 0)

			boss1.timeline[0] = true
			boss1.timeline[100] = false
			boss2.timeline[100] = true
			boss2.timeline[110] = false
			boss3.timeline[200] = true
			boss3.timeline[205] = false

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			local expected = (750 + 250 + 250 + 250 + 616 + 19842) / (100 + 10 + 5)
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly while still in combat", function()
			-- config
			local currentTime = 70
			local startTime = 50
			SetQuestDuration(currentTime)

			local boss1 = initializeMockBossMonster()

			addDamageToBoss(boss1, 1, 0, 100, 0, 0)

			boss1.timeline[startTime] = true

			generateReport(REPORT_MONSTERS)

			local r= DAMAGE_REPORTS[1]

			local expected = 100 / (currentTime - startTime)
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

		it("is calculated correctly while still in combat but one monster left", function()
			-- config
			SetQuestDuration(100)

			local boss1 = initializeMockBossMonster()
			local boss2 = initializeMockBossMonster()

			addDamageToBoss(boss1, 1, 0, 100, 0, 0)
			addDamageToBoss(boss1, 1, 0, 200, 0, 0)

			boss1.timeline[60] = true
			boss2.timeline[80] = true
			boss1.timeline[90] = false

			generateReport(REPORT_MONSTERS)

			local r= DAMAGE_REPORTS[1]

			local expected = 300 / 40
			local actual = r.items[1].dps.report

			assert.is_equal(expected, actual)
		end)

	end)

end)
