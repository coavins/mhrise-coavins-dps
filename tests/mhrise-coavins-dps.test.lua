---@diagnostic disable: undefined-global
_G._UNIT_TESTING = true

require 'tests/mock'
require 'src/mhrise-coavins-dps'

describe("mhrise-coavins-dps", function()
	setup(function()
		MANAGER.MESSAGE = MockMessageManager:create()
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

			assert.is_equal(635, actual)
		end)
	end)
	describe("damage source", function()
		it("is empty when initialized", function()
			local s = initializeDamageSource()

			assert.is_nil(s.id)
		end)
	end)
	describe("report", function()
		it("merges a damage source correctly", function()
			local r = initializeReport()

			local bossSources = {}
			bossSources[1] = initializeDamageSource(1)
			bossSources[1].damageCounters['weapon'] = initializeDamageCounter()
			bossSources[1].damageCounters['weapon'].physical = 100

			local actual = 100

			mergeDamageSourcesIntoReport(r, bossSources)

			assert.is_equal(actual, r.totalDamage)

		end)
		it("merges two bosses correctly", function()
			local r = initializeReport()

			local boss1 = {}
			boss1[1] = initializeDamageSource(1)
			boss1[1].damageCounters['weapon'] = initializeDamageCounter()
			boss1[1].damageCounters['weapon'].physical = 100
			boss1[1].damageCounters['weapon'].elemental = 50
			boss1[1].damageCounters['weapon'].condition = 7

			local boss2 = {}
			boss2[1] = initializeDamageSource(1)
			boss2[1].damageCounters['weapon'] = initializeDamageCounter()
			boss2[1].damageCounters['weapon'].physical = 201
			boss2[1].damageCounters['weapon'].elemental = 54
			boss2[1].damageCounters['weapon'].condition = 18

			mergeDamageSourcesIntoReport(r, boss1)
			mergeDamageSourcesIntoReport(r, boss2)

			local expected = 100 + 50 + 7 + 201 + 54 + 18
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)
		it("generates from boss cache correctly", function()
			-- automatically puts boss into cache
			local enemy = MockEnemy:create()
			initializeBossMonster(enemy)
			local boss = LARGE_MONSTERS[enemy]

			addDamageToBoss(boss, 1, 0, 100, 200, 300)
			addDamageToBoss(boss, 2, 0, 0, 100, 0)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			assert.is_equal(r.totalDamage, 700)
			assert.is_equal(r.topDamage, 600)
		end)
	end)
end)
