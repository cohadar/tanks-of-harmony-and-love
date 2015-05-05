--- @module history
local m_tests = {}

local m_tank = require "tank"
local m_utils = require "utils"
local m_history = require "history"

-------------------------------------------------------------------------------
function m_tests.run_all()
	local tank_a = m_tank.new()
	m_history.tank_record( 77 , tank_a )
	tank_a.x = 123.232
	local tank_b = m_history.get_tank( 77 )
	assert( m_tank.neq(tank_a, tank_b) == true )
end

-------------------------------------------------------------------------------
return m_tests