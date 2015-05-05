--- @module history
local m_history = {}

m_tank = require "tank"
m_utils = require "utils"

-- TODO: replace with circular buffer
local history = {}

-------------------------------------------------------------------------------
function m_history.tank_record( tick, tank )
	history[ tick ] = m_utils.deepcopy( tank )
end

-------------------------------------------------------------------------------
function m_history.get_tank( tick )
	return m_utils.deepcopy( history[ tick ] )
end

-------------------------------------------------------------------------------
function m_history.clear_tank_record( tick )
	history[ tick ] = nil
end

-------------------------------------------------------------------------------
function m_history.reset()
	history = {}
end

-------------------------------------------------------------------------------
return m_history