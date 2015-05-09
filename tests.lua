--- @module tests
local tests = {}

local tank = require "tank"
local utils = require "utils"
local history = require "history"
local smallfolk = require "libs.smallfolk"

local Njak = {}
function Njak.new()
	local self = { x = 0, y = 0 }
	return self
end

function Njak:move( x, y )
	self.x = x
	self.y = y
end

-------------------------------------------------------------------------------
function tests.runAll()
	local tank_a = tank.new()

	local text = string.format("%1.16e", math.pi)
	local pi1 = tonumber( text )
	assert( math.pi == pi1 )

	local text = string.format("%.17g", math.pi)
	local pi = tonumber( text )
	assert( math.pi == pi )

	local text = smallfolk.dumps( { pi = math.pi } )
	t =  smallfolk.loads( text )
	assert( math.pi == t.pi )
end

-------------------------------------------------------------------------------
return tests