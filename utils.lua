--- @module utils
local utils = {}

local smallfolk = require "libs.smallfolk"
local rgb = require "libs.rgb"
local text = require "text"

-------------------------------------------------------------------------------
-- for testing only
-------------------------------------------------------------------------------
utils.x = 0.0
utils.y = 0.0

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
-- this function also normalizes angle to -math.pi .. +math.pi
-------------------------------------------------------------------------------
function utils.cleanAngle( angle )
	angle = math.atan2( math.sin( angle ), math.cos( angle ) )
  	return math.floor( angle * 0x10000 + 0.5 ) / 0x10000
end

-------------------------------------------------------------------------------
function utils.setColor( color_name, alpha )
    local color = rgb[ color_name ]
    assert( color, "unknown color: " .. color_name )
    love.graphics.setColor(color.r, color.g, color.b, alpha or 255 )
end

-------------------------------------------------------------------------------
-- testing only
-------------------------------------------------------------------------------
function utils.keypressed( key )
    if key     == "c" then
        utils.x = utils.x + 1
        text.print( "utils.x", utils.x )
    elseif key == "z" then
        utils.x = utils.x - 1
        text.print( "utils.x", utils.x )
    elseif key == "u" then
        utils.y = utils.y + 1
        text.print( "utils.y", utils.y )
    elseif key == "t" then
        utils.y = utils.y - 1
        text.print( "utils.y", utils.y )
    end
end

-------------------------------------------------------------------------------
return utils