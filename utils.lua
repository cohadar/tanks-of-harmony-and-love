--- @module utils
local utils = {}

local smallfolk = require "libs.smallfolk"

-------------------------------------------------------------------------------
-- facade over packing methods so we can change implementations
-------------------------------------------------------------------------------
utils.pack = smallfolk.dumps
utils.unpack = smallfolk.loads

-------------------------------------------------------------------------------
-- data-only deepcopy
-------------------------------------------------------------------------------
function utils.deepcopy( orig )
    local copy = orig
    if type( orig ) == 'table' then
        copy = {}
        for key, value in next, orig, nil do
            copy[ utils.deepcopy( key ) ] = utils.deepcopy( value )
        end
    end
    return copy
end

-------------------------------------------------------------------------------
-- we round up the angles because we don't really need all extra precision
-- and rounded angles are much easier synchronized in multiplayer
-------------------------------------------------------------------------------
function utils.round_angle( num )
  return math.floor( num * 0x10000 + 0.5 ) / 0x10000
end

-------------------------------------------------------------------------------
return utils