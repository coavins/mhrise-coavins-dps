package.path = package.path .. ';tests/?.lua'

require 'mock.mock_d2d'
require 'mock.mock_fs'
require 'mock.mock_json'

--#region type definition

local function createMockTypeDefinition()
	local mockTypeDefinition = {}

	function mockTypeDefinition:get_method(name)
		return 'no method'
	end

	return mockTypeDefinition
end

--#endregion

--#region MockMessageManager

MockMessageManager = {}
MockMessageManager.__index = MockMessageManager

function MockMessageManager:create()
	local manager = {}
	setmetatable(manager, MockMessageManager)

	return manager;
end

function MockMessageManager:call(what)
	if what == 'getEnemyNameMessage' then
		return 'MockEnemy';
	end
end

--#endregion

--#region MockEnemy

MockEnemy = {}
MockEnemy.__index = MockEnemy

function MockEnemy:create()
	local enemy = {}
	setmetatable(enemy, MockEnemy)

	return enemy;
end

function MockEnemy:call(what)
	if what == 'get_EnemySpecies' then
		return 0;
	elseif what == 'get_BossEnemyGenus' then
		return 101;
	end
end

function MockEnemy:get_field(what)
	if what == '<EnemyType>k__BackingField' then
		return 0;
	end
end

--#endregion

--#region sdk

sdk = {}

function sdk.get_native_singleton(name)
	return 'singleton'
end

function sdk.find_type_definition(name)
	return createMockTypeDefinition()
end

function sdk.call_native_func(name, type, func)
	-- do nothing
end

function sdk.hook(name, fnPre, fnPost)
	-- do nothing
end

--#endregion

--#region re

re = {}

function re:on_frame(fnFrame)
	-- do nothing
end

function re:on_draw_ui(fnFrame)
	-- do nothing
end

function re:on_config_save(fnSave)
	-- do nothing
end

--#endregion

--#region log

log = {}

function log.error(text)
	error(text)
end

function log.info(text)
	--print(text)
end

--#endregion
