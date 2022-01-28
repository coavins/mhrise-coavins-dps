---@diagnostic disable: undefined-global
_G._UNIT_TESTING = true

require 'tests/mock'
require 'src/mhrise-coavins-dps'

local function initializeMockBossMonster()
	-- automatically puts boss into cache
	local enemy = MockEnemy:create()
	initializeBossMonster(enemy)
	local boss = LARGE_MONSTERS[enemy]
	return boss;
end

describe("mhrise-coavins-dps", function()
	setup(function()
		MANAGER.MESSAGE = MockMessageManager:create()
	end)

	before_each(function()
		cleanUpData();

		-- all attacker types enabled
		for _,type in pairs(ATTACKER_TYPES) do
			AddAttackerTypeToReport(type);
		end
	end)

	describe("boss", function()

		it("works through damage hook with one attacker", function()
			local boss = initializeMockBossMonster();

			addDamageToBoss(boss, 1, 0, 100, 200, 400);

			local sum = sumDamageSourcesList(boss.damageSources)
			assert.is_equal(100, sum.physical)
			assert.is_equal(200, sum.elemental)
			assert.is_equal(400, sum.condition)
			assert.is_equal(700, sum.total)
		end)

		it("works through damage hook with a full party of four", function()
			local boss = initializeMockBossMonster();

			addDamageToBoss(boss, 0, 0, 101, 202, 403);
			addDamageToBoss(boss, 1, 0, 201, 402, 803);
			addDamageToBoss(boss, 2, 0, 401, 802, 103);
			addDamageToBoss(boss, 3, 0, 801, 102, 203);

			local sum = sumDamageSourcesList(boss.damageSources)

			assert.is_equal(101 + 201 + 401 + 801, sum.physical)
			assert.is_equal(202 + 402 + 802 + 102, sum.elemental)
			assert.is_equal(403 + 803 + 103 + 203, sum.condition)
			assert.is_equal(1504 + 1508 + 1512, sum.total)
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

		it("merges a boss correctly", function()
			local r = initializeReport()
			local b = initializeMockBossMonster();

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
			local boss1 = initializeMockBossMonster();
			local boss2 = initializeMockBossMonster();

			local s1 = {}
			s1[1] = initializeDamageSource(1)
			s1[1].counters['weapon'] = initializeDamageCounter()
			s1[1].counters['weapon'].physical = 100
			s1[1].counters['weapon'].elemental = 50
			s1[1].counters['weapon'].condition = 7

			boss1.damageSources = s1;

			local s2 = {}
			s2[1] = initializeDamageSource(1)
			s2[1].counters['weapon'] = initializeDamageCounter()
			s2[1].counters['weapon'].physical = 201
			s2[1].counters['weapon'].elemental = 54
			s2[1].counters['weapon'].condition = 18

			boss2.damageSources = s2;

			mergeBossIntoReport(r, boss1)
			mergeBossIntoReport(r, boss2)

			local expected = 100 + 50 + 7 + 201 + 54 + 18
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)
		it("merges three bosses correctly", function()
			local r = initializeReport()
			local boss1 = initializeMockBossMonster();
			local boss2 = initializeMockBossMonster();
			local boss3 = initializeMockBossMonster();

			local s1 = {}
			s1[1] = initializeDamageSource(1)
			s1[1].counters['weapon'] = initializeDamageCounter()
			s1[1].counters['weapon'].physical = 100
			s1[1].counters['weapon'].elemental = 50
			s1[1].counters['weapon'].condition = 7

			boss1.damageSources = s1;

			local s2 = {}
			s2[1] = initializeDamageSource(1)
			s2[1].counters['weapon'] = initializeDamageCounter()
			s2[1].counters['weapon'].physical = 201
			s2[1].counters['weapon'].elemental = 54
			s2[1].counters['weapon'].condition = 18

			boss2.damageSources = s2;

			local s3 = {}
			s3[1] = initializeDamageSource(1)
			s3[1].counters['weapon'] = initializeDamageCounter()
			s3[1].counters['otomo'] = initializeDamageCounter()

			boss3.damageSources = s3;

			mergeBossIntoReport(r, boss1)
			mergeBossIntoReport(r, boss2)
			mergeBossIntoReport(r, boss3)

			local expected = 100 + 50 + 7 + 201 + 54 + 18
			local actual = r.totalDamage

			assert.is_equal(expected, actual)

		end)
		it("generates from boss cache correctly", function()
			local boss = initializeMockBossMonster()

			addDamageToBoss(boss, 1, 0, 100, 200, 300)
			addDamageToBoss(boss, 2, 0, 0, 100, 0)

			generateReport(REPORT_MONSTERS)

			local r = DAMAGE_REPORTS[1]

			assert.is_equal(r.totalDamage, 700)
			assert.is_equal(r.topDamage, 600)
		end)
	end)
end)
