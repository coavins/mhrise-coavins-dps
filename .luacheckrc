---@diagnostic disable
files['src/'] = {
	read_globals = {
		'sdk',
		're',
		'imgui',
		'draw',
		'log',
		'json',
		'fs',
		'd2d'
	}
}

files['tests/'] = {
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
