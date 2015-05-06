--- @module world
local m_world = {}

m_tank = require "tank"
m_utils = require "utils"

local tanks = {}
tanks[ 0 ] = m_tank.new() -- tank on index zero is localhost tank

-- TODO: make server use world?


-------------------------------------------------------------------------------
function m_world.get_tank( index )
	return m_utils.deepcopy( tanks[ index ] );
end

-------------------------------------------------------------------------------
function m_world.tank_pairs()
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
	if NETCODE_DEBUG then
		tanks[ index ] = m_utils.deepcopy( tanks[ 0 ] ) 
	end
end

-------------------------------------------------------------------------------
function m_world.player_gone( index )
	tanks[ index ] = nil
end

-------------------------------------------------------------------------------
return m_world