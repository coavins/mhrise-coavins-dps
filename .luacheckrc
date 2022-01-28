---@diagnostic disable
read_globals = {
	'sdk',
	're',
	'imgui',
	'draw',
	'log'
}

files['tests/'] = {
	globals = {
		'sdk',
		're',
		'imgui',
		'draw',
		'log'
	},
	std = '+busted',
	ignore = {'111','112','113','212'}
}

files['tests/*.test.lua'] = {
	globals = {
		'MANAGER'
	},
	std = '+busted',
	enable = {'111','112','212'}
}
