---@diagnostic disable
files['src/'] = {
	read_globals = {
		'sdk',
		're',
		'imgui',
		'draw',
		'log',
		'json',
		'fs'
	}
}

files['tests/'] = {
	globals = {
		'sdk',
		're',
		'imgui',
		'draw',
		'log',
		'json',
		'fs'
	},
	std = '+busted',
	ignore = {'111','112','113','212'}
}

files['tests/*.test.lua'] = {
	globals = {
		'MANAGER',
		'CFG'
	},
	std = '+busted',
	enable = {'111','112','212'}
}
