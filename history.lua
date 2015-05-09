--- @module history
local history = {}

utils = require "utils"

-- TODO: replace with circular buffer
local _history = {}

-------------------------------------------------------------------------------
function history.tankRecord( tick, tank )
	_history[ tick ] = utils.deepcopy( tank )
end

-------------------------------------------------------------------------------
function history.getTank( tick )
	return utils.deepcopy( _history[ tick ] )
end

-------------------------------------------------------------------------------
function history.clearRankRecord( tick )
	_history[ tick ] = nil
end

-------------------------------------------------------------------------------
function history.reset()
	_history = {}
end

-------------------------------------------------------------------------------
return history