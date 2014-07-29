--[[
	@file: utils.lua
	@author: l0nger <l0nger.programmer@ourlife.pl> or admin@ourlife.pl
	
	(c) 2014, all rights reserved.	
]]

--[[
	string interpolation
	
	This function replaces all "pattern" names in a string with the value found in a table or a function.	
]]
local function string:interpolate(t, txt, pattern)
	pattern="%" .. pattern or "%$"
	return (txt:gsub(pattern .. "([%a_][%w_]*)", t))
end

--[[
	example
	
	local t={car="elegy", owner="jonhson"}
	print(string_interpolate(t, "$car - $owner", "$"))
	result: elegy - jonhson
]]