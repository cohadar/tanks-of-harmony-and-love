--- @module world
local m_world = {}

m_tank = require "tank"
m_utils = require "utils"

local localhost_tank = m_tank.new()
local tanks = {}

-- TODO: make server use world?

-------------------------------------------------------------------------------
function m_world.getLocalTank()
	return localhost_tank;
end

-------------------------------------------------------------------------------
function m_world.getTankPairs()
	return pairs( tanks )
end

-------------------------------------------------------------------------------
function m_world.update_tank( index, src_tank )
	local tank = tanks[ index ]
	if tank == nil then
		tank = m_tank.new()
		tanks[ index ] = tank
	end
	m_tank.slurp( tank, src_tank )
end

-------------------------------------------------------------------------------
function m_world.connect( index )
	-- production
	-- tanks[ index ] = localhost_tank 
	
	-- testing
	tanks[ index ] = m_utils.deepcopy( localhost_tank ) 
	tanks[ 0 ] = localhost_tank
end

-------------------------------------------------------------------------------
function m_world.player_gone( index )
	tanks[ index ] = nil
end

-------------------------------------------------------------------------------
return m_world