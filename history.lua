--- @module history
local history = {}

utils = require "utils"

local _history = {}

-------------------------------------------------------------------------------
function history.set( index, data )
	_history[ index ] = utils.deepcopy( data )
end

-------------------------------------------------------------------------------
function history.getAndClear( index )
	return utils.deepcopy( _history[ index ] )
end

-------------------------------------------------------------------------------
function history.reset()
	_history = {}
end

-------------------------------------------------------------------------------
return history