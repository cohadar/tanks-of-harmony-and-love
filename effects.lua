--- @module effects
local effects = {}

local utils = require "utils"

local _effects = {}

local DRAW_FPS = 60

-------------------------------------------------------------------------------
function effects.addExplosion( x, y, seconds )
	table.insert( _effects, { type = "explosion", x = x, y = y, tick = seconds * DRAW_FPS, radius = 0 } )
end

-------------------------------------------------------------------------------
function effects.update()
	for index, fx in pairs( _effects ) do
		fx.tick = fx.tick - 1
		if fx.tick < 0 then
			_effects[ index ] = nil
		end
	end
end

-------------------------------------------------------------------------------
function effects.draw()
	for index, fx in pairs( _effects ) do
		if fx.type == "explosion" then
			fx.radius = fx.radius + 2
			love.graphics.circle( "fill", fx.x, fx.y, fx.radius )
		else
			utils.print("unknown effect type", fx.type )
		end
	end	
end

-------------------------------------------------------------------------------
return effects

