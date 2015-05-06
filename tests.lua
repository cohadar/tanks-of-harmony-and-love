--- @module history
local m_tests = {}

local m_tank = require "tank"
local m_utils = require "utils"
local m_history = require "history"
local serpent = require "serpent"

-------------------------------------------------------------------------------
function m_tests.run_all()
	local tank_a = m_tank.new()
	m_history.tank_record( 77 , tank_a )
	tank_a.x = 123.232
	local tank_b = m_history.get_tank( 77 )
	assert( m_tank.neq(tank_a, tank_b) == true )

	local text = string.format("%1.16e", math.pi)
	local pi1 = tonumber( text )
	assert( math.pi == pi1 )

	local text = string.format("%1.17g", math.pi)
	local pi2 = tonumber( text )
	assert( math.pi == pi2 )

	-- local text = serpent.line( { pi = math.pi } )
	-- ok, t = serpent.load( text )
	-- assert( ok )
	-- assert( math.pi == t.pi )

end

-------------------------------------------------------------------------------
return m_tests