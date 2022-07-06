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

describe("data:", function()
	setup(function()
		STATE.MANAGER.MESSAGE = MockMessageManager:create()
	end)

	before_each(function()
		-- load default settings
		if not CORE.loadDefaultConfig() then
			return -- halt script
		end

		CORE.cleanUpData('before test')

		CORE.SetQuestDuration(0.0)

		-- all damage types enabled
		for _,type in pairs(ENUM.DAMAGE_TYPES) do
			CORE.AddDamageTypeToReport(type)
		end
	end)

	describe("boss", function()

		it("works through damage hook with one attacker", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 200, 400)

			local sum = REPORT.sumDamageSourcesList(boss.damageSources)
			assert.is_equal(100, sum.physical)
			assert.is_equal(200, sum.elemental)
			assert.is_equal(400, sum.condition)
			assert.is_equal(300, sum.total)
		end)

		it("works through damage hook with a full party of four", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 0, 0, 101, 202, 403)
			DATA.addDamageToBoss(boss, 1, 0, 201, 402, 803)
			DATA.addDamageToBoss(boss, 2, 0, 401, 802, 103)
			DATA.addDamageToBoss(boss, 3, 0, 801, 102, 203)

			local sum = REPORT.sumDamageSourcesList(boss.damageSources)

			assert.is_equal(101 + 201 + 401 + 801, sum.physical)
			assert.is_equal(202 + 402 + 802 + 102, sum.elemental)
			assert.is_equal(403 + 803 + 103 + 203, sum.condition)
			assert.is_equal(1504 + 1508, sum.total)
		end)

	end)

	describe("hit count", function()

		it("counts correctly", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 500)
			DATA.addDamageToBoss(boss, 1, 0, 400)
			DATA.addDamageToBoss(boss, 1, 0, 300)
			DATA.addDamageToBoss(boss, 1, 0, 200)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 4
			local actual = r.items[1].numHit

			assert.is_equal(expected, actual)
		end)

	end)

	describe('marionette', function()

		it('counts damage for players', function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('MARIONETTE_IS_PLAYER_DMG', true)

			local monsterAttackerId = 300
			local marionetteDamageTypeId = 125
			DATA.addDamageToBoss(boss, monsterAttackerId, marionetteDamageTypeId
			, 100, 0, nil, nil, nil, nil, nil, 1)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			for _,item in ipairs(r.items) do
				local actual = item.total
				if item.id == monsterAttackerId then
					assert.is_equal(0, actual)
				elseif item.id == 1 then
					assert.is_equal(100, actual)
				end
			end
		end)

		it('counts damage for monster', function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('MARIONETTE_IS_PLAYER_DMG', false)

			local monsterAttackerId = 300
			local marionetteDamageTypeId = 125
			DATA.addDamageToBoss(boss, monsterAttackerId, marionetteDamageTypeId
			, 100, 0, nil, nil, nil, nil, nil, 1)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r= STATE.DAMAGE_REPORTS[1]

			for _,item in ipairs(r.items) do
				local actual = item.total
				if item.id == monsterAttackerId then
					assert.is_equal(100, actual)
				elseif item.id == 1 then
					assert.is_equal(0, actual)
				end
			end
		end)

	end)

	describe("biggest hit", function()

		it("counts correctly", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 500)
			DATA.addDamageToBoss(boss, 1, 0, 400)
			DATA.addDamageToBoss(boss, 1, 0, 300)
			DATA.addDamageToBoss(boss, 1, 0, 200)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			local expected = 500
			local actual = r.items[1].maxHit

			assert.is_equal(expected, actual)
		end)

	end)

	describe("buildup", function()

		it("gets set on boss", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 50, 5)

			local expected = 50
			local actual = boss.ailment.buildup[5][1]

			assert.is_equal(expected, actual)
		end)

		it("accumulates on boss", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 1, 5)
			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 2, 5)
			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 4, 5)

			local expected = 7
			local actual = boss.ailment.buildup[5][1]

			assert.is_equal(expected, actual)
		end)

		it("accumulates on boss for multiple attackers", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 1, 5)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 2, 5)
			DATA.addDamageToBoss(boss, 654, 0, 100, 0, 4, 5)

			assert.is_equal(1, boss.ailment.buildup[5][1])
			assert.is_equal(2, boss.ailment.buildup[5][2])
			assert.is_equal(4, boss.ailment.buildup[5][654])
		end)

	end)

	describe("ailment damage", function()

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 100, 5)

			DATA.calculateAilmentContrib(boss, 5)

			assert.is_equal(0.5, boss.ailment.share[5][1])
			assert.is_equal(0.5, boss.ailment.share[5][2])
		end)

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 100, 4)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 100, 4)

			DATA.calculateAilmentContrib(boss, 4)

			assert.is_equal(0.5, boss.ailment.share[4][1])
			assert.is_equal(0.5, boss.ailment.share[4][2])
		end)

		it("is distributed fairly", function()
			local boss = initializeMockBossMonster()

			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 100, 5)
			DATA.addDamageToBoss(boss, 3, 0, 100, 0, 200, 5)

			DATA.calculateAilmentContrib(boss, 5)

			assert.is_equal(0.25, boss.ailment.share[5][1])
			assert.is_equal(0.25, boss.ailment.share[5][2])
			assert.is_equal(0.5, boss.ailment.share[5][3])
		end)

		it("is distributed fairly (blast)", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('TABLE_SORT_IN_ORDER', true)

			DATA.addDamageToBoss(boss, 0, 0, 100, 0, 100, 5)
			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 100, 5)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 200, 5)
			DATA.addDamageToBoss(boss, 3, 0, 100, 0, 400, 5)

			DATA.calculateAilmentContrib(boss, 5)

			assert.is_equal(0.125, boss.ailment.share[5][0])
			assert.is_equal(0.125, boss.ailment.share[5][1])
			assert.is_equal(0.25, boss.ailment.share[5][2])
			assert.is_equal(0.5, boss.ailment.share[5][3])

			DATA.addAilmentDamageToBoss(boss, 5, 1000)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(125, r.items[1].totalBlast)
			assert.is_equal(125, r.items[2].totalBlast)
			assert.is_equal(250, r.items[3].totalBlast)
			assert.is_equal(500, r.items[4].totalBlast)

			DATA.addAilmentDamageToBoss(boss, 5, 1500)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(2500 * 0.125, r.items[1].totalBlast)
			assert.is_equal(2500 * 0.125, r.items[2].totalBlast)
			assert.is_equal(2500 * 0.25, r.items[3].totalBlast)
			assert.is_equal(2500 * 0.5, r.items[4].totalBlast)
		end)

		it("is distributed fairly (poison)", function()
			local boss = initializeMockBossMonster()

			CORE.SetCFG('TABLE_SORT_IN_ORDER', true)

			DATA.addDamageToBoss(boss, 0, 0, 100, 0, 100, 4)
			DATA.addDamageToBoss(boss, 1, 0, 100, 0, 100, 4)
			DATA.addDamageToBoss(boss, 2, 0, 100, 0, 200, 4)
			DATA.addDamageToBoss(boss, 3, 0, 100, 0, 400, 4)

			DATA.calculateAilmentContrib(boss, 4)

			assert.is_equal(0.125, boss.ailment.share[4][0])
			assert.is_equal(0.125, boss.ailment.share[4][1])
			assert.is_equal(0.25, boss.ailment.share[4][2])
			assert.is_equal(0.5, boss.ailment.share[4][3])

			DATA.addAilmentDamageToBoss(boss, 4, 20)
			DATA.addAilmentDamageToBoss(boss, 4, 20)
			DATA.addAilmentDamageToBoss(boss, 4, 20)
			DATA.addAilmentDamageToBoss(boss, 4, 20)
			DATA.addAilmentDamageToBoss(boss, 4, 20)

			REPORT.generateReport(STATE.REPORT_MONSTERS)

			local r = STATE.DAMAGE_REPORTS[1]

			assert.is_equal(12.5, r.items[1].totalPoison)
			assert.is_equal(12.5, r.items[2].totalPoison)
			assert.is_equal(25, r.items[3].totalPoison)
			assert.is_equal(50, r.items[4].totalPoison)
		end)

	end)

	describe("damage counter", function()

		it("is empty when initialized", function()
			local c = DATA.initializeDamageCounter()

			assert.is_equal(c.physical, 0)
			assert.is_equal(c.elemental, 0)
			assert.is_equal(c.condition, 0)

			local total = DATA.getTotalDamageForDamageCounter(c)

			assert.is_equal(0, total)
		end)

		it("merges correctly", function ()
			local a = DATA.initializeDamageCounter()
			local b = DATA.initializeDamageCounter()
			local result = DATA.initializeDamageCounter()

			a.physical = 100
			b.physical = 100
			result.physical = 200

			a.elemental = 405
			b.elemental = 5
			result.elemental = 410

			a.condition = 999
			b.condition = 3
			result.condition = 1002

			local actual = DATA.mergeDamageCounters(a,b)

			assert.are_same(result, actual)
		end)

		it("shows the right total", function()
			local c = DATA.initializeDamageCounter()

			c.physical = 100
			c.elemental = 212
			c.condition = 323

			local actual = DATA.getTotalDamageForDamageCounter(c)

			assert.is_equal(100 + 212, actual)
		end)

		describe("damage source", function()

			it("is empty when initialized", function()
				local s = DATA.initializeDamageSource()

				assert.is_nil(s.id)
			end)

		end)

	end)
end)