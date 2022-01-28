--#region type definition

function createMockTypeDefinition()
	local mockTypeDefinition = {}

	function mockTypeDefinition:get_method(self, name)
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

function sdk:get_native_singleton(self, name)
	return 'singleton'
end

function sdk:find_type_definition(self, name)
	return createMockTypeDefinition()
end

function sdk:call_native_func(self, name)
	-- do nothing
end

function sdk:hook(self, name, fnPre, fnPost)
	-- do nothing
end

--#endregion

--#region re

re = {}

function re:on_frame(self, fnFrame)
	-- do nothing
end

function re:on_draw_ui(self, fnFrame)
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
