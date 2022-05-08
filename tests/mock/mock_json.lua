local jsonlua = require 'tests.mock.json'

json = {}

json.load_file = function(filename)
	local file = io.open('src/data/' .. filename, 'r')
	if file then
		local contents = file:read("*all")
		local j = jsonlua.decode(contents)
		return j
	end
	return nil
end
