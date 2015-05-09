--- @module world
local world = {}

conf = require "conf"
tank = require "tank"
utils = require "utils"

local _tanks = {}
_tanks[ 0 ] = tank.new() -- tank on index zero is localhost tank

-- TODO: make server use world?
-- TODO: add bullets to world?

-------------------------------------------------------------------------------
function world.getTank( index )
	return utils.deepcopy( _tanks[ index ] );
end

-------------------------------------------------------------------------------
function world.tankPairs()
	return pairs( _tanks )
end

-------------------------------------------------------------------------------
function world.updateTank( index, src_tank )
	local tnk = _tanks[ index ]
	if tnk == nil then
		tnk = tank.new()
		_tanks[ index ] = tnk
	end
	tank.slurp( tnk, src_tank )
end

-------------------------------------------------------------------------------
function world.connect( index )
	if conf.NETCODE_DEBUG then
		_tanks[ index ] = utils.deepcopy( _tanks[ 0 ] ) 
	end
end

-------------------------------------------------------------------------------
function world.playerGone( index )
	_tanks[ index ] = nil
end

-------------------------------------------------------------------------------
return world