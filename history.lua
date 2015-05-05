--- @module history
local m_history = {}

m_tank = require "tank"

-- TODO: replace with circular buffer
local history = {}
local tick = 0

-------------------------------------------------------------------------------
function m_history.tank_record( tank )
	tick = tick + 1
	history[ tick ] = tank
	return tick
end

-------------------------------------------------------------------------------
function m_history.get_tank( index )
	return history[ tick ]
end

-------------------------------------------------------------------------------
function m_history.clear_tank_record( index )
	history[ index ] = nil
end

-------------------------------------------------------------------------------
return m_history